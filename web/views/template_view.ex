defmodule XAdmin.TemplateView do
  @moduledoc false
  use XAdmin.Web, :view
  # import XAdmin.Authentication

  def site_title do
    case Application.get_env(:xadmin, :module) |> Module.split do
      [_, title | _] -> title
      [title] -> title
      _ -> "XAdmin"
    end
  end

  def check_for_sidebars(conn, filters, defn) do
    require Logger
    if (is_nil(filters) or filters == false) and not XAdmin.Sidebar.sidebars_visible?(conn, defn) do
      {false, "without_sidebar"}
    else
      {true, "with_sidebar"}
    end
  end

  def admin_static_path(conn, path) do
    theme = "/themes/" <> Application.get_env(:xadmin, :theme, "active_admin")
    static_path(conn, "#{theme}#{path}")
  end
end
