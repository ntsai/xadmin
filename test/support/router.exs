defmodule TestXAdmin.Router do
  use XAdmin.Web, :router
  use XAdmin.Router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/admin", XAdmin do
    pipe_through :browser
    admin_routes
  end
end

