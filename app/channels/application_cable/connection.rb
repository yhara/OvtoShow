module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    def connect
      self.user = User.find_by(id: cookies.encrypted[:user_id])
    end
  end
end
