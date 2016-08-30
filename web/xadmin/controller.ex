defmodule XAdmin.Controller do
  @moduledoc false
  def get_registered_by_controller_route!(%Plug.Conn{} = conn, resource_name \\ nil) do
    resource_name = resource_name || conn.params["resource"]
    res = get_registered_by_controller_route(resource_name)
    if res == %{} do
      raise Phoenix.Router.NoRouteError, conn: conn, router: __MODULE__
    else
      res
    end
  end

  def get_registered_by_controller_route(resource_name) do
    Enum.find XAdmin.get_registered, %{}, &(Map.get(&1, :controller_route) == resource_name)
  end

end
