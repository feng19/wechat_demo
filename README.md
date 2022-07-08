# WeChatDemo

[WeChat SDK 使用指南](https://feng19.com/2022/07/08/wechat_for_elixir_usage/) 配套代码

## 建立 project

```shell
mix phx.new wechat_demo --no-ecto --no-gettext --no-dashboard --no-mailer
```

## 构建流程

1. 修改 [`mix.exs`](mix.exs)，增加依赖

  ```elixir
  defp deps do
    [
      ...,
      {:saxy, "~> 1.4"},
      {:wechat, "~> 0.10", hex: :wechat_sdk}
    ]
  end
  ```

2. 增加 clients
  - 公众号 [`Client.Normal`](lib/wechat_demo/client/normal.ex)
  - 小程序 [`Client.Mini`](lib/wechat_demo/client/mini.ex)
  - 企业微信 [`Client.Work`](lib/wechat_demo/client/work.ex)

3. 增加文件 [`WeChatDemo.WeChatEvent`](lib/wechat_demo/wechat_event.ex)
4. 修改 [`router.ex`](lib/wechat_demo_web/router.ex)，增加下面代码

  ```elixir
  clients = [WeChatDemo.Client.Normal, WeChatDemo.Client.Mini, WeChatDemo.Client.Work]

  pipeline :wechat_event do
    plug :accepts, ["html", "json"]
  end

  pipeline :oauth2_checker do
    plug WeChat.Plug.OAuth2Checker, clients: clients
  end

  if Application.compile_env(:wechat, :server_role) == :hub do
    pipeline :exposer_auth do
      import Plug.BasicAuth, warn: false

      opts =
        Application.compile_env(:wechat, WeChat.Storage.HttpForHubClient)
        |> Keyword.take([:username, :password])

      plug :basic_auth, opts
    end

    scope "/hub/expose", WeChat.Plug do
      pipe_through :exposer_auth
      get "/:store_id/:store_key", HubExposer, clients: clients
    end
  end

  scope "/wx/:app", WeChat.Plug do
    get "/:env/cb/*callback_path", HubSpringboard,
        clients: [WeChatDemo.Client.Normal, WeChatDemo.Client.Mini]

    scope "/event" do
      pipe_through :wechat_event
      forward "/", EventHandler, event_handler: &WeChatDemo.WeChatEvent.handle_event/3
    end
  end

  # work
  scope "/wxw/:app/:agent", WeChat.Plug do
    get "/:env/cb/*callback_path", HubSpringboard, clients: [WeChatDemo.Client.Work]

    scope "/event" do
      pipe_through :wechat_event
      forward "/", WorkEventHandler, event_handler: &WeChatDemo.WeChatEvent.handle_work_event/4
    end
  end

  scope "/hello/:app", WeChatDemoWeb do
    pipe_through [:oauth2_checker, :browser]
    get "/", PageController, :index
    get "/:agent/:qr", PageController, :index
    get "/:agent", PageController, :index
  end
  ```

5. 修改 [`config.exs`](config/config.exs)，增加下面配置

  ```elixir
  host = "https://wx.example.com"
  oauth2_callbacks = %{"dev" => "http://127.0.0.1:4000"}

  client_settings = [
    hub_springboard_url: "#{host}/wx/:app/:env/cb/",
    oauth2_callbacks: oauth2_callbacks
  ]

  work_client_settings = [
    hub_springboard_url: "#{host}/wxw/:app/:agent/:env/cb/",
    oauth2_callbacks: oauth2_callbacks
  ]

  config :wechat,
    refresh_settings: [
      WeChatDemo.Client.Normal,
      WeChatDemo.Client.Mini,
      WeChatDemo.Client.Work
    ],
    clients: [
      {WeChatDemo.Client.Normal, client_settings},
      {WeChatDemo.Client.Mini, client_settings},
      {WeChatDemo.Client.Work, all: work_client_settings}
    ]

  config :wechat, WeChat.Storage.HttpForHubClient,
    hub_base_url: "#{host}/hub/expose",
    username: "hello",
    password: "000999"
  ```

6. 修改 [`prod.exs`](config/prod.exs), 增加下面配置

  ```elixir
  config :wechat,
    server_role: :hub,
    storage: WeChat.Storage.File
  ```