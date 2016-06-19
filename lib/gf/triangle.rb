module GF
  class Formation
    def build_pyramid_triangle(lev = 3)
      # ボトムアップで三角型（俵型）ピラミッドを構成
      @level = lev
      1.upto(lev) do |i|
        1.upto(lev - i + 1) do |j|
          name = compose_name(lv(i), j)
          p = GF::Person.new(:name => name); add_person(p)
          if i > 1
            [j, j + 1].each do |j2|
              name2 = compose_name(lv(i - 1), j2)
              p.put_load(@mem[name2], 0.5)
            end
          end
        end
      end
    end

    def set_triangle_plc(*args)
      if args.length > 1
        set_triangle_weight(args)
      end
      arg = args.first
      if String === arg && /,/ =~ arg
        set_triangle_weight(arg.split(/,/))
      end

      case arg.to_s
      when "4"
        place_triangle_weight4 # place4
      else
        puts "option -m #{args} was ignored."
      end
    end

    def set_triangle_weight(weight_a)
      raise "fewer persons" if weight_a.size < self.size
      mem_a = @mem.keys.sort_by {|key| key}
      mem_a.each do |name|
        @mem[name].weight = weight_a.pop.to_i
      end
    end


    def place_triangle_weight4
      # 土台と上2段と残りに分ける
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
