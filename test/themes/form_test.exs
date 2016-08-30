defmodule XAdmin.ThemeFormTest do
  use ExUnit.Case
  alias XAdmin.Theme.{ActiveAdmin, AdminLte2}
  alias TestXAdmin.{Repo, PhoneNumber}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestXAdmin.Repo)
    conn = Plug.Conn.assign(%Plug.Conn{}, :theme, XAdmin.Theme.AdminLte2)
    |> struct(params: %{})
    {:ok, conn: conn}
  end

  test "AdminLte2 theme_build_has_many_fieldset", %{conn: conn} do
    pn = Repo.insert! PhoneNumber.changeset(%PhoneNumber{}, %{label: "Home Phone", number: "5555555555"})
    fields = build_fields pn

    {inx, html} = AdminLte2.Form.theme_build_has_many_fieldset(conn, pn, fields, 0, "contact_phone_numbers_attributes_0",
      :phone_numbers, "phone_numbers_attributes", "contact", nil)

    assert inx == 0

    assert Floki.find(html, "div div h3") |> Floki.text == "Phone Number"

  end

  test "ActiveAdmin theme_build_has_many_fieldset", %{conn: conn} do
    pn = Repo.insert! PhoneNumber.changeset(%PhoneNumber{}, %{label: "Home Phone", number: "5555555555"})
    fields = build_fields pn

    {inx, html} = ActiveAdmin.Form.theme_build_has_many_fieldset(conn, pn, fields, 0, "contact_phone_numbers_attributes_0",
      :phone_numbers, "phone_numbers_attributes", "contact", nil)

    assert inx == 0

    assert Floki.find(html, "fieldset ol h3") |> Floki.text == "Phone Number"
  end


  ################
  # Helpers

  defp build_fields(resource) do
    [
      %{
        name: :label, resource: resource, type: :input,
        opts: %{collection: PhoneNumber.labels},
      },
      %{name: :number, opts: %{}, resource: resource, type: :input}
    ]
  end
end
