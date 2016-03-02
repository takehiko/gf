#!/usr/bin/env ruby

# gfload_est.rb - Load Estimator of Trigonal Human Pyramids
#   by takehikom
# see also:
#   https://gist.github.com/takehiko/a32f51e2eabba4f821d8
#   http://d.hatena.ne.jp/takehikom/20151019/1445266799
# usage:
#   ruby gfload_est.rb
#   ruby gfload_est.rb -p 7 -m 0
#   ruby gfload_est.rb -p 7 -m 1
#   ruby gfload_est.rb -p 7 -m 2
#   ruby gfload_est.rb -p 7 -m 4

require_relative "gfload.rb"
require "optparse"

module GFLoad
  class Estimator
    include GFLoad::Helper

    def initialize(param = {})
      @level = param[:level] || 5      # 三角錐型人間ピラミッドの段数
      @zmax = param[:zmax] || 2        # generate_random_bmで使用
      @placement_id = param[:plc] || 2 # 体重配分の方法
      @weight_a = param[:w]            # 体重のリスト
      @print = param[:print]
    end
    attr_reader :level, :zmax, :placement_id, :gf
    attr_accessor :weight_a

    def start(opt_noprint = false)
      @gf = GFLoad::Formation.new
      @gf.build_pyramid_trigonal(@level)

      unless Array === @weight_a
        init_weight_a
      end

      case @placement_id.to_s
      when "0"
        # do nothing
      when "1"
        place1
      when "3"
        place3
      when "4"
        place4
      else # when "2"
        place2
      end

      if !opt_noprint
        if @print == :verbose
          puts @gf
          puts @gf.to_s_member
        else
          puts self.to_s
        end
      end
    end

    def summary
      raise if @gf.nil?

      sum = Hash.new
      sum[:person] = @gf.mem.size
      sum[:total_weight] = @gf.total_weight
      sum[:max_load_weight] = @gf.max_load_weight
      p_max = @gf.member.sort_by {|p| p.load_weight_rate}.last
      sum[:person_max_load_rate] = p_max.load_weight_rate
      sum[:person_max_load_name] = p_max.name
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

    def to_s
      sum = summary
      s_gf = @gf.to_s
      s_self = "max_rate=%g (name=%s, weight=%g, load=%g)" %
        [sum[:person_max_load_rate], sum[:person_max_load_name],
        sum[:person_max_load_weight], sum[:person_max_load]]
      [s_gf, s_self].join(", ")
    end

    def init_weight_a
      # 分布は，政府統計の総合窓口
      # http://www.e-stat.go.jp/SG1/estat/eStatTopPortal.do
      # の体力・運動能力調査 > 平成２６年度 > 学校段階別体格測定の結果より，
      # 小学校11男子と中学校12男子の体重の平均値・標準偏差をもとにした．
      avg = (37.82 + 43.86) / 2
      sd = Math.sqrt((7.40 ** 2 + 8.31 ** 2) / 2)
      # 小学校11男子のみであれば，以下のコメントを外す
      # avg = 37.82; sd = 7.40
      @weight_a = generate_random_bm(avg, sd, @gf.mem.size, @zmax)
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

    def place1
      # 土台と2段目以上に分けず，負荷の高いところを体重の重い者に割り当てる
      p_a = @gf.mem.values.sort_by {|p| p.load_weight}
      w_a = @weight_a.sort

      p_a.each_with_index do |p, i|
        w = w_a[i]
        p.weight = w
        puts "%s : %5.2f kg" % [p.name, w] if $DEBUG
      end
    end

    def place2
      # 土台と2段目以上に分け，負荷の高いところを体重の重い者に割り当てる
      # (gfload+.rbのデフォルト処理)
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 2段目以上の人(誰かに負荷をかける)
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

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

    def place3
      # 土台と上2段と残りに分け，残りは総当たり
      # 他の方法と比べて時間がかかるが，結果はplace4と同じになる
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 残り
      p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
        @gf.mem[compose_name(*pos)]
      }                                         # 上2段の人
      p_a2 -= p_a3
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a2.map{|p| p.name}.inspect}"
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
      min_load = @gf.max_load_weight * 2
      min_a = (0...p_a2.length).to_a
      min_a.dup.permutation do |a|
        a.each do |num|
          p_a2[num].weight = w_a[num]
        end

        if min_load > @gf.max_load_weight
          min_load = @gf.max_load_weight
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

    def place4
      # 土台と上2段と残りに分ける
      p_a = @gf.mem.values
      p_a1 = p_a.dup
      p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
      p_a2 = p_a - p_a1                         # 残り
      p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
        @gf.mem[compose_name(*pos)]
      }                                         # 上2段の人
      p_a2 -= p_a3
      p_a1.sort_by! {|p| p.load_weight}
      p_a2.sort_by! {|p| p.load_weight}
      w_a = @weight_a.sort

      if $DEBUG
        puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
        puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
        puts "p_a3: #{p_a2.map{|p| p.name}.inspect}"
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

if __FILE__ == $0
  seed = 12345
  opt = OptionParser.new
  h = {}
  opt.on("-p", "--pyramid=VAL",
         "Level of human pyramid") {|v| h[:level] = v.to_i}
  opt.on("-z", "--zmax=VAL",
         "Threshold of weight") {|v| h[:zmax] = v.to_f}
  opt.on("-s", "--seed=VAL",
         "Random seed") {|v| seed = v.to_i}
  opt.on("-m", "--placement=VAL",
         "Placement Method") {|v| h[:plc] = v.dup}
  opt.on("-v", "--verbose",
         "Print verbose info") { h[:print] = :verbose }
  opt.parse!(ARGV)
  srand(seed)
  GFLoad::Estimator.new(h).start
end
