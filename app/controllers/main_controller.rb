require 'ovto_show/slide_parser'

class MainController < ApplicationController
  skip_before_action :require_login, only: %w(screen atendee print slides)
  before_action :set_slides

  def screen
    render :index
  end

  def presenter
    require_login
    render :index
  end

  def atendee
    render :index
  end

  def print
    render :index
  end

  # 
  # APIs
  #

  def slides
    respond_to do |format|
      format.json
    end
  end

  private

  def set_slides
    @parser ||= OvtoShow::SlideParser.new
    @slides = @parser.parse(File.read("#{Rails.root}/data/slide.txt"))
  end
end
