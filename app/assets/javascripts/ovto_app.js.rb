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
    item :rotation, default: 0.0
    item :rotation_interval_id, default: nil
    item :show_state, default: false
    item :page_break, default: true
    item :emos, default: []
    item :show_emo_buttons, default: false

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
      when "a"
        actions.first_page()
      when "z"
        actions.last_page()
      when "r"
        actions.reload_slides()
      when "s"
        actions.toggle_show_state()
      when "x"
        actions.toggle_rotation()
      when "c"
        actions.reset_rotation()
      when "b"
        actions.toggle_page_break()
      when "e"
        actions.toggle_emo_buttons()
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

    def toggle_show_state
      return {show_state: !state.show_state}
    end

    def first_page
      actions.change_page(to: 0)
    end

    def last_page
      actions.change_page(to: state.slides.length)
    end

    def next_page
      actions.change_page(diff: +1)
    end

    def prev_page
      actions.change_page(diff: -1)
    end

    def change_page(to: nil, diff: nil)
      if state.presenter_mode? || state.screen_mode?
        actions.change_presenter_page(to: to, diff: diff)
      else
        actions.change_my_page(to: to, diff: diff)
      end
    end

    def change_presenter_page(to: nil, diff: nil)
      to ||= state.presenter_page + diff
      actions.update_presenter_page(page: to.clamp(0, state.slides.length-1))
    end

    def update_presenter_page(page:)
      `App.presentation.send_action("set_presenter_page", {page: #{page}})`
      actions.set_presenter_page(page: page)
    end

    def set_presenter_page(page:)
      return {presenter_page: page}
    end

    def change_my_page(to: nil, diff: nil)
      to ||= state.my_page + diff
      return {my_page: to.clamp(0, state.slides.length-1)}
    end

    def reload_slides
      Ovto.fetch('/slides.json').then {|json|
        actions.set_slides(slides: json)
      }.fail {|e|
        console.log("get_slides", e)
      }
    end

    def rotate
      return {rotation: state.rotation + 1}
    end

    def toggle_rotation
      if state.rotation_interval_id
        `clearInterval(#{state.rotation_interval_id})`
        return {rotation_interval_id: nil}
      else
        id = `setInterval(function(){
          #{actions.rotate}
        }, 10)`
        return {rotation_interval_id: id}
      end
    end

    def reset_rotation
      return {rotation: 0.0}
    end

    def toggle_page_break
      return {page_break: !state.page_break}
    end

    def toggle_emo_buttons
      return {show_emo_buttons: !state.show_emo_buttons}
    end

    def send_emo(str:)
      `App.presentation.send_action("receive_emo", {str: #{str}})`
      nil
    end

    def receive_emo(str:)
      new_emos = state.emos.dup
      new_emos.push({str: str, key: Time.new.to_f})
      new_emos.shift if new_emos.length > 5
      return {emos: new_emos}
    end
  end

  class MainComponent < Ovto::Component
    def render
      o '.MainComponent' do
        if state.print_mode?
          o AllSlides
        else
          o StateInspector if state.show_state
          o Emos unless state.print_mode?
          o EmoButtons if state.show_emo_buttons
          o PageCount if state.presenter_mode?
          o PageControl unless state.screen_mode? || state.print_mode?
          o MySlide if state.atendee_mode?
          o Screen
          if state.hide_presenter_note?
            o "style", ".presenter-note{ display: none; }"
          end
        end
      end
    end

    class AllSlides < Ovto::Component
      def render
        o '.AllSlides' do
          state.slides.each do |slide|
            o PrintSlide, slide: slide
          end
        end
      end
    end

    class PrintSlide < Ovto::Component
      def render(slide:)
        style = {
          border: "1px solid black",
        }
        style['page-break-after'] = :always if state.page_break
        o '.PrintSlide', {style: style} do
          o SlideContent, slide: slide
        end
      end
    end

    class StateInspector < Ovto::Component
      def render
        o '.StateInspector', style: {
          position: :fixed,
          top: 0,
          left: 0,
          bottom: 0, 'overflow-y': :auto, # Make it scrollable
          background: "#333",
          color: "#fff",
          opacity: 0.7,
          "z-index": 100, 
        } do
          o 'pre', state.pretty_inspect
        end
      end
    end

    class Screen < Ovto::Component
      def render
        o '.Screen', style: {border: "none"} do
          o SlideContent, slide: state.get_slide(state.presenter_page)
        end
      end
    end

    class MySlide < Ovto::Component
      def render
        style = {
          border: "1px solid black",
          background: "#eee",
        }
        o '.MySlide', {style: style} do
          o SlideContent, slide: state.get_slide(state.my_page)
        end
      end
    end

    class SlideContent < Ovto::Component
      def render(slide:)
        # Inject js VDOM obj
        o '.SlideContent', {
          style: {transform: "rotate(#{state.rotation}deg)"}
        }, slide.to_n
      end
    end

    class PageControl < Ovto::Component
      def render
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

    class PageCount < Ovto::Component
      def render
        o '.PageCount' do
          "#{state.presenter_page+1}/#{state.slides.count}"
        end
      end
    end

    class EmoButtons < Ovto::Component
      def render
        o '.EmoButtons' do
          (0x1F600..0x1F609).each do |c|
            str = `String.fromCodePoint(c)`
            o 'input', {
              type: 'button',
              value: str,
              onclick: ->{ actions.send_emo(str: str) }
            }
          end
        end
      end
    end

    class Emos < Ovto::Component
      def render
        o '.Emos', {key: 1} do
          state.emos.each do |item|
            o 'span', {
              key: item[:key],
              style: {
                position: :fixed,
                top: "#{rand(600)}px",
                left: "#{rand(600)}px",
                'font-size': :normal,
                transition: 'all 1000ms 0s ease',
                'z-index': -1,
              },
              oncreate: ->(elm){
                console.log("created", item[:key], elm);
                %x{
                  setTimeout(function(){
                    elm.style['font-size'] = '300px';
                    elm.style['opacity'] = '0';
                  }, 100);
                }
              }
            }, item[:str]
          end
        end
      end
    end
  end
end

#Ovto.debug_trace = true
