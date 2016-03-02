#!/usr/bin/env ruby

module GFLoad
  class Formation
    def build_yagura_by_person(size = 5)
      case size
      when 5
        build_yagura5
      when 7
        build_yagura7
      when 9
        build_yagura9
      when 21
        build_yagura21
      end
    end

    def build_yagura5
      # やぐら(5人技)を構成
      p = GFLoad::Person.new(:name => "1.1"); add_person(p)
      p = GFLoad::Person.new(:name => "1.2"); add_person(p)
      p = GFLoad::Person.new(:name => "2.1"); add_person(p)
      p.put_load(@mem["1.1"], 0.3)
      p = GFLoad::Person.new(:name => "2.2"); add_person(p)
      p.put_load(@mem["1.2"], 0.3)
      p = GFLoad::Person.new(:name => "3.1"); add_person(p)
      p.put_load(@mem["2.1"], 0.5)
      p.put_load(@mem["2.2"], 0.5)
    end
  end
end
