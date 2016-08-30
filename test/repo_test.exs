defmodule XAdmin.RepoTest do
  use ExUnit.Case
  require Logger
  alias XAdmin.Repo

  defmodule Schema do
    defstruct id: 0, name: nil
  end
  defmodule Schema2 do
    defstruct id: 0, field: nil
  end
  defmodule Cs1 do
    defstruct model: nil, changes: %{}
  end
  defmodule Cs2 do
    defstruct data: nil, changes: %{}
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestXAdmin.Repo)
  end

  test "changeset supports different primary key" do
    params = %{name: "test", description: "desc"}
    cs = %XAdmin.Changeset{changeset: TestXAdmin.Noid.changeset(%TestXAdmin.Noid{}, params)}
    res = Repo.insert(cs)
    assert res.name == "test"
    assert res.description == "desc"
  end

  test "set_dependents ecto2" do
    expected = %XAdmin.RepoTest.Cs2{changes: %{name: "test"},
      data: %XAdmin.RepoTest.Schema{id: 0, name: nil}}
    list = [{"fields", %Cs2{changes: %{field: "f1"}, data: %Schema2{}}}]
    cs = %Cs2{data: %Schema{}, changes: %{name: "test"}}
    cs = Repo.set_dependents(cs, list)
    assert cs == expected
  end

  test "set_dependents ecto1" do
    expected = %XAdmin.RepoTest.Cs1{changes: %{name: "test"},
      model: %XAdmin.RepoTest.Schema{id: 0, name: nil}}
    list = [{"fields", %Cs1{changes: %{field: "f1"}, model: %Schema2{}}}]
    cs = %Cs1{model: %Schema{}, changes: %{name: "test"}}
    cs = Repo.set_dependents(cs, list)
    assert cs == expected
  end

  test "set_changeset_collection ecto2" do
    cs = %XAdmin.Changeset{changeset: %Cs2{data: %Schema{}}}
    fields = [{"id", 1}, {"name", "T"}]
    cs = Repo.set_changeset_collection(fields, cs)
    assert cs.changeset.data.id == 1
    assert cs.changeset.data.name == "T"
  end

  test "set_changeset_collection ecto1" do
    cs = %XAdmin.Changeset{changeset: %Cs1{model: %Schema{}}}
    fields = [{"id", 2}, {"name", "TT"}]
    cs = Repo.set_changeset_collection(fields, cs)
    assert cs.changeset.model.id == 2
    assert cs.changeset.model.name == "TT"
  end

  test "param_stringify_keys" do
    assert Repo.param_stringify_keys(%{one: 1, two: "t"}) == %{"one" => 1, "two" => "t"}
    assert Repo.param_stringify_keys(%{"one" =>  1, "two" => "t"}) == %{"one" => 1, "two" => "t"}
    assert Repo.param_stringify_keys(%{one: 1, two: %{a: 7, b: %{c: 0, d: "tt"}}}) ==
      %{"one" => 1, "two" =>  %{"a" =>  7, "b" => %{"c" =>  0, "d" => "tt"}}}
  end
end
