use Mix.Config

config :xadmin, TestXAdmin.Endpoint,
  http: [port: 4001],
  secret_key_base: "HL0pikQMxNSA58DV3mf26O/eh1e4vaJDmx1qLgqBcnS14gbKu9Xn3x114D+mHYcX",
  server: false

config :xadmin, TestXAdmin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "xadmin_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :xadmin,
  repo: TestXAdmin.Repo,
  module: TestXAdmin,
  modules: [
    TestXAdmin.XAdmin.Dashboard,
    TestXAdmin.XAdmin.Noid,
    TestXAdmin.XAdmin.User,
    TestXAdmin.XAdmin.Product,
    TestXAdmin.XAdmin.Simple,
    TestXAdmin.XAdmin.ModelDisplayName,
    TestXAdmin.XAdmin.DefnDisplayName,
    TestXAdmin.XAdmin.RestrictedEdit
  ]

config :xain,
  quote: "'",
  after_callback: {Phoenix.HTML, :raw}

config :logger, level: :error
