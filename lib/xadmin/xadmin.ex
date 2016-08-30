defmodule XAdmin do
  @moduledoc """
  XAdmin is a an auto administration tool for the PhoenixFramework,
  providing a quick way to create a CRUD interface for administering
  Ecto models with little code and the ability to customize the
  interface if desired.

  After creating one or more Ecto models, the administration tool can
  be used by creating a resource model for each model. The basic
  resource file for model ... looks like this:

      # web/admin/my_model.ex

      defmodule MyProject.XAdmin.MyModel do
        use XAdmin.Register

        register_resource MyProject.MyModel do
        end
      end

  This file can be created manually, or by using the mix task:

      mix admin.gen.resource MyModel

  XAdmin adds a menu item for the model in the admin interface, along
  with the ability to index, add, edit, show and delete instances of
  the model.

  Many of the pages in the admin interface can be customized for each
  model using a DSL. The following can be customized:

  * `index` - Customize the index page
  * `show` - Customize the show page
  * `form` - Customize the new and edit pages
  * `menu` - Customize the menu item
  * `controller` - Customer the controller

  ## Custom Ecto Types

  ### Map Type

  By default, XAdmin used Poison.encode! to encode `Map` type. To change the
  decoding, add override the protocol. For Example:

      defimpl XAdmin.Render, for: Map do
        def to_string(map) do
          {:ok, encoded} = Poison.encode map
          encoded
        end
      end

  As well as handling the encoding to display the data, you will need to handle
  the params decoding for the `:create` and `:modify` actions. You have a couple
  options for handling this.

  * In your changeset, you can update the params field with the decoded value
  * Add a controller `before_filter` in your admin resource file.

  For example:

      register_resource AdminIdIssue.UserSession do
        controller do
          before_filter :decode, only: [:update, :create]

          def decode(conn, params) do
            if get_in params, [:usersession, :data] do
              params = update_in params, [:usersession, :data], &(Poison.decode!(&1))
            end
            {conn, params}
          end
        end
      end

  ## Other Types

  To support other Ecto Types, implement the XAdmin.Render protocol for the
  desired type. Here is an example from the XAdmin code for the `Ecto.Date` type:

      defimpl XAdmin.Render, for: Ecto.Date do
        def to_string(dt) do
          Ecto.Date.to_string dt
        end
      end

  ## Adding Custom CSS or JS to the Layout Head

  A configuration item is available to add your own CSS or JS files
  to the `<head>` section of XAdmin's layout file.

  Add the following to your project's `config/config.exs` file:

    config :xadmin,
      head_template: {XAdminDemo.AdminView, "admin_layout.html"}

  Where:
  * `XAdminDemo.AdminView` is a view in your project
  * `admin_layout.html` is a template in `web/templates/admin` directory

  For example:

  in `web/templates/admin/admin_layout.html.eex`
  ```html
  <link rel='stylesheet' href='<%= static_path(@conn, "/css/admin_custom.css") %>'>

  <!--
    since this is rendered into the head area, make sure to defer the loading
    of your scripts with `async` to not block rendering.
  -->
  <script async src='<%= static_path(@conn, "/js/app.js") %>'></script>
  ```

  in `priv/static/css/admin_custom.css`
  ```css
  .foo {
    color: green !important;
    font-weight: 600;
  }
  ```

  """
  require Logger
  use Xain
  alias XAdmin.Utils
  import XAdmin.Utils, only: [titleize: 1, humanize: 1, admin_resource_path: 2]
  require XAdmin.Register

  @filename "/tmp/xadmin_registered"
  Code.ensure_compiled XAdmin.Register

  Module.register_attribute __MODULE__, :registered, accumulate: true, persist: true

  @default_theme XAdmin.Theme.AdminLte2

  defmacro __using__(_) do
    quote do
      use XAdmin.Index
      import unquote(__MODULE__)
    end
  end

  # check for old xain.after_callback format and issue a compile time
  # exception if not configured correctly.

  case Application.get_env :xain, :after_callback do
    nil -> nil
    {_, _} -> nil
    _ ->
      raise XAdmin.CompileError, message: "Invalid xain_callback in config. Use {Phoenix.HTML, :raw}"
  end

  @doc false
  def registered, do: Application.get_env(:xadmin, :modules, []) |> Enum.reverse

  @doc false
  def put_data(key, value) do
    Agent.update __MODULE__, &(Map.put(&1, key, value))
  end

  @doc false
  def get_data(key) do
    Agent.get __MODULE__, &(Map.get(&1, key))
  end

  @doc false
  def get_all_registered do
    for reg <- registered do
      case get_registered_resource(reg) do
        %{resource_model: rm} = item ->
          {rm, item}
        %{type: :page} = item ->
          {nil, item}
      end
    end
  end

  @doc false
  def get_registered_resource(name) do
    apply(name, :__struct__, [])
  end

  @doc false
  def get_registered do
    for reg <- registered do
      get_registered_resource(reg)
    end
  end
  @doc false
  def get_registered(resource_model) do
    get_all_registered
    |> Keyword.get(resource_model)
  end


  def get_registered_by_association(resource, assoc_name) do
    resource_model = resource.__struct__
    assoc_model = case resource_model.__schema__(:association, assoc_name) do
      %{through: [link1, link2]} ->
        resource |> Ecto.build_assoc(link1) |> Ecto.build_assoc(link2) |> Map.get(:__struct__)
      %{queryable: assoc_model} ->
        assoc_model
      nil ->
        raise ArgumentError.exception("Association #{assoc_name} is not found.\n#{inspect(resource_model)}.__schema__(:association, #{inspect(assoc_name)}) returns nil")
      _ ->
        raise ArgumentError.exception("Association type of #{assoc_name} is not supported. Please, fill an issue.")
    end
    Enum.find get_registered, %{}, &(Map.get(&1, :resource_model) == assoc_model)
  end


  @doc false
  def get_controller_path(%{} = resource) do
    get_controller_path Map.get(resource, :__struct__)
  end
  @doc false
  def get_controller_path(resource_model) when is_atom(resource_model) do
    get_all_registered
    |> Keyword.get(resource_model, %{})
    |> Map.get(:controller_route)
  end

  @doc false
  def get_title_actions(%Plug.Conn{private: _private, path_info: _path_info} = conn) do
    defn = conn.assigns.defn
    fun = defn |> Map.get(:title_actions)
    fun.(conn, defn)
  end

  @doc false
  def get_title_actions(name) do
    case get_registered(name) do
      nil ->
        &__MODULE__.default_page_title_actions/2
      %{title_actions: actions} ->
        actions
    end
  end

  @doc false
  def get_name_from_controller(controller) when is_atom(controller) do
    get_all_registered
    |> Enum.find_value(fn({name, %{controller: c_name}}) ->
      if c_name == controller, do: name
    end)
  end

  @doc false
  def default_resource_title_actions(%Plug.Conn{params: params} = conn, %{resource_model: _resource_model} = defn) do
    singular = XAdmin.Utils.displayable_name_singular(conn) |> titleize
    actions = defn.actions
    case Utils.action_name(conn) do
      :show ->
        id = Map.get(params, "id")
        Enum.reduce([:edit, :new, :delete], [], fn(action, acc) ->
          if Utils.authorized_action?(conn, action, defn) do
            [{action, action_button(conn, defn, singular, :show, action, actions, id)}|acc]
          else
            acc
          end
        end)
        |> add_custom_actions(:show, actions, id)
        |> Enum.reverse
      action when action in [:index, :edit] ->
        if Utils.authorized_action?(conn, action, defn) do
          [{action, action_button(conn, defn, singular, action, :new, actions)}]
        else
          []
        end
        |> add_custom_actions(action, actions)
        |> Enum.reverse
      _ ->
        []
    end
  end

  @doc false
  def default_page_title_actions(_conn, _) do
    []
  end

  @doc """
  Get current theme name
  """

  def theme do
    Application.get_env(:xadmin, :theme, @default_theme)
  end

  def theme_name(conn) do
    conn.assigns.theme.name
  end

  def action_button(conn, defn, name, _page, action, actions, id \\ nil) do
    if action in actions do
      if XAdmin.Utils.authorized_action?(conn, action, defn) do
        [action_link(conn, name, action, id)]
      else
        []
      end
    else
      []
    end
  end

  defp add_custom_actions(acc, action, actions, id \\ nil)
  defp add_custom_actions(acc, _action, [], _id), do: acc
  defp add_custom_actions(acc, action, [{action, button} | actions], id) do
    import XAdmin.ViewHelpers
    {fun, _} = Code.eval_quoted button, [id: id], __ENV__
    cond do
      is_function(fun, 1) -> [fun.(id) | acc]
      is_function(fun, 0) -> [fun.() | acc]
      true                -> acc
    end
    |> add_custom_actions(action, actions, id)
  end
  defp add_custom_actions(acc, action, [_|actions], id) do
    add_custom_actions(acc, action, actions, id)
  end

  defp action_link(conn, name, :delete, _id) do
    {button_name(name, :delete),
      [href: admin_resource_path(conn, :destroy),
        "data-confirm": Utils.confirm_message,
        "data-method": :delete, rel: :nofollow]}
  end
  defp action_link(conn, name, action, _id) do
    {button_name(name, action),
      [href: admin_resource_path(conn, action)]}
  end

  defp button_name(name, :destroy), do: button_name(name, :delete)
  defp button_name(name, action) do
    "#{humanize action} #{name}"
  end

  @doc false
  def has_action?(conn, defn, action) do
    if XAdmin.Utils.authorized_action?(conn, action, defn),
      do: _has_action?(defn, action), else: false
  end

  defp _has_action?(defn, action) do
    except = Keyword.get defn.actions, :except, []
    only = Keyword.get defn.actions, :only, []
    cond do
      action in defn.actions -> true
      action in only -> true
      action in except -> false
      true -> false
    end
  end

end
