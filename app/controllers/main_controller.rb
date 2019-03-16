require 'ovto_show/slide_parser'

class MainController < ApplicationController
  before_action :set_slides

  def screen
    render :index
  end

  def presenter
    render :index
  end

  def atendee
    render :index
  end

  private

  def set_slides
    @parser ||= OvtoShow::SlideParser.new
    @slides = @parser.parse(<<~EOD)
# Ovto: Frontend web framework for Rubyists

- author: Yutaka Hara
- event: RubyKaigi 2019 Fukuoka
- date: 2019/04/19

## Summary

- Ovto is a web framework 
- VirtualDOM + Single state (like react-redux)
- yet you can write apps in Ruby

EOD
  end
end
