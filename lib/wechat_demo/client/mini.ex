defmodule WeChatDemo.Client.Mini do
  @moduledoc "小程序"
  use WeChat,
    app_type: :mini_program,
    appid: "your-appid",
    appsecret: "your-app-secret",
    token: "your-token",
    encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG",
    server_role: Application.get_env(:wechat, :server_role, :hub_client),
    storage: Application.get_env(:wechat, :storage, WeChat.Storage.HttpForHubClient)
end
