# root.rb : Load Calculator for Gymnastic Formation
#   by takehikom

module GF
  module Helper
    SEPARATOR = "."
    SEPARATOR2 = "_"

    def compose_name(*a)
      a.join(SEPARATOR)
    end

    def decompose_name(name)
      name.split(SEPARATOR).map {|item| item.to_i}
    end

    def name_key(name)
      item_a = decompose_name(name)
      # item_a[0] = 9999 - item_a[0]
      s = item_a.map {|num| "%04d" % num}.join
      s
    end

    def sort_name(a)
      a.sort_by {|name| name_key(name)}
    end

    def sort_person(a)
      a.sort_by {|person| name_key(person.name)}
    end

    def change_separator(s)
      s.split(SEPARATOR).join(SEPARATOR2)
    end

    def sample(size, zmax)
      # 分布は，政府統計の総合窓口
      # http://www.e-stat.go.jp/SG1/estat/eStatTopPortal.do
      # の体力・運動能力調査 > 平成２６年度 > 学校段階別体格測定の結果より，
      # 小学校11男子と中学校12男子の体重の平均値・標準偏差をもとにした．
      avg = (37.82 + 43.86) / 2
      sd = Math.sqrt((7.40 ** 2 + 8.31 ** 2) / 2)
      # 小学校11男子のみであれば，以下のコメントを外す
      # avg = 37.82; sd = 7.40
      generate_random_bm(avg, sd, size, zmax)
    end

    def generate_random_bm(avg, sd, size, zmax = 2)
      # ボックス=ミュラー法を用いて，平均avg, 分散sd**2の正規分布から
      # size個の乱数を生成しリストにして返す
      # seedは乱数生成の種
      # zmaxが正のとき，乱数のz値の絶対値がzmaxを超えるものは使用しない
      # zmaxが0のとき，size個のavgからなるリストを返す
      # zmaxが負のとき，値の間引きは行わない

      if zmax == 0
        return [avg] * size
      end

      (1..size).to_a.map do
        begin
          begin
            r1, r2 = rand, rand
          end while r1 == 0.0 || r2 == 0.0
          v = Math.sqrt(-2 * Math.log(r1)) * Math.cos(2 * Math::PI * r2)
          puts "debug: v=#{v}, #{v.abs <= zmax ? 'ok' : 'ng'}" if $DEBUG
        end while v.abs > zmax
        sd * v + avg
      end
    end
  end

  class Formation
    include GF::Helper

    def initialize(h = nil)
      @mem = {} # name => Personインスタンス
      @opt = h || {}
      @level = 0
    end
    attr_accessor :mem, :opt, :level

    def start
      method_plc = nil
      setup_hand_foot

      if @opt.key?(:triangle)
        require_relative "triangle.rb"
        build_pyramid_triangle(@opt[:triangle])
        if @opt[:plc]
          method_plc = :set_triangle_plc
        end
      elsif @opt.key?(:pyramid)
        require_relative "trigonal.rb"
        build_pyramid_trigonal(@opt[:pyramid])
        if @opt[:plc]
          method_plc = :set_trigonal_plc
        end
      elsif @opt.key?(:yagura)
        require_relative "yagura.rb"
        build_yagura_by_person(@opt[:yagura])
        if @opt[:plc]
          method_plc = :set_yagura_plc
        end
      else
        @level = 3
        p11 = GF::Person.new(:name => "1.1"); add_person(p11)
        p12 = GF::Person.new(:name => "1.2"); add_person(p12)
        p13 = GF::Person.new(:name => "1.3"); add_person(p13)
        p21 = GF::Person.new(:name => "2.1"); add_person(p21)
        p21.put_load(p11, 0.5)
        p21.put_load(p12, 0.5)
        p22 = GF::Person.new(:name => "2.2"); add_person(p22)
        p22.put_load(p12, 0.5)
        p22.put_load(p13, 0.5)
        p31 = GF::Person.new(:name => "3.1"); add_person(p31)
        p31.put_load(p21, 0.5)
        p31.put_load(p22, 0.5)
      end

      if method_plc
        send(method_plc, @opt[:plc])
      end

      if @opt[:workbook_name]
        require_relative "excel.rb"
        to_excel
      end

      case @opt[:print]
      when :verbose
        puts to_s
        puts to_s_member
      when :none
       # do nothing
      when :ruby
        puts to_ruby
      when :dot
        puts to_dot
      else
        puts to_s
      end
    end

    def to_s(opt_short = false)
      s = "%d persons, total_weight=%g, max_load=%g" %
        [size, total_weight, max_load_weight]

      return s if opt_short

      sum = summary
      s2 = "max_rate=%g (name=%s, weight=%g, load=%g)" %
        [sum[:person_max_load_rate], sum[:person_max_load_name],
        sum[:person_max_load_weight], sum[:person_max_load]]

      [s, s2].join(", ")
    end

    def member
      @mem.values
    end

    def to_s_member
      sort_person(member).map {|p| p.to_s }.join("\n")
    end

    def add_person(person)
      @mem[person.name] = person
      self
    end

    def size
      @mem.size
    end

    def total_weight
      member.map {|p| p.weight}.inject(:+)
    end

    def max_load_weight
      member.map {|p| p.load_weight}.max
    end

    def to_h_load
      # person_name => load_weight
      Hash[*member.map {|person| [person.name, person.load_weight]}.flatten]
    end

    def setup_hand_foot
      @default_hand_rate = 0.15
      @default_foot_rate = 0.35

      case @opt[:hand_foot]
      when /:/
        h, f = $`.to_f, $'.to_f
        s = h + f
        @default_hand_rate = h / s / 2.0
        @default_foot_rate = f / s / 2.0
      when /^\d/
        h = @opt[:hand_foot].to_f
        @default_hand_rate = h / 2.0
        @default_foot_rate = 0.5 - @default_hand_rate
      end
      [@default_hand_rate, @default_foot_rate]
    end
    attr_reader :default_hand_rate, :default_foot_rate

    def summary
      raise if size < 1

      sum = Hash.new
      sum[:person] = size
      sum[:total_weight] = total_weight
      sum[:max_load_weight] = max_load_weight
      p_max = member.sort_by {|p| p.load_weight_rate}.last
      sum[:person_max_load_rate] = p_max.load_weight_rate
      sum[:person_max_load_name] = p_max.name # one person only
      sum[:person_max_load_weight] = p_max.weight
      sum[:person_max_load] = p_max.load_weight

      sum
    end
    alias :summary_h :summary

    def summary_a
      sum = summary
      [sum[:person], sum[:total_weight], sum[:max_load_weight],
        sum[:person_max_load_rate], sum[:person_max_load_name],
        sum[:person_max_load_weight], sum[:person_max_load]]
    end

    def to_ruby
      s = <<"EOS"
#! ruby
require "#{__FILE__}"
g = GF::Formation.new
EOS
      sort_person(member).each do |person|
        s += "g.add_person(GF::Person.new(:name => \"#{person.name}\", :weight => #{person.weight}))\n"
      end

      sort_person(member).each do |person1|
        sort_person(person1.sub.keys).each do |person2|
          s += "g.mem[\"%s\"].put_load(g.mem[\"%s\"], %g)\n" %
            [person1.name, person2.name, person1.sub[person2]]
        end
      end

      s += <<'EOS'
puts g
# puts g; puts g.to_s_member
# puts g.to_ruby
# puts g.to_dot
EOS
      s
    end

    def to_dot
      s = "digraph Gymnastic_Formation {\n"

      sort_person(member).each do |person|
        ps = change_separator(person.name)
        s += "  p%s [label=\"%s\\n(%1.2f)\"];\n" % [ps, ps, person.load_weight]
      end

      sort_person(member).each do |person1|
        sort_person(person1.sub.keys).each do |person2|
          s += "  p%s -> p%s [label = \"%g\"];\n" %
            [change_separator(person1.name),
            change_separator(person2.name),
            person1.sub[person2]]
        end
      end

      s += "}\n"
      s
    end
  end

  class Person
    include GF::Helper

    def initialize(param = {})
      @name = param[:name] || "anonymous" # 名前
      @weight = param[:weight] || 1.0 # 自重
      @sup = {}            # Personインスタンス（上にいる人）から
                           # 真偽値へのハッシュ
      @sub = Hash.new(0.0) # Personインスタンス（下にいる人）から
                           # 実数値（負荷割合）へのハッシュ
    end
    attr_accessor :name, :weight, :sup, :sub

    def put_load(person, rate)
      @sub[person] = rate
      person.sup[self] = true

      self
    end

    def to_s
      s = "name=%s, weight=%g, load=%g, load_rate=%g, " %
        [@name, @weight, load_weight, load_weight_rate]
      s += "supporting: #{to_s_sup(true)}, supported by: #{to_s_sub(true)}"
      s += ", onground=#{onground?}, sub=#{wrong_sub? ? 'ng' : 'ok'}" if $DEBUG

      s
    end

    def load_weight
      # 負荷重量を返す．自重は算入しない
      @sup.keys.map {|p| p.total_weight * p.sub[self]}.inject(:+) || 0.0
    end

    def total_weight
      # 負荷重量と自重の和を返す
      load_weight + @weight
    end

    def load_weight_rate
      # 負荷重量の自重に対する割合を返す
      load_weight / @weight
    end

    def onground?
      # 地面に体をつけているなら真を返す
      return true if @sub.empty?
      @sub.values.inject(:+) < 1.0
    end

    def wrong_sub?
      # 下にかける負荷が不適切（割合の和が1を超えている）なら真を返す
      return false if @sub.empty?
      @sub.values.inject(:+) > 1.0
    end

    def to_a_sup(opt_all = false)
      # 引数がないか偽のときは，直接，自分に負荷をかけている（上にいる）
      # Porsonインスタンスの配列を返す．引数が真のときは，
      # 間接的にかけている人を含める
      a = @sup.keys
      if opt_all
        a += a.map {|p| p.to_a_sup(true)}.flatten
      end
      a.uniq!
      a
    end

    def to_a_sub(opt_all = false)
      # 引数がないか偽のときは，直接，自分が負荷をかけている（下にいる）
      # Porsonインスタンスの配列を返す．引数が真のときは，
      # 間接的にかけている人を含める
      a = @sub.keys
      if opt_all
        a += a.map {|p| p.to_a_sub(true)}.flatten
      end
      a.uniq!
      a
    end

    def to_s_sub(opt_all = false)
      # @subの詳細を文字列にする
      a1 = to_a_sub(false).map {|p| p.name}
      a2 = to_a_sub(true).map {|p| p.name}
      a3 = sort_name(a2 - a1)

      s = "["
      s += sort_person(@sub.keys).map {|p| "%s~%g" % [p.name, @sub[p]]}.join(", ")
      s += ";" if !a1.empty?
      s += " " if !a3.empty?
      s += a3.join(", ")
      s += "]"

      s
    end

    def to_s_sup(opt_all = false)
      # @supの詳細を文字列にする
      a1 = to_a_sup(false).map {|p| p.name}
      a2 = to_a_sup(true).map {|p| p.name}
      a3 = sort_name(a2 - a1)

      s = "["
      s += sort_person(@sup.keys).map {|p| "%s_%g" % [p.name, p.total_weight * p.sub[self]]}.join(", ")
      s += ";" if !a1.empty?
      s += " " if !a3.empty?
      s += a3.join(", ")
      s += "]"
      s
    end
  end

  class Generator
    def self.start(opt = {})
      require_relative "triangle.rb"
      require_relative "trigonal.rb"
      require_relative "yagura.rb"
      require_relative "excel.rb"

      filename_a = []
      summary_a = []

      [[:triangle, (2..8).to_a],
        [:trigonal, (3..11).to_a],
        [:yagura, [5, 7, 9, 21]]].each do |sym, args|
        args.each do |arg|
          gf = GF::Formation.new
          case sym
          when :trigonal
            gf.build_pyramid_trigonal(arg)
            gf.set_trigonal_plc(opt[:plc]) if opt[:plc]
          when :triangle
            gf.build_pyramid_triangle(arg)
          when :yagura
            gf.build_yagura_by_person(arg)
            gf.set_yagura_plc(opt[:plc]) if opt[:plc]
          end
          summary = "Form type=#{sym}, level/person=#{arg}... #{gf}"
          puts summary
          summary_a << summary

          basename = [sym, arg].join

          gf.opt[:print] = :verbose
          filename1 = "#{basename}_result.txt"
          puts "saving as #{filename1}..."
          open(filename1, "w") do |f_out|
            f_out.print gf.to_s.gsub(/\n/, "\r\n") + "\r\n"
            f_out.print gf.to_s_member.gsub(/\n/, "\r\n") + "\r\n"
          end
          filename_a << filename1

          gf.opt[:print] = :ruby
          filename2 = "#{basename}.rb"
          puts "saving as #{filename2}..."
          open(filename2, "w") do |f_out|
            f_out.puts gf.to_ruby
          end
          filename_a << filename2

          gf.opt[:print] = :dot
          filename3 = "#{basename}.dot"
          puts "saving as #{filename3}..."
          open(filename3, "w") do |f_out|
            f_out.puts gf.to_dot
          end
          filename_a << filename3

          image_format = "png"
          filename4 = filename3.sub(/dot$/, image_format)
          command = "dot -T#{image_format} #{filename3} -o #{filename4}"
          puts command
          system command
          filename_a << filename4 if test(?f, filename4)

          filename5 = "#{basename}.xlsx"
          gf.opt[:workbook_name] = filename5
          gf.to_excel
          filename_a << filename5
        end
      end

      # summary
      filename_summary = "00summary.txt"
      puts "saving as #{filename_summary}..."
      open(filename_summary, "w") do |f_out|
        f_out.print (summary_a + [""]).join("\r\n")
      end
      filename_a.unshift(filename_summary)

      # zip
      filename_script = File.basename(__FILE__)
      command = "zip gf.zip " + filename_a.join(" ")
      if File.expand_path(__FILE__) != File.expand_path(filename_script)
        command_cp = "cp #{__FILE__} ."
        puts command_cp
        system command_cp
        filename_a << filename_script
      end
      command += " " + filename_script
      puts command
      system command
      File.unlink(*filename_a)
    end
  end

  class Estimator
    def self.start
      require_relative "triangle.rb"
      require_relative "trigonal.rb"
      require_relative "yagura.rb"

      seed_a = (12340..12349).to_a

      2.upto(5) do |level|
        puts "Triangle (level=#{level})"
        max_load_rate_sum = 0.0
        seed_a.each do |seed|
          srand(seed)
          gf = GF::Formation.new(:triangle => level, :plc => 4, :print => :none)
          gf.start
          max_load_rate = gf.summary[:person_max_load_rate]
          puts "  seed=#{seed}, max_load_rate=#{max_load_rate}"
          max_load_rate_sum += max_load_rate
        end
        puts "  average_max_load_rate=#{max_load_rate_sum / seed_a.size}"

        gf = GF::Formation.new(:triangle => level, :print => :none)
        gf.start
        max_load_rate = gf.summary[:person_max_load_rate]
        puts "  conventional_max_load_rate=#{max_load_rate}"
      end

      3.upto(11) do |level|
        puts "Trigonal (level=#{level})"
        max_load_rate_sum = 0.0
        seed_a.each do |seed|
          srand(seed)
          gf = GF::Formation.new(:pyramid => level, :plc => 4, :print => :none)
          gf.start
          max_load_rate = gf.summary[:person_max_load_rate]
          puts "  seed=#{seed}, max_load_rate=#{max_load_rate}"
          max_load_rate_sum += max_load_rate
        end
        puts "  average_max_load_rate=#{max_load_rate_sum / seed_a.size}"

        gf = GF::Formation.new(:pyramid => level, :print => :none)
        gf.start
        max_load_rate = gf.summary[:person_max_load_rate]
        puts "  conventional_max_load_rate=#{max_load_rate}"
      end

      [5, 7, 9, 21].each do |person|
        puts "Yagura (person=#{person})"
        max_load_rate_sum = 0.0
        seed_a.each do |seed|
          srand(seed)
          gf = GF::Formation.new(:yagura => person, :plc => 4, :print => :none)
          gf.start
          max_load_rate = gf.summary[:person_max_load_rate]
          puts "  seed=#{seed}, max_load_rate=#{max_load_rate}"
          max_load_rate_sum += max_load_rate
        end
        puts "  average_max_load_rate=#{max_load_rate_sum / seed_a.size}"

        gf = GF::Formation.new(:yagura => person, :print => :none)
        gf.start
        max_load_rate = gf.summary[:person_max_load_rate]
        puts "  conventional_max_load_rate=#{max_load_rate}"
      end
    end
  end
end
