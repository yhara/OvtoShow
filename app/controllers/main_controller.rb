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
    @slides = @parser.parse(File.read("#{Rails.root}/data/slide.txt"))
  end
end
