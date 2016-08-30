defmodule XAdmin.Web do
  @moduledoc false

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      import Ecto.Model
      import Ecto.Query, only: [from: 1, from: 2]

      import XAdmin.Router.Helpers
      import XAdmin.Utils, only: [admin_path: 0, admin_path: 2, admin_resource_path: 3, admin_association_path: 4]
      import XAdmin.Controller

      defp set_theme(conn, _) do
        assign(conn, :theme, XAdmin.theme)
      end

      defp set_layout(conn, _) do
        layout = Application.get_env(:xadmin, :layout) || "#{conn.assigns.theme.name}.html"
        put_layout(conn, layout)
      end
    end
  end

  def view do
    quote do
      require Logger


      file_path = __ENV__.file
      |> Path.dirname
      |> String.split("/views")
      |> hd
      |> Path.join("templates")

      use Phoenix.View, root: file_path
      # use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import XAdmin.Router.Helpers
      #import ExAuth
      import XAdmin.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      # alias Application.get_env(:xadmin, :repo)
      # import Application.get_env(:xadmin, :repo)
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
