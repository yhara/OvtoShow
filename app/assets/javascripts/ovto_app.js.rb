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
    item :slides, default: []
    item :presenter_page, default: 0
    item :my_page, default: 0
    item :mode, default: nil
    item :scale, default: 1.0
    item :rotation, default: 0.0
    item :rotation_interval_id, default: nil
    item :show_state, default: false

    def presenter_mode?; self.mode == "presenter"; end
    def screen_mode?; self.mode == "screen"; end
    def atendee_mode?; self.mode == "atendee"; end
    def print_mode?; self.mode == "print"; end

    def hide_presenter_note?
      %w(screen atendee).include?(self.mode)
    end

    def get_slide(page)
      self.slides[page]
    end
  end

  class Actions < Ovto::Actions
    def on_keydown(event:)
      case event.JS['key']
      when "ArrowRight", "j"
        actions.next_page()
      when "ArrowLeft", "k"
        actions.prev_page()
      when "r"
        actions.reload_slides()
#      when "i"
#        actions.change_scale(pt: -0.1)
#      when "o"
#        actions.change_scale(pt: +0.1)
      when "s"
        actions.toggle_show_state()
      when "x"
        actions.toggle_rotation()
      else
        console.log(event.JS['key'])
      end
      nil
    end

    def set_mode(mode:)
      return {mode: mode}
    end

    def set_slides(slides:)
      return {slides: slides}
    end

    def toggle_show_state(state:)
      return {show_state: !state.show_state}
    end

    def next_page(state:)
      (state.presenter_mode? || state.screen_mode?) ? actions.presenter_next_page
                                                   : actions.my_next_page
    end

    def prev_page(state:)
      (state.presenter_mode? || state.screen_mode?) ? actions.presenter_prev_page
                                                   : actions.my_prev_page
    end

    def presenter_prev_page(state:)
      if state.presenter_page > 0
        actions.update_presenter_page(page: state.presenter_page - 1)
      end
    end

    def presenter_next_page(state:)
      if state.presenter_page < (state.slides.length-1)
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
      if state.my_page < (state.slides.length-1)
        {my_page: state.my_page + 1}
      else
        nil
      end
    end

    def reload_slides
      Ovto.fetch('/slides.json').then {|json|
        actions.set_slides(slides: json)
      }.fail {|e|
        console.log("get_slides", e)
      }
    end

    def change_scale(state:, pt:)
      return {scale: state.scale + pt}
    end

    def rotate(state:)
      return {rotation: state.rotation + 1}
    end

    def toggle_rotation(state:)
      if state.rotation_interval_id
        `clearInterval(#{state.rotation_interval_id})`
        return {rotation_interval_id: nil, rotation: 0.0}
      else
        id = `setInterval(function(){
          #{actions.rotate}
        }, 10)`
        return {rotation_interval_id: id}
      end
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o '.MainComponent' do
        if state.print_mode?
          o AllSlides
        else
          o StateInspector if state.show_state
          o PageControl unless state.screen_mode?
          o MySlide if state.atendee_mode?
          o Screen
          if state.hide_presenter_note?
            o "style", ".presenter-note{ display: none; }"
          end
        end
      end
    end

    class AllSlides < Ovto::Component
      def render(state:)
        o '.AllSlides' do
          OvtoApp.slides.each do |slide|
            o PrintSlide, slide: slide
          end
        end
      end
    end

    class PrintSlide < Ovto::Component
      def render(slide:)
        style = {
          border: "1px solid black",
          #'page-break-after': :always,
        }
        o '.PrintSlide', {style: style} do
          o SlideContent, slide: slide
        end
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
          o SlideContent, slide: state.get_slide(state.presenter_page)
        end
      end
    end

    class MySlide < Ovto::Component
      def render(state:)
        style = {
          border: "1px solid black",
          background: "#eee",
        }
        o '.MySlide', {style: style} do
          o SlideContent, state.get_slide(state.my_page)
        end
      end
    end

    class SlideContent < Ovto::Component
      def render(state:, slide:)
        # Inject js VDOM obj
        o '.SlideContent', {
          style: {transform: "rotate(#{state.rotation}deg)"}
        }, slide.to_n
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
