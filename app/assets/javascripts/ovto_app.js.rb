require 'ovto'

class OvtoApp < Ovto::App
  class State < Ovto::State

  end

  class Actions < Ovto::Actions

  end

  class MainComponent < Ovto::Component
    def render(state:)
      o 'h1', "HELLO!"
    end
  end
end
