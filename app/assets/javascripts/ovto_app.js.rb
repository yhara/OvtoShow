require 'ovto'
require 'pp'
require 'singleton'

class OvtoApp < Ovto::App
  include Singleton

  class State < Ovto::State
    item :page, default: 1
    item :presenter_page, default: 1
    item :mode, default: nil

    def presenter?; self.mode == "presenter"; end
  end

  class Actions < Ovto::Actions
    # - mode: "screen", "presenter", "atendee"
    def set_mode(state:, mode:)
      p mode
      return {mode: mode}
    end

    def prev_page(state:)
      actions.select_page(page: state.page - 1)
      nil
    end

    def next_page(state:)
      actions.select_page(page: state.page + 1)
      nil
    end

    def select_page(page:)
      `App.presentation.send_action("set_presenter_page", {page: #{page}})`
      return {page: page}
    end

    def set_presenter_page(page:)
      return {presenter_page: page}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o '.MainComponent' do
        o 'pre', state.pretty_inspect
        o PageControl if state.presenter?
      end
    end

    class PageControl < Ovto::Component
      def render(state:)
        o '.PageControl' do
          o 'input', {
            type: 'button',
            value: '<',
            onclick: ->{ actions.prev_page() }
          }
          o 'input', {
            type: 'button',
            value: '>',
            onclick: ->{ actions.next_page() }
          }
        end
      end
    end
  end
end
