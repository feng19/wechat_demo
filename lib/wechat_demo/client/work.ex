defmodule WeChatDemo.Client.Work do
  use WeChat.Work,
    corp_id: "your-corp_id",
    agents: [
      contacts_agent(
        secret: "your-secret",
        token: "your-token",
        encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG"
      ),
      customer_agent(
        secret: "your-secret",
        token: "your-token",
        encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG"
      ),
      kf_agent(
        secret: "your-secret",
        token: "your-token",
        encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG"
      ),
      agent(1_000_002,
        name: :test,
        secret: "your-secret",
        token: "your-token",
        encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG"
      )
    ],
    server_role: :runtime_env,
    storage: :runtime_env
end
