module GFLoad
  class Formation
    def build_pyramid_triangle(level = 3)
      # ボトムアップで三角型（俵型）ピラミッドを構成
      1.upto(level) do |i|
        1.upto(level - i + 1) do |j|
          name = compose_name(i, j)
          p = GFLoad::Person.new(:name => name); add_person(p)
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
