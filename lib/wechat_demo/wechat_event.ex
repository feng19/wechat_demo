defmodule WeChatDemo.WeChatEvent do
  require Logger
  import WeChat.Utils, only: [now_unix: 0]
  alias WeChat.{Utils, CustomMessage}
  alias WeChat.ServerMessage.XmlMessage

  # 处理 公众号 & 小程序 推送消息
  def handle_event(_conn, client, message) do
    case client.app_type() do
      :official_account -> handle_official_account_event(client, message)
      :mini_program -> handle_mini_program_event(client, message)
    end
  end

  defp handle_official_account_event(client, message) do
    Logger.info("client: #{inspect(client)} get message: #{inspect(message)}")

    case message do
      # 文本消息
      %{"MsgType" => "text"} ->
        openid = message["FromUserName"]
        timestamp = now_unix()

        reply_text =
          case message["Content"] do
            "openid" ->
              openid

            _ ->
              "Hello!"
          end

        reply_msg = XmlMessage.reply_text(openid, message["ToUserName"], timestamp, reply_text)

        {:reply, reply_msg, timestamp}

      # 订阅消息
      %{"MsgType" => "event", "Event" => "subscribe"} ->
        timestamp = now_unix()

        reply_msg =
          XmlMessage.reply_text(
            message["FromUserName"],
            message["ToUserName"],
            timestamp,
            "非常感谢您的订阅关注"
          )

        {:reply, reply_msg, timestamp}

      _ ->
        :ignore
    end
  end

  defp handle_mini_program_event(client, message) do
    Logger.info("client: #{inspect(client)} get message: #{inspect(message)}")

    case message do
      %{"MsgType" => "text"} ->
        openid = message["FromUserName"]

        case message["Content"] do
          "openid" ->
            CustomMessage.send_text(client, openid, openid)
            :ok

          "客服" ->
            to = message["ToUserName"]

            encoded_json =
              Jason.encode!(%{
                "ToUserName" => openid,
                "FromUserName" => to,
                "CreateTime" => now_unix(),
                "MsgType" => "transfer_customer_service"
              })

            {:reply, encoded_json}

          content ->
            CustomMessage.send_text(client, openid, content)
            :ok
        end

      %{"Event" => "user_enter_tempsession"} ->
        openid = message["FromUserName"]
        CustomMessage.send_text(client, openid, "您好，很高兴为您服务!")
        :ok

      _ ->
        :ok
    end
  end

  # 处理 企业微信 推送消息
  def handle_work_event(_conn, client, agent, message) do
    Logger.info(
      "client: #{inspect(client)}, agent: #{inspect(agent)} get message: #{inspect(message)}"
    )

    :ok
  end
end
