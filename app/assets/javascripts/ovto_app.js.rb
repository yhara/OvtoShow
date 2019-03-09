require 'ovto'
require 'pp'
require 'singleton'

class OvtoApp < Ovto::App
  include Singleton

  def run(*args)
    super
    %x{
      document.addEventListener('keydown', function(e) {
        #{actions.on_keydown(event: `e`)}
      });
    }
  end

  class State < Ovto::State
    item :presenter_page, default: 1
    item :mode, default: nil
    item :slides, default: nil

    def presenter?; self.mode == "presenter"; end

    def slide
      self.slides[self.presenter_page-1]
    end
  end

  class Actions < Ovto::Actions
    def on_keydown(event:)
      case event.JS['key']
      when "ArrowRight"
        actions.presenter_next_page()
      when "ArrowLeft"
        actions.presenter_prev_page()
      end
      nil
    end

    # - mode: "screen", "presenter", "atendee"
    def set_mode(mode:)
      p mode
      return {mode: mode}
    end

    def set_slides(slides:)
      return {slides: slides}
    end

    def presenter_prev_page(state:)
      actions.update_presenter_page(page: state.presenter_page - 1)
      nil
    end

    def presenter_next_page(state:)
      actions.update_presenter_page(page: state.presenter_page + 1)
      nil
    end

    def update_presenter_page(page:)
      `App.presentation.send_action("set_presenter_page", {page: #{page}})`
      actions.set_presenter_page(page: page)
      nil
    end

    def set_presenter_page(page:)
      return {presenter_page: page}
    end
  end

  class MainComponent < Ovto::Component
    def render(state:)
      o '.MainComponent' do
        o 'div', state.pretty_inspect
        o PageControl if state.presenter?
        o Screen
      end
    end

    class Screen < Ovto::Component
      def render(state:)
        slide = state.slide
        o '.Screen', style: {border: "1px solid black"} do
          case slide['layout']
          when 'title'
            o TitleSlide, slide: slide
          when 'list'
            o ListSlide, slide: slide
          else 
            raise "unknown layout: #{slide['layout']}" 
          end
        end
      end
    end

    class TitleSlide < Ovto::Component
      def render(slide:)
        o '.TitleSlide' do
          o "h1", slide['title']
        end
      end
    end

    class ListSlide < Ovto::Component
      def render(slide:)
        o '.ListSlide' do
          o "ul" do
            slide['items'].each do |line|
              o "li", {
                style: {"font-size" => "10vh"},
              }, line
            end
          end
        end
      end
    end

    class PageControl < Ovto::Component
      def render(state:)
        o '.PageControl' do
          o 'input', {
            type: 'button',
            value: '<',
            onclick: ->{ actions.presenter_prev_page() }
          }
          o 'input', {
            type: 'button',
            value: '>',
            onclick: ->{ actions.presenter_next_page() }
          }
        end
      end
    end
  end
end
