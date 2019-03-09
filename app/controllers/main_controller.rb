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
    @slides = [
      {
        layout: "title",
        title: "Ovto: Frontend-...",
      },
      {
        layout: "list",
        items: [
          "A",
          "A'",
          "B",
        ]
      }
    ]
  end
end
