defmodule XAdmin.HelpersTest do
  use ExUnit.Case
  alias XAdmin.Helpers
  alias TestXAdmin.Noid
  alias TestXAdmin.Simple
  use Xain

  test "build_field" do
    res = Helpers.build_field(%Noid{description: "desc"}, %{},
      {:description, %{}}, fn(contents, field_name) ->
        XAdmin.Table.handle_contents(contents, field_name)
      end)
    assert res == ~s(<td class='td-description'>desc</td>)
  end

  test "build_field Actions" do
    resource = %Simple{name: "N", description: "D", id: 1}
    defn = %TestXAdmin.XAdmin.Simple{}
    conn = Plug.Conn.assign(%Plug.Conn{}, :theme, XAdmin.Theme.AdminLte2)
    |> Plug.Conn.assign(:defn, defn)

    expected = "<td class='td-actions'><a href='/admin/simples/1' class='member_link view_link'>View</a>" <>
      "<a href='/admin/simples/1/edit' class='member_link edit_link'>Edit</a>" <>
      "<a href='/admin/simples/1' class='member_link delete_link'" <>
      " data-confirm='Are you sure you want to delete this?'" <>
      " data-remote='true' data-method='delete' rel='nofollow'>Delete</a></td>"

    res = Helpers.build_field(resource, conn, {"Actions", %{fun: fn(res) ->
      XAdmin.Index.build_index_links(conn, res, [:show, :edit, :delete])
    end}},
      fn(contents, field_name) ->
        XAdmin.Table.handle_contents(contents, field_name)
      end)
    assert res == expected
  end

  test "group_by" do
    list = [one: 1, two: 2, two: 3]
    result = Helpers.group_by(list, &(elem(&1,0)))
    assert result[:one] == [one: 1]
    assert result[:two] == [two: 2, two: 3]
  end

  test "group_reduce_by_reverse" do
    list = [one: 1, two: 2, two: 3]
    result = Helpers.group_reduce_by_reverse(list)
    assert result[:one] == [1]
    assert result[:two] == [3,2]
  end

  test "group_reduce_by" do
    list = [one: 1, two: 2, two: 3]
    result = Helpers.group_reduce_by(list)
    assert result[:one] == [1]
    assert result[:two] == [2,3]
    list = [after_filter: {:three, []}, before_filter: {:two, [only: [:update]]},
      before_filter: {:one, [only: [:create, :update]]}]
    result = Helpers.group_reduce_by(list)
    assert result[:before_filter] == [two: [only: [:update]], one: [only: [:create, :update]]]
    assert result[:after_filter] == [three: []]
  end

  test "get_name_field :name" do
    assert Helpers.get_name_field(TestXAdmin.User) == :name
  end
  test "get_name_field :title" do
    assert Helpers.get_name_field(TestXAdmin.Product) == :title
  end
  test "get_name_field not first" do
    assert Helpers.get_name_field(TestXAdmin.Noid) == :name
  end
  test "get_name_field :first string field" do
    assert Helpers.get_name_field(TestXAdmin.PhoneNumber) == :number
  end
  test "display_name name" do
    assert Helpers.display_name(%TestXAdmin.User{name: "test"}) == "test"
  end
  test "display_name first string field" do
    assert Helpers.display_name(%TestXAdmin.PhoneNumber{number: "5555"}) == "5555"
  end
end
