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
      p11 = GFLoad::Person.new(:name => "1.1"); add_person(p11)
      p12 = GFLoad::Person.new(:name => "1.2"); add_person(p12)
      p21 = GFLoad::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p11, 0.3)
      p22 = GFLoad::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p12, 0.3)
      p31 = GFLoad::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.5)
      p31.put_load(p22, 0.5)
    end
  end
end





