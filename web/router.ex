defmodule XAdmin.Router do
  @moduledoc """
  Router macro for XAdmin sites.

  Provides a helper macro for adding up XAdmin routes to your application.

  ## Examples:

      defmodule MyProject.Router do
        use MyProject.Web, :router
        use XAdmin.Router
        ...
        scope "/", MyProject do
          ...
        end

        # setup the XAdmin routes on /admin
        scope "/admin", XAdmin do
          pipe_through :browser
          admin_routes
        end
      end

  """
  use XAdmin.Web, :router

  defmacro __using__(_opts \\ []) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Add XAdmin Routes to your project's router

  Adds the routes required for XAdmin
  """
  defmacro admin_routes(_opts \\ []) do
    quote do
      get "/", AdminController, :dashboard
      get "/login", AdminController,  :login
      post "/login", AdminController,  :login
      get "/logout", AdminController, :logout
      get "/dashboard", AdminController, :dashboard
      get "/page/:page", AdminController, :page
      get "/select_theme/:id", AdminController, :select_theme
      get "/:resource/", AdminResourceController, :index
      get "/:resource/new", AdminResourceController, :new
      get "/:resource/csv", AdminResourceController, :csv
      get "/:resource/:id", AdminResourceController, :show
      get "/:resource/:id/edit", AdminResourceController, :edit
      post "/:resource/", AdminResourceController, :create
      patch "/:resource/:id", AdminResourceController, :update
      put "/:resource/:id", AdminResourceController, :update
      put "/:resource/:id/toggle_attr", AdminResourceController, :toggle_attr
      delete "/:resource/:id", AdminResourceController, :destroy
      post "/:resource/batch_action", AdminResourceController, :batch_action
      put   "/:resource/:id/member/:action", AdminResourceController, :member
      patch "/:resource/:id/member/:action", AdminResourceController, :member
      get "/:resource/collection/:action", AdminResourceController, :collection
      post "/:resource/:id/:association_name/update_positions", AdminAssociationController, :update_positions, as: :admin_association
      post "/:resource/:id/:association_name", AdminAssociationController, :add, as: :admin_association
      get "/:resource/:id/:association_name", AdminAssociationController, :index, as: :admin_association
    end
  end
end
