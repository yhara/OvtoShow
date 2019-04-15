class PresentationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "the_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_action(data)
    # TODO: whitelist?
    ActionCable.server.broadcast('the_channel', data)
  end
end
