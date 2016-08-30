defmodule TestXAdmin.TestHelpers do
  alias TestXAdmin.Repo

  def insert_noid(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "test name",
      description: "test description",
      company: "test company"
    }, attrs)

    TestXAdmin.Noid.changeset(%TestXAdmin.Noid{}, changes)
    |> Repo.insert!()
  end

  def insert_simple(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "test name",
      description: "test description",
    }, attrs)

    TestXAdmin.Simple.changeset(%TestXAdmin.Simple{}, changes)
    |> Repo.insert!()
  end

  def insert_restricted(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "test name",
      description: "test description",
    }, attrs)

    TestXAdmin.Restricted.changeset(%TestXAdmin.Restricted{}, changes)
    |> Repo.insert!()
  end

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "user one",
      email: "userone@example.com"
      }, attrs)
    TestXAdmin.User.changeset(%TestXAdmin.User{}, changes)
    |> Repo.insert!()
  end
end
