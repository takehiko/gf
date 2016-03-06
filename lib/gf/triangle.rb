module GF
  class Formation
    def build_pyramid_triangle(lev = 3)
      # ボトムアップで三角型（俵型）ピラミッドを構成
      @level = lev
      1.upto(lev) do |i|
        1.upto(lev - i + 1) do |j|
          name = compose_name(i, j)
          p = GF::Person.new(:name => name); add_person(p)
          if i > 1
            [j, j + 1].each do |j2|
              name2 = compose_name(i - 1, j2)
              p.put_load(@mem[name2], 0.5)
            end
          end
        end
      end
    end
  end
end
