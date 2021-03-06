Code.ensure_compiled(XAdmin.Utils)
defmodule XAdmin.Table do
  @module_doc false
  require Integer
  use Xain
  import XAdmin.Helpers
  import XAdmin.Utils
  import XAdmin.Render
  import XAdmin.Theme.Helpers
  import XAdmin.Gettext
  import Kernel, except: [to_string: 1]
  alias XAdmin.Schema

  def attributes_table(conn, resource, schema) do
    theme_module(conn, Table).theme_attributes_table conn, resource,
      schema, model_name(resource)
  end

  def attributes_table_for(conn, resource, schema) do
    theme_module(conn, Table).theme_attributes_table_for conn, resource,
      schema, model_name(resource)
  end

  def do_attributes_table_for(conn, resource, resource_model, schema, table_opts) do
    primary_key = Schema.get_id(resource)
    div(".panel_contents") do
      id = "attributes_table_#{resource_model}_#{primary_key}"
      div(".attributes_table.#{resource_model}#{id}") do
        table(table_opts) do
          tbody do
            for field_name <- Map.get(schema, :rows, []) do
              build_field(resource, conn, field_name, fn(contents, f_name) ->
                tr do
                  field_header field_name
                  handle_contents(contents, f_name)
                end
              end)
            end
          end
        end
      end
    end
  end

  def field_header({_, %{label: label}}), do: th(humanize label)
  def field_header({field_name, _opts}), do: field_header(field_name)
  def field_header(field_name), do: th(humanize field_name)

  def panel(conn, schema, _opts \\ []) do
    theme_module(conn, Table).theme_panel(conn, schema)
  end

  def do_panel(conn, columns \\ [], table_opts \\ [], output \\ [])
  def do_panel(_conn, [], _table_opts, output), do: Enum.join(Enum.reverse(output))
  def do_panel(conn, [{:table_for, %{resources: resources, columns: columns, opts: opts}} | tail], table_opts, output) do
    output = [table(Dict.merge(table_opts, opts)) do
      table_head(columns)
      tbody do
        model_name = get_resource_model resources
        Enum.with_index(resources)
        |> Enum.map(fn({resource, inx}) ->
          odd_even = if Integer.is_even(inx), do: "even", else: "odd"
          tr_id = if Map.has_key?(resource, :id), do: resource.id, else: inx
          tr(".#{odd_even}##{model_name}_#{tr_id}") do
            for field <- columns do
              case field do
                {f_name, fun} when is_function(fun) ->
                  td ".td-#{parameterize f_name} #{fun.(resource)}"
                {f_name, opts} ->
                  build_field(resource, conn, {f_name, Enum.into(opts, %{})}, fn(contents, f_name) ->
                    td ".td-#{parameterize f_name} #{contents}"
                  end)
              end
            end
          end
        end)
      end
    end | output]
    do_panel(conn, tail, table_opts, output)
  end
  def do_panel(conn, [{:contents, %{contents: content}} | tail], table_opts, output) do
    output = [
      case content do
        {:safe, _} -> Phoenix.HTML.safe_to_string(content)
        content -> content
      end
      |> Xain.raw | output]
    do_panel(conn, tail, table_opts, output)
  end
  # skip unknown blocks
  def do_panel(conn, [_head|tail], table_opts, output) do
    do_panel(conn, tail, table_opts, output)
  end

  def table_head(columns, opts \\ %{}) do
    selectable = Map.get opts, :selectable_column

    thead do
      tr do
        if selectable do
          th(".selectable") do
            div(".resource_selection_toggle_cell") do
              input("#collection_selection_toggle_all.toggle_all", type: "checkbox", name: "collection_selection_toggle_all")
            end
          end
        end
        for field <- columns do
          build_th field, opts
        end
      end
    end
  end

  def build_th({field_name, opts}, table_opts) when is_atom(field_name),
    do: build_th(Atom.to_string(field_name), opts, table_opts)
  def build_th({field_name, _opts}, _table_opts) when is_binary(field_name),
    do: th(".th-#{parameterize field_name} #{humanize field_name}")
  def build_th(field_name, _),
    do: th(".th-#{parameterize field_name} #{humanize field_name}")
  def build_th(field_name, opts, %{fields: fields} = table_opts) do
    if String.to_atom(field_name) in fields do
      _build_th(field_name, opts, table_opts)
    else
      th(".th-#{parameterize field_name} #{humanize field_name}")
    end
  end
  def build_th(field_name, _, _) when is_binary(field_name) do
    th(class: to_class("th-", field_name)) do
    # th do
      text humanize(field_name)
    end
  end
  def build_th(field_name, _, _), do: build_th(field_name, nil)

  def _build_th(field_name, opts, %{path_prefix: path_prefix, order: {name, sort},
      fields: _fields} = table_opts) when field_name == name do
    label = if opts[:label], do: opts[:label], else: field_name
    link_order = if sort == "desc", do: "asc", else: "desc"
    page_segment = case Map.get table_opts, :page, nil do
      nil -> ""
      page -> "&page=#{page.page_number}"
    end
    scope_segment = case table_opts[:scope] do
      nil -> ""
      scope -> "&scope=#{scope}"
    end
    th(".sortable.sorted-#{sort}.th-#{field_name}") do
      a("#{humanize label}", href: path_prefix <>
        field_name <> "_#{link_order}#{page_segment}" <> scope_segment <>
        Map.get(table_opts, :filter, ""))
    end
  end
  def _build_th(field_name, opts, %{path_prefix: path_prefix} = table_opts) do
    label = if opts[:label], do: opts[:label], else: field_name
    sort = Map.get(table_opts, :sort, "asc")
    page_segment = case Map.get table_opts, :page, nil do
      nil -> ""
      page -> "&page=#{page.page_number}"
    end
    scope_segment = case table_opts[:scope] do
      nil -> ""
      scope -> "&scope=#{scope}"
    end
    th(".sortable.th-#{field_name}") do
      a("#{humanize label}", href: path_prefix <>
        field_name <> "_#{sort}#{page_segment}" <> scope_segment <>
        Map.get(table_opts, :filter, ""))
    end
  end
  def handle_contents(%Ecto.DateTime{} = dt, field_name) do
    td class: to_class("td-", field_name) do
      text to_string(dt)
    end
  end
  def handle_contents(%Ecto.Time{} = dt, field_name) do
    td class: to_class("td-", field_name) do
      text to_string(dt)
    end
  end
  def handle_contents(%Ecto.Date{} = dt, field_name) do
    td class: to_class("td-", field_name) do
      text to_string(dt)
    end
  end
  def handle_contents(%{}, _field_name), do: []
  def handle_contents(contents, field_name) when is_binary(contents) do
    td(to_class(".td-", field_name)) do
      text contents
    end
  end
  def handle_contents({:safe, contents}, field_name) do
    handle_contents contents, field_name
  end
  def handle_contents(contents, field_name) do
    td(to_class(".td-", field_name), contents)
  end

end
