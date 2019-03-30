require 'commonmarker'

module OvtoShow
  class SlideParser
    def parse(str)
      doc = CommonMarker.render_doc(
        str,
        :UNSAFE  # Allow raw/custom HTML and unsafe links.
      )
      pages = doc.each.slice_before{|x| x.type == :header}
                      .select{|x| x.first.type == :header}
      return pages.map{|nodes|
        { 
          nodeName: "div",
          attributes: {},
          children: nodes.map{|x| convert_node(x)}.compact,
        }
      }
    end

    private

    def convert_node(node)
      case node.type
      when :header
        {
          nodeName: "h#{node.header_level}",
          attributes: {},
          children: [node.first_child&.string_content],
        }
      when :code_block
        {
          nodeName: "pre",
          attributes: {lang: node.fence_info},
          children: [{
            nodeName: "code",
            attributes: {},
            children: node.string_content,
          }],
        }
      when :list, :list_item, :paragraph
        tag_name = {list: "ul", list_item: "li", paragraph: "p"}[node.type]
        {
          nodeName: tag_name,
          attributes: {},
          children: node.map{|node| convert_node(node)}.compact,
        }
      when :text
        str = node.string_content
        str.start_with?('~ ') ? nil : str
      when :softbreak
        nil
      when :image
        {
          nodeName: "img",
          attributes: {src: node.url},
          children: []
        }
      else
        node
      end
    end
  end
end

if $0 == __FILE__
  pp OvtoShow::SlideParser.new.parse(File.read('data/slide.txt'))
end
