defmodule WeChatDemoWeb.Router do
  use WeChatDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WeChatDemoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

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
end
