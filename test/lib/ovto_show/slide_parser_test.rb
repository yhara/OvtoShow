require 'test_helper'
require 'ovto_show/slide_parser'

class SlideParserTest < ActiveSupport::TestCase
  setup do
    @parser = OvtoShow::SlideParser.new
  end

  test "pages" do
    slide = @parser.parse(<<~EOD)
      # Presentaion 1
      
      - author: Jhon Doe
      - event: Some Event
      - date: 2018 01 01
      
      ## Page 1
      
      - a
      - b
      - c
    EOD
    expected = [
      {
        layout: "title",
        title: "Presentaion 1",
        author: "Jhon Doe",
        event: "Some Event",
        date: "2018 01 01",
      },
      {
        layout: "list",
        title: "Page 1",
        items: [
          "a",
          "b",
          "c",
        ]
      }
    ]
    assert_equal expected, slide
  end
end
