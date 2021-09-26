defmodule WeChatDemoWeb.PageController do
  use WeChatDemoWeb, :controller

  def index(conn, _params) do
    appid = get_session(conn, "appid")
    info = get_session(conn, "access_info") |> inspect()
    render(conn, "index.html", appid: appid, info: info)
  end
end
