# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :wechat_demo, WeChatDemoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: WeChatDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WeChatDemo.PubSub,
  live_view: [signing_salt: "ImXlDqqT"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# for WeChat

host = "https://wx.example.com"
oauth2_env_callbacks = %{"dev" => "http://127.0.0.1:4000"}

client_settings = [
  hub_springboard_url: "#{host}/wx/:app/:env/cb/",
  oauth2_callbacks: oauth2_env_callbacks
]

work_client_settings = [
  hub_springboard_url: "#{host}/wxw/:app/:agent/:env/cb/",
  oauth2_callbacks: oauth2_env_callbacks
]

config :wechat,
  check_token_for_clients: [WeChatDemo.Client.Normal, WeChatDemo.Client.Mini],
  refresh_settings: [
    WeChatDemo.Client.Normal,
    WeChatDemo.Client.Mini,
    WeChatDemo.Client.Work
  ],
  clients: %{
    WeChatDemo.Client.Normal => client_settings,
    WeChatDemo.Client.Mini => client_settings,
    WeChatDemo.Client.Work => [all: work_client_settings]
  }

config :wechat, WeChat.Storage.HttpForHubClient,
  hub_base_url: "#{host}/hub/expose",
  username: "hello",
  password: "000999"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
