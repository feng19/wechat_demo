import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :wechat_demo, WeChatDemoWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

alias WeChatDemo.Client.{Normal, Mini, Work}
server_role = :hub
storage = WeChat.Storage.File

config :wechat, Normal, server_role: server_role, storage: storage
config :wechat, Mini, server_role: server_role, storage: storage
config :wechat, Work, server_role: server_role, storage: storage