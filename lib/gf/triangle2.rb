module GF
  class Formation
    def build_pyramid_triangle2(lev = 3)
      # ボトムアップで変則三角型（俵型）ピラミッドを構成
      # http://bylines.news.yahoo.co.jp/ryouchida/20160619-00058983/ より:
      # 最下段は四つんばいの状態になり、下から2段目の生徒は、
      # 最下段の生徒の背中に手を乗せて、足は地面につける。つ
      # まり、下から2段目までは立体型の組み方を利用する。それ
      # より上は、通常の俵型の組み方になる。つまり、下から3段
      # 目の生徒は、下から2段目の生徒の上に、四つんばいで乗る。
      # 以降、頂点まで四つんばいで積み重なっていく。
      @level = lev
      1.upto(lev) do |i|
        1.upto(lev - i + 1) do |j|
          name = compose_name(lv(i), j)
          p = GF::Person.new(:name => name); add_person(p)
          if i > 1
            [j, j + 1].each do |j2|
              name2 = compose_name(lv(i - 1), j2)
              p.put_load(@mem[name2], i == 2 ? @default_hand_rate : 0.5)
            end
          end
        end
      end
    end

    def set_triangle2_plc(*args)
      if args.length > 1
        set_triangle2_weight(args)
      end
      arg = args.first
      if String === arg && /,/ =~ arg
        set_triangle2_weight(arg.split(/,/))
      end

      case arg.to_s
      when "1"
        place_triangle2_weight1
      when "4"
        place_triangle2_weight4
      else
        puts "option -m #{args} was ignored."
      end
    end

    def set_triangle2_weight(weight_a)
      raise "fewer persons" if weight_a.size < self.size
      p_a = @mem.values.sort_by {|p| p.load_weight}.reverse
      p_a.each do |p|
        p.weight = weight_a.pop
      end
    end

    def place_triangle2_weight1
      # 土台と2段目以上に分けず，負荷の高いところを体重の重い者に割り当てる
      set_triangle2_weight(sample(size, @opt[:dist]).sort)
    end

    def place_triangle2_weight4
      # 土台と上2段と残りに分ける
      # ただし，@levelが4以上のときは土台は下2段
      h = partition_member(@level > 3 ? 2 : 1)
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
