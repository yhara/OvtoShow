class Object
  def pretty_inspect
    inspect
  end
end

module Ovto
  class State
    def pretty_inspect
      "#<Ovto::State:#{object_id} " + values.pretty_inspect + ">"
    end
  end
end

class Array
  def pretty_inspect
    items = self.map(&:pretty_inspect)
    total_len = items.map(&:size).inject(0, :+)
    if items.any?{|s| s.include?("\n")} || total_len > 80
      "[\n" +
        items.map{|s|
          s.lines.map{|l| "  #{l}"}.join + ",\n"
        }.join +
      "]"
    else
      "[" + items.join(", ") + "]"
    end
  end
end

class Hash
  def pretty_inspect
    items = self.map{|k, v| [k.pretty_inspect, v.pretty_inspect]}
    total_len = items.map{|k, v| k.size + v.size}.inject(0, :+)
    if items.flatten(1).any?{|s| s.include?("\n")} || total_len > 80
      "{\n" +
        items.map{|k, v| "  #{k} => #{v},\n"}.join +
      "}"
    else
      "{" +
        items.map{|k, v| "#{k} => #{v}"}.join(', ') +
      "}"
    end
  end
end
