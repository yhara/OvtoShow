class PresentationChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def select_page
  end

  def send_emo
  end

  def send_comment
  end
end
