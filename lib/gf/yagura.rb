module GF
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
      @level = 3
      p11 = GF::Person.new(:name => "1.1"); add_person(p11)
      p12 = GF::Person.new(:name => "1.2"); add_person(p12)
      p21 = GF::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p11, 0.3)
      p22 = GF::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p12, 0.3)
      p31 = GF::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.5)
      p31.put_load(p22, 0.5)
    end

    def build_yagura7
      # やぐら(7人技，3段タワー)を構成
      @level = 3
      p111 = GF::Person.new(:name => "1.1.1"); add_person(p111)
      p112 = GF::Person.new(:name => "1.1.2"); add_person(p112)
      p121 = GF::Person.new(:name => "1.2.1"); add_person(p121)
      p122 = GF::Person.new(:name => "1.2.2"); add_person(p122)
      p21 = GF::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p111, 0.15)
      p21.put_load(p112, 0.15)
      p22 = GF::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p121, 0.15)
      p22.put_load(p122, 0.15)
      p31 = GF::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.5)
      p31.put_load(p22, 0.5)
    end

    def build_yagura9
      # やぐら(9人技，天空の城)を構成
      @level = 4
      p111 = GF::Person.new(:name => "1.1.1"); add_person(p111)
      p112 = GF::Person.new(:name => "1.1.2"); add_person(p112)
      p121 = GF::Person.new(:name => "1.2.1"); add_person(p121)
      p122 = GF::Person.new(:name => "1.2.2"); add_person(p122)
      p21 = GF::Person.new(:name => "2.1"); add_person(p21)
      p21.put_load(p111, 0.15)
      p21.put_load(p112, 0.15)
      p22 = GF::Person.new(:name => "2.2"); add_person(p22)
      p22.put_load(p121, 0.15)
      p22.put_load(p122, 0.15)
      p31 = GF::Person.new(:name => "3.1"); add_person(p31)
      p31.put_load(p21, 0.3)
      p31.put_load(p111, 0.35)
      p31.put_load(p112, 0.35)
      p32 = GF::Person.new(:name => "3.2"); add_person(p32)
      p32.put_load(p22, 0.3)
      p32.put_load(p121, 0.35)
      p32.put_load(p122, 0.35)
      p41 = GF::Person.new(:name => "4.1"); add_person(p41)
      p41.put_load(p31, 0.5)
      p41.put_load(p32, 0.5)
    end

    def build_yagura21
      # やぐら(21人技，インフィニティー)を構成
      @level = 5
      p111 = GF::Person.new(:name => "1.1.1"); add_person(p111)
      p112 = GF::Person.new(:name => "1.1.2"); add_person(p112)
      p113 = GF::Person.new(:name => "1.1.3"); add_person(p113)
      p114 = GF::Person.new(:name => "1.1.4"); add_person(p114)
      p121 = GF::Person.new(:name => "1.2.1"); add_person(p121)
      p122 = GF::Person.new(:name => "1.2.2"); add_person(p122)
      p123 = GF::Person.new(:name => "1.2.3"); add_person(p123)
      p124 = GF::Person.new(:name => "1.2.4"); add_person(p124)
      p211 = GF::Person.new(:name => "2.1.1"); add_person(p211)
      p211.put_load(p111, 0.15)
      p211.put_load(p112, 0.15)
      p212 = GF::Person.new(:name => "2.1.2"); add_person(p212)
      p212.put_load(p112, 0.15)
      p212.put_load(p113, 0.15)
      p213 = GF::Person.new(:name => "2.1.3"); add_person(p213)
      p213.put_load(p113, 0.15)
      p213.put_load(p114, 0.15)
      p221 = GF::Person.new(:name => "2.2.1"); add_person(p221)
      p221.put_load(p121, 0.15)
      p221.put_load(p122, 0.15)
      p222 = GF::Person.new(:name => "2.2.2"); add_person(p222)
      p222.put_load(p122, 0.15)
      p222.put_load(p123, 0.15)
      p223 = GF::Person.new(:name => "2.2.3"); add_person(p223)
      p223.put_load(p123, 0.15)
      p223.put_load(p124, 0.15)
      p311 = GF::Person.new(:name => "3.1.1"); add_person(p311)
      p311.put_load(p211, 0.15)
      p311.put_load(p212, 0.15)
      p311.put_load(p111, 0.3)
      p311.put_load(p112, 0.4)
      p312 = GF::Person.new(:name => "3.1.2"); add_person(p312)
      p312.put_load(p212, 0.15)
      p312.put_load(p213, 0.15)
      p312.put_load(p113, 0.4)
      p312.put_load(p114, 0.3)
      p321 = GF::Person.new(:name => "3.2.1"); add_person(p321)
      p321.put_load(p221, 0.15)
      p321.put_load(p222, 0.15)
      p321.put_load(p121, 0.3)
      p321.put_load(p122, 0.4)
      p322 = GF::Person.new(:name => "3.2.2"); add_person(p322)
      p322.put_load(p222, 0.15)
      p322.put_load(p223, 0.15)
      p322.put_load(p123, 0.4)
      p322.put_load(p124, 0.3)
      p41 = GF::Person.new(:name => "4.1"); add_person(p41)
      p41.put_load(p311, 0.15)
      p41.put_load(p312, 0.15)
      p41.put_load(p211, 0.175)
      p41.put_load(p212, 0.35)
      p41.put_load(p213, 0.175)
      p42 = GF::Person.new(:name => "4.2"); add_person(p42)
      p42.put_load(p321, 0.15)
      p42.put_load(p322, 0.15)
      p42.put_load(p221, 0.175)
      p42.put_load(p222, 0.35)
      p42.put_load(p223, 0.175)
      p51 = GF::Person.new(:name => "5.1"); add_person(p51)
      p51.put_load(p41, 0.5)
      p51.put_load(p42, 0.5)
    end

    def set_yagura_plc(*args)
      if args.length > 1
        set_yagura_weight(args)
      end
      arg = args.first
      case arg.to_s
      when /,/
        set_yagura_weight(arg.split(/,/))
      when "4"
        place_yagura_weight4
      end
    end

    def set_yagura_weight(weight_a)
      raise "fewer persons" if weight_a.size < self.size
      mem_a = @mem.keys.sort_by {|key| key}
      mem_a.each do |name|
        @mem[name].weight = weight_a.pop.to_i
      end
    end

    def place_yagura_weight4
      set_yagura_weight(sample(@mem.size, 2.0).sort)
    end
  end
end
