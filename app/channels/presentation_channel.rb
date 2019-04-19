class PresentationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "the_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  ALLOWED_ACTIONS = %w(receive_emo)
  ADMIN_ONLY_ACTIONS = %w(set_presenter_page)
  def send_action(data)
    action_name = data['ovto_action']
    if ALLOWED_ACTIONS.include?(action_name) ||
        (ADMIN_ONLY_ACTIONS.include?(action_name) && user)
      ActionCable.server.broadcast('the_channel', data)
    end
  end
end
