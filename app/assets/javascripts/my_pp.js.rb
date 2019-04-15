require 'native'

class MyPP
  def self.pretty_inspect(obj)
    if native?(obj)
      "#<native>"
    else
      obj.pretty_inspect
    end
  end
end

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
    if self.length > 2
      items = [
        MyPP.pretty_inspect(self[0]),
        MyPP.pretty_inspect(self[1]),
        "...",
      ]
    else
      items = self.map{|x| MyPP.pretty_inspect(x)}
    end

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
    items = self.map{|k, v|
      # Dirty hack
      if k == "slides"
        [MyPP.pretty_inspect(k), "..."]
      else
        [MyPP.pretty_inspect(k), MyPP.pretty_inspect(v)]
      end
    }
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
