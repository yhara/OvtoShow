module OvtoShow
  class SlideParser
    def initialize
    end

    def parse(str)
      pages = []
      page = []
      state = :normal
      str.each_line do |line|
        case
        when line.rstrip == "```"
          page << line
          state = (state == :code ? :normal : :code)
        when line.start_with?("#")
          unless state == :code
            # Flush current page
            pages << parse_page(page) unless page.empty?
            page.clear
          end
          page << line
        else
          page << line
        end
      end
      pages << parse_page(page)
      return pages
    end

    private

    def parse_page(lines)
      case lines.first
      when /^# /
        parse_title_page(lines)
      else
        parse_list_page(lines)
      end
    end

    def parse_title_page(lines)
      title_line, *rest = *lines
      title = title_line[/^# (.*)/, 1].strip
      hash = rest.map(&:strip).reject(&:empty?).map{|l|
        l =~ /^- (\w+):(.+)/
        [$1.to_sym, $2.strip]
      }.to_h
      return {
        layout: "title",
        title: title
      }.merge(hash)
    end

    def parse_list_page(lines)
      title_line, *rest = *lines
      title = title_line[/^## (.*)/, 1].strip
      items = rest.map(&:strip).reject(&:empty?).map{|l| l[/^- (.*)/, 1]}
      return {
        layout: "list",
        title: title,
        items: items
      }
    end
  end
end
