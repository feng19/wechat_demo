defmodule WeChatDemo.Client.Normal do
  @moduledoc """
  公众号 - 测试号

  [测试号](http://mp.weixin.qq.com/debug/cgi-bin/sandboxinfo?action=showinfo&t=sandbox/index)
  """
  use WeChat,
    appid: "your-appid",
    appsecret: "your-app-secret",
    token: "your-token",
    encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG",
    server_role: :runtime_env,
    storage: :runtime_env
end
