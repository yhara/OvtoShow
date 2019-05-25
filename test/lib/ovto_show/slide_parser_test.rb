require 'test_helper'
require 'ovto_show/slide_parser'

class SlideParserTest < ActiveSupport::TestCase
  setup do
    @parser = OvtoShow::SlideParser.new
  end

  test "inline" do
    slide = @parser.parse(<<~EOD)
      # `E=MC^2`
    EOD
    expected = [
      {
        nodeName: "div",
        attributes: {},
        children: [
          {
            nodeName: "h1",
            attributes: {},
            children: [
              {
                nodeName: "code",
                attributes: {},
                children: ["E=MC^2"]
              }
            ]
          }
        ]
      }
    ]
    assert_equal expected, slide
  end

  test "link" do
    slide = @parser.parse(<<~EOD)
      # [Ruby](https://www.ruby-lang.org)
    EOD
    expected = [
      {
        nodeName: "div",
        attributes: {},
        children: [
          {
            nodeName: "h1",
            attributes: {},
            children: [
              {
                nodeName: "a",
                attributes: {href: "https://www.ruby-lang.org"},
                children: ["Ruby"]
              }
            ]
          }
        ]
      }
    ]
    assert_equal expected, slide
  end
end
