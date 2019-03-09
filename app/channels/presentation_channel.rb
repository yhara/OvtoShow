class PresentationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "the_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_action(data)
    ActionCable.server.broadcast('the_channel', data)
  end

  def select_page(data)
    #PresentationChannel.broadcast_to("the_channel", "hi")
    ActionCable.server.broadcast('the_channel', data.inspect)
  end

  def send_emo
  end

  def send_comment
  end
end
