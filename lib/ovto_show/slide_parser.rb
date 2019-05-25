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
          children: convert_nodes(nodes)
        }
      }
    end

    private

    def convert_nodes(nodes)
      nodes.map{|x| convert_node(x)}.compact
    end
    alias convert_children convert_nodes

    def convert_node(node)
      case node.type
      when :header
        {
          nodeName: "h#{node.header_level}",
          attributes: {},
          children: convert_children(node)
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
      when :list, :list_item
        tag_name = {list: "ul", list_item: "li"}[node.type]
        {
          nodeName: tag_name,
          attributes: {},
          children: convert_children(node)
        }
      when :paragraph
        children = convert_children(node)
        if children.first.is_a?(String) && children.first.start_with?("~ ")
          {
            nodeName: "div",
            attributes: {class: "presenter-note"},
            children: [children.join("\n")],
          }
        else
          {
            nodeName: "p",
            attributes: {},
            children: children,
          }
        end
      when :text
        node.string_content
      when :softbreak
        nil
      when :image
        {
          nodeName: "img",
          attributes: {src: node.url},
          children: []
        }
      when :code
        {
          nodeName: "code",
          attributes: {},
          children: [node.string_content]
        }
      when :link
        {
          nodeName: "a",
          attributes: {href: node.url},
          children: convert_children(node)
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
