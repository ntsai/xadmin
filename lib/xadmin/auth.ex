defmodule XAdmin.Auth.Help do
  def auth_module() do
    if module = Application.get_env(:xadmin, :auth) do
      config_plug = Application.get_env(:xadmin, :plug, [])
      config_plug = config_plug ++ [{module, nil}]
      Application.put_env :xadmin, :plug, config_plug
      module
    else
      nil
    end
  end
end

defmodule XAdmin.Auth do
  @moduledoc """
    config :xadmin,
      auth: Xin.XAdmin.Auth

    defmodule Xin.XAdmin.Auth do
      import Plug.Conn
      import Project.Router.Helpers
      alias Project.Endpoint

      def init(default) do
        default
      end

      def call(conn, default) do
        conn
      end

      def login(conn, _params) do
        Map.put conn, :admin_login, true
      end

      def logout(conn, _params) do
        # do something
        conn
      end
    end  
  """

  @auth_module XAdmin.Auth.Help.auth_module

  def login(conn, params) do
    apply(@auth_module, :login, [conn, params])
  end

  def logout(conn, params) do
    apply(@auth_module, :logout, [conn, params])
  end

end
