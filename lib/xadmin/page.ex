defmodule XAdmin.Page do
  @moduledoc """
  Define pages in XAdmin that don't render models, like a dashboard
  page.

  """

  import XAdmin.Theme.Helpers

  defmacro __using__(_) do
    quote do
      import XAdmin.Form, except: [content: 1]
      import unquote(__MODULE__)
    end
  end


  @doc """
  Display contents on a page. Use Xain markup to create the page.

  ## Examples

      register_page "Dashboard" do
        menu priority: 1, label: "Dashboard"
        content do
          columns do
            column do
              panel "Recent Orders" do
                Repo.all Order.complete(5)
                |> table_for do
                  column "State", fn(o) -> status_tag Order.state(o) end
                  column "Customer", fn(o) ->
                    a o.user.email, href: "/admin/users/\#{o.user.id}"
                  end
                  column "Total", fn(o) -> text decimal_to_currency(o.total_price) end
                end
              end
            end
            column do
              panel "Recent Customers" do
                order_by(User, desc: :id)
                |> limit(5)
                |> Repo.all
                |> table_for do
                  column "email", fn(c) -> a c.email, href: "/admin/users/\#{c.id}" end
                end
              end
            end
          end
        end
      end
  """
  defmacro content(_opts \\ [], do: block) do
    quote location: :keep do
      def page_view(var!(conn)) do
        import Kernel, except: [div: 2, to_string: 1]
        import XAdmin.ViewHelpers
        use Xain
        _ = var!(conn)
        markup safe: true do
          unquote(block)
        end
      end
    end
  end

  @doc """
  Start one or more columns.
  """
  defmacro columns(do: block) do
    quote do
      var!(columns, XAdmin.Show) = []
      var!(columns, XAdmin.Page) = []
      unquote(block)
      cols = var!(columns, XAdmin.Page) |> Enum.reverse
      var!(columns, XAdmin.Page) = []
      theme_module(Page).columns(cols)
    end
  end

  @doc """
  Define a column.
  """
  defmacro column([do: block]) do
    quote do
      html = markup do
        unquote(block)
      end
      var!(columns, XAdmin.Page) = [html | var!(columns, XAdmin.Page)]
    end
  end

end
