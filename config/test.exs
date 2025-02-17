import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :case_manager, CaseManager.Repo,
  username: System.get_env("POSTGRES_USER") || "dev",
  password: System.get_env("POSTGRES_PASSWORD") || "dev",
  database:
    System.get_env("POSTGRES_DB") || "sarchive_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  types: CaseManager.PostgresTypes

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :case_manager, CaseManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Fnpa7Af4poHa7oaXmmXZrP65Lta+fjwvca4An9s7X/aqBgkW4Z5PEBeMXXVnAnnS",
  server: false

# In test we don't send emails.
config :case_manager, CaseManager.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
