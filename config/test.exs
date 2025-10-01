import Config
username = System.get_env("DB_USERNAME") || "postgres"
password = System.get_env("DB_PASSWORD") || "postgres"
hostname = System.get_env("DB_HOSTNAME") || "localhost"
port = System.get_env("DB_PORT") || "5432"
database = System.get_env("DB_NAME") || "baule_bio_1_test"

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :baule_bio_1, BauleBio1.Repo,
  username: username,
  password: password,
  hostname: hostname,
  database: "#{database}#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :baule_bio_1, BauleBio1Web.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "L+L6jJbYF/i6a7a0m9y3fEEH7/l6kWodP7NWohTOghFP8jDzfKvmkaEc2dyyqHkA",
  server: false

# In test we don't send emails
config :baule_bio_1, BauleBio1.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
