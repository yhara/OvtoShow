require 'ovto'
require 'singleton'
require 'my_pp'

class OvtoApp < Ovto::App
  include Singleton

  def self.slides
    `window.Opal.OvtoApp.slides`
  end

  def run(*args)
    super
    %x{
      document.addEventListener('keydown', function(e) {
        #{actions.on_keydown(event: `e`)}
      });
    }
  end

  class State < Ovto::State
    item :presenter_page, default: 0
    item :my_page, default: 0
    item :mode, default: nil

    def presenter?; self.mode == "presenter"; end
    def screen?; self.mode == "screen"; end
    def atendee?; self.mode == "atendee"; end

    def get_slide(page)
      `window.Opal.OvtoApp.slides[page]`
    end
  end

  class Actions < Ovto::Actions
    def on_keydown(event:)
      case event.JS['key']
      when "ArrowRight"
        actions.next_page()
      when "ArrowLeft"
        actions.prev_page()
      end
      nil
    end

    # - mode: "screen", "presenter", "atendee"
    def set_mode(mode:)
      return {mode: mode}
    end

    def next_page(state:)
      state.presenter? ? actions.presenter_next_page : actions.my_next_page
    end

    def prev_page(state:)
      state.presenter? ? actions.presenter_prev_page : actions.my_prev_page
    end

    def presenter_prev_page(state:)
      if state.presenter_page > 0
        actions.update_presenter_page(page: state.presenter_page - 1)
      end
    end

    def presenter_next_page(state:)
      if state.presenter_page < (OvtoApp.slides.length-1)
        actions.update_presenter_page(page: state.presenter_page + 1)
      end
    end

    def update_presenter_page(page:)
      `App.presentation.send_action("set_presenter_page", {page: #{page}})`
      actions.set_presenter_page(page: page)
    end

    def set_presenter_page(page:)
      return {presenter_page: page}
    end

    def my_prev_page(state:)
      if state.my_page > 0
        {my_page: state.my_page - 1}
      else
        nil
      end
    end

    def my_next_page(state:)
      if state.my_page < (OvtoApp.slides.length-1)
        {my_page: state.my_page + 1}
      else
        nil
      end
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o '.MainComponent' do
        o StateInspector
        o PageControl unless state.screen?
        o MySlide if state.atendee?
        o Screen
      end
    end

    class StateInspector < Ovto::Component
      def render(state:)
        o '.StateInspector', style: {
          position: :fixed,
          top: 0,
          left: 0,
          bottom: 0, 'overflow-y': :auto, # Make it scrollable
        } do
          o 'pre', state.pretty_inspect
        end
      end
    end

    class Screen < Ovto::Component
      def render(state:)
        o '.Screen', style: {border: "1px solid black"} do
          o Slide, slide: state.get_slide(state.presenter_page)
        end
      end
    end

    class Slide < Ovto::Component
      def render(slide:)
        # Inject js VDOM obj
        o '.Slide', slide
      end
    end

    class MySlide < Ovto::Component
      def render(state:)
        style = {
          border: "1px solid black",
          background: "#eee",
        }
        # Inject js VDOM obj
        o '.MySlide', {style: style}, state.get_slide(state.my_page)
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

#Ovto.debug_trace = true
