defmodule XAdmin.QueryTest do
  use ExUnit.Case
  require Logger
  import TestXAdmin.TestHelpers

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestXAdmin.Repo)
  end

  test "run_query with resource with non default primary key" do
    insert_noid name: "query1"
    query_opts = %{all: [preload: []]}
    res = XAdmin.Query.run_query(TestXAdmin.Noid,  TestXAdmin.Repo, %TestXAdmin.XAdmin.Noid{},
      :show, "query1", query_opts)
    |> XAdmin.Query.execute_query(TestXAdmin.Repo, :show, "query1")
    assert res.name == "query1"
  end

end
