import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wechat_demo, WeChatDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "kke6BzCsBIimJMfAaI1qBELXLoj23CG7CQaEmRO4y7WBfxzfe1g3km5iozEl9gN+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
