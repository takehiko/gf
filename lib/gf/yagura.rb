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

    def build_yagura7
      # やぐら(7人技，3段タワー)を構成
      p111 = GFLoad::Person.new(:name => "1.1.1"); add_person(p111)
      p112 = GFLoad::Person.new(:name => "1.1.2"); add_person(p112)
      p121 = GFLoad::Person.new(:name => "1.2.1"); add_person(p121)
      p122 = GFLoad::Person.new(:name => "1.2.2"); add_person(p122)
      p21 = GFLoad::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p111, 0.15)
      p21.put_load(p112, 0.15)
      p22 = GFLoad::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p121, 0.15)
      p22.put_load(p122, 0.15)
      p31 = GFLoad::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.5)
      p31.put_load(p22, 0.5)
    end

    def build_yagura9
      # やぐら(9人技，天空の城)を構成
      p111 = GFLoad::Person.new(:name => "1.1.1"); add_person(p111)
      p112 = GFLoad::Person.new(:name => "1.1.2"); add_person(p112)
      p121 = GFLoad::Person.new(:name => "1.2.1"); add_person(p121)
      p122 = GFLoad::Person.new(:name => "1.2.2"); add_person(p122)
      p21 = GFLoad::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p111, 0.15)
      p21.put_load(p112, 0.15)
      p22 = GFLoad::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p121, 0.15)
      p22.put_load(p122, 0.15)
      p31 = GFLoad::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.3)
      p31.put_load(p111, 0.35)
      p31.put_load(p112, 0.35)
      p32 = GFLoad::Person.new(:name => "3.2"); add_person(p32)
      p32.put_load(p22, 0.3)
      p32.put_load(p121, 0.35)
      p32.put_load(p122, 0.35)
      p41 = GFLoad::Person.new(:name => "4.1"); add_person(p41)
      p41.put_load(p31, 0.5)
      p41.put_load(p32, 0.5)
    end

    def set_yagura_weight(weight_a)
      mem_a = @mem.keys.sort_by {|key| key}
      mem_a.each do |name|
        @mem[name].weight = weight_a.pop
      end
    end

    def place_yagura_weight4
      set_yagura_weight(sample(@mem.size, 2.0).sort)
    end
  end
end
