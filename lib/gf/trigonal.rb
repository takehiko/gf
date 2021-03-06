module GF
  class Formation
    def build_pyramid_trigonal(lev = 4)
      # トップダウンで三角錐型（立体型）ピラミッドを構成
      raise if lev < 3
      @level = lev

      name_top = compose_name(lv(lev), 1, 1)
      p = GF::Person.new(:name => name_top)
      add_person(p)

      name_a = [compose_name(lv(lev - 1), 1, 1), compose_name(lv(lev - 1), 1, 2)]
      name_a.each do |name|
        p = GF::Person.new(:name => name)
        add_person(p)
        @mem[name_top].put_load(p, 0.5)
      end

      until name_a.empty?
        name = name_a.shift
        p = @mem[name]

        i, j, k = decompose_name(name)

        if lv(i) >= 3
          i2 = i - 2 * (@opt[:descend] ? -1 : 1)
          j2 = j + 1
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GF::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, @default_foot_rate)
          end
        end

        if lv(i) >= 2
          i2 = i - 1 * (@opt[:descend] ? -1 : 1)
          j2 = j
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GF::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, @default_hand_rate)
          end
        end
      end
    end

    def set_trigonal_plc(*args)
      if args.length > 1
        set_trigonal_weight(args)
      end
      arg = args.first
      if String === arg && /,/ =~ arg
        set_trigonal_weight(arg.split(/,/))
      end

      case arg.to_s
      when "1"
        place_trigonal_weight1 # place1
      when "3"
        place_trigonal_weight3 # place3
      when "4"
        place_trigonal_weight4 # place4
      when "2"
        place_trigonal_weight2 # place2
      else
        puts "option -m #{args} was ignored."
      end
    end

    def set_trigonal_weight(weight_a)
      raise "fewer persons" if weight_a.size < self.size
      mem_a = @mem.keys.sort_by {|key| key}
      mem_a.each do |name|
        @mem[name].weight = weight_a.pop.to_i
      end
    end

    def place_trigonal_weight1
      # 土台と2段目以上に分けず，負荷の高いところを体重の重い者に割り当てる
      p_a = member.sort_by {|p| p.load_weight}
      w_a = sample(size, @opt[:dist]).sort

      p_a.each_with_index do |p, i|
        w = w_a[i]
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end
    end

    def place_trigonal_weight2
      # 土台と2段目以上に分け，負荷の高いところを体重の重い者に割り当てる
      h = partition_member
      p_a1, p_a2 = h[:foundation], h[:top2level] + h[:interlevel]
      w_a = sample(size, @opt[:dist]).sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      [p_a2, p_a1].each do |p_aa|
        p_aa.each do |p|
          w = w_a.shift
          p.weight = w
          puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
        end
      end
    end

    def place_trigonal_weight3
      # 土台と上2段と残りに分け，残りは総当たり
      # 他の方法と比べて時間がかかるが，結果はplace_trigonal_weight4と同じになる
      h = partition_member
      p_a1, p_a2, p_a3 = h[:foundation], h[:interlevel], h[:top2level]
      w_a = sample(size, @opt[:dist]).sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a3.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      # 上2段
      p_a3.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      # 土台
      p_a1.reverse.each do |p|
        w = w_a.pop
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      if p_a2.length != w_a.length
        raise
      end

      # 残り
      c = c_init = 10000
      min_load = max_load_weight * 2
      min_a = (0...p_a2.length).to_a
      min_a.dup.permutation do |a|
        a.each do |num|
          p_a2[num].weight = w_a[num]
        end

        if min_load > max_load_weight
          min_load = max_load_weight
          min_a = a.dup
          print "!";
        end
        c -= 1
        if c == 0
          print "*";
          c = c_init
        end
      end
      puts
      min_a.each do |num|
        p_a2[num].weight = w_a[num]
        puts "%s : %5.2f kg" % [p_a2[num].name, w_a[num]] if $DEBUG
      end
    end

    def place_trigonal_weight4
      h = partition_member
      p_a1, p_a2, p_a3 = h[:foundation], h[:interlevel], h[:top2level]
      w_a = sample(size, @opt[:dist]).sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a3.map{|p| p.name}.inspect}"
        puts "w_a: #{w_a.inspect}"
      end

      # 上2段
      p_a3.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      # 土台
      p_a1.reverse.each do |p|
        w = w_a.pop
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end

      if p_a2.length != w_a.length
        raise
      end

      # 残り
      p_a2.each do |p|
        w = w_a.shift
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end
    end
  end
end
