defmodule TestXAdmin.XAdmin.Dashboard do
  use XAdmin.Register

  register_page "Dashboard" do
    menu priority: 1, label: "Dashboard"
    content do
      div ".blank_slate_container#dashboard_default_message" do
        span ".blank_slate" do
          span "Welcome to XAdmin. This is the default dashboard page."
          small "To add dashboard sections, checkout 'web/admin/dashboards.ex'"
        end
      end
    end
    sidebar "Test Sidebar" do
      div do
        text "This is a test."
      end
    end
  end
end

defmodule TestXAdmin.XAdmin.Noid do
  use XAdmin.Register

  register_resource TestXAdmin.Noid do
    query do
      %{all: [preload: [:user]]}
    end
  end
end

defmodule TestXAdmin.XAdmin.User do
  use XAdmin.Register

  register_resource TestXAdmin.User do
    filter only: [:name, :email]
    show user do
      panel "No IDs" do
        markup_contents do
          h3 "First table"
        end
        markup_contents do
          p "With some No-ID entries"
        end
        table_for user.noids do
          column "Full name", fn(item) -> text "#{item.name} (#{item.company})" end
        end
        table_for user.noids do
          column "Full name", fn(item) -> text "#{item.name} (#{item.company})" end
        end
        markup_contents do
          h3 "^^ Second table"
        end
      end
    end
    form user do
      inputs "User Details" do
        input user, :name
        input user, :email
      end

      inputs "Roles" do
        inputs :roles, as: :check_boxes, collection: TestXAdmin.Role.all
      end

    end
    query do
      %{all: [preload: [:noids, :roles]]}
    end
  end
end

defmodule TestXAdmin.XAdmin.Product do
  use XAdmin.Register
  alias TestXAdmin.Repo
  alias TestXAdmin.User

  register_resource TestXAdmin.Product do
    controller do
      after_filter :do_after, only: [:create, :update]
      after_filter :after2, only: [:update]
      before_filter :before_both, only: [:create, :update]
      before_filter :before_update, only: [:update]

      def do_after(conn, params, resource, :create) do
        user = Repo.all(User) |> hd
        resource = Product.changeset(resource, %{user_id: user.id})
        |> Repo.update!
        conn = Plug.Conn.assign(conn, :product, resource)
        |> Plug.Conn.assign(:after_create, :yes)
        {conn, params, resource}
      end
      def do_after(conn, _params, _resource, :update) do
        Plug.Conn.assign(conn, :answer, 42)
        |> Plug.Conn.assign(:after_update, :yes)
      end

      def after2(conn, _params, _resource, _) do
        Plug.Conn.assign(conn, :after_update2, :yes)
      end

      def before_both(conn, _) do
        Plug.Conn.assign(conn, :before_both, :yes)
      end
      def before_update(conn, _) do
        Plug.Conn.assign(conn, :before_update, :yes)
      end
    end
  end
end

defmodule TestXAdmin.XAdmin.Simple do
  use XAdmin.Register

  register_resource TestXAdmin.Simple do
  end
end

defmodule TestXAdmin.XAdmin.UUIDSchema do
  use XAdmin.Register

  register_resource TestXAdmin.UUIDSchema do
  end
end

defmodule TestXAdmin.XAdmin.Noprimary do
  use XAdmin.Register

  register_resource TestXAdmin.Noprimary do
  end
end

defmodule TestXAdmin.XAdmin.Contact do
  use XAdmin.Register

  register_resource TestXAdmin.Contact do

    form contact do
      inputs do
        input contact, :first_name
        input contact, :last_name
      end

      inputs "Phone Numbers" do
        has_many contact, :phone_numbers, fn(p) ->
          input p, :label, collection: TestXAdmin.PhoneNumber.labels
          input p, :number
        end
      end
    end
  end
end

defmodule TestXAdmin.XAdmin.ModelDisplayName do
  use XAdmin.Register
  register_resource TestXAdmin.ModelDisplayName do
  end
end

defmodule TestXAdmin.XAdmin.DefnDisplayName do
  use XAdmin.Register
  register_resource TestXAdmin.DefnDisplayName  do
  end
  def display_name(resource) do
    resource.second
  end
end

defmodule TestXAdmin.XAdmin.RestrictedEdit do
  use XAdmin.Register
  register_resource TestXAdmin.Restricted do
    action_items only: [:show]
  end
end

