ExUnit.start()

Code.require_file "./support/schema.exs", __DIR__
Code.require_file "./support/repo.exs", __DIR__
Code.require_file "./support/migrations.exs", __DIR__
Code.require_file "./support/admin_resources.exs", __DIR__
Code.require_file "./support/router.exs", __DIR__
Code.require_file "./support/endpoint.exs", __DIR__
Code.require_file "./support/conn_case.exs", __DIR__
Code.require_file "./support/test_helpers.exs", __DIR__
Code.require_file "./support/view.exs", __DIR__

defmodule XAdmin.RepoSetup do
  use ExUnit.CaseTemplate
end

TestXAdmin.Repo.__adapter__.storage_down TestXAdmin.Repo.config
TestXAdmin.Repo.__adapter__.storage_up TestXAdmin.Repo.config

{:ok, _pid} = TestXAdmin.Repo.start_link
{:ok, _pid} = TestXAdmin.Endpoint.start_link
_ = Ecto.Migrator.up(TestXAdmin.Repo, 0, TestXAdmin.Migrations, log: false)
Process.flag(:trap_exit, true)
Ecto.Adapters.SQL.Sandbox.mode(TestXAdmin.Repo, :manual)

