defmodule XAdmin.Theme.Helpers do
  @moduledoc false
  @default_theme XAdmin.Theme.AdminLte2
  def theme_module(conn, module) do
    Module.concat(conn.assigns.theme, module)
  end
  def theme_module(module) do
    Application.get_env(:xadmin, :theme, @default_theme)
    |> Module.concat(module)
  end

end
