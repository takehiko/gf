#!/usr/bin/env ruby

# gfload+.rb : Load Estimation of Trigonal Human Pyramids
#   by takehikom
# see also:
#   https://gist.github.com/takehiko/a32f51e2eabba4f821d8
#   http://d.hatena.ne.jp/takehikom/20151016/1444941800
#   http://d.hatena.ne.jp/takehikom/20151018/1445094000
# usage:
#   ruby gfload+.rb
#   ruby gfload+.rb 5
#   ruby gfload+.rb 5 4

require_relative "gfload.rb"

srand(12345)

def generate_random_bm(avg, sd, size, zmax = 2)
  # ボックス=ミュラー法を用いて，平均avg, 分散sd**2の正規分布から
  # size個の乱数を生成しリストにして返す
  # seedは乱数生成の種
  # zmaxが正のとき，乱数のz値の絶対値がzmaxを超えるものは使用しない
  # zmaxが0のとき，size個のavgからなるリストを返す
  # zmaxが負のとき，値の切り捨ては行わない

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

gf = GFLoad::Formation.new
level = (ARGV.shift || 5).to_i
gf.build_pyramid_trigonal(level)
size = gf.mem.size

# 分布は，政府統計の総合窓口
# http://www.e-stat.go.jp/SG1/estat/eStatTopPortal.do
# の体力・運動能力調査 > 平成２６年度 > 学校段階別体格測定の結果より，
# 小学校11男子と中学校12男子の体重の平均値・標準偏差をもとにした．
avg = (37.82 + 43.86) / 2
sd = Math.sqrt((7.40 ** 2 + 8.31 ** 2) / 2)
# 小学校11男子のみであれば，以下のコメントを外す
# avg = 37.82; sd = 7.40
w_a = generate_random_bm(avg, sd, size)

case ARGV.shift
when "1"
  # 土台と2段目以上に分けず，負荷の高いところを体重の重い者に割り当てる
  p_a = gf.mem.values.sort_by {|p| p.load_weight}
  w_a.sort!

  p_a.each_with_index do |p, i|
    w = w_a[i]
    p.weight = w
    puts "%s : %5.2f kg" % [p.name, w]
  end
when "3"
  # 土台と上2段と残りに分け，残りは総当たり
  # 他の方法と比べて時間がかかるが，結果はwhen "4"のときと同じになる
  include GFLoad::Helper

  p_a = gf.mem.values
  p_a1 = p_a.dup
  p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
  p_a2 = p_a - p_a1                         # 残り
  p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
      gf.mem[compose_name(*pos)]
  }                                         # 上2段
  p_a2 -= p_a3
  p_a1.sort_by! {|p| p.load_weight}
  p_a2.sort_by! {|p| p.load_weight}
  w_a.sort!

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
    puts "%s : %5.2f kg" % [p.name, w]
  end

  # 土台
  p_a1.reverse.each do |p|
    w = w_a.pop
    p.weight = w
    puts "%s : %5.2f kg" % [p.name, w]
  end

  if p_a2.length != w_a.length
    raise
  end

  # 残り
  c = c_init = 10000
  min_load = gf.max_load_weight * 2
  min_a = (0...p_a2.length).to_a
  min_a.dup.permutation do |a|
    a.each do |num|
      p_a2[num].weight = w_a[num]
    end

    if min_load > gf.max_load_weight
      min_load = gf.max_load_weight
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
    puts "%s : %5.2f kg" % [p_a2[num].name, w_a[num]]
  end
when "4"
  # 土台と上2段と残りに分ける
  include GFLoad::Helper

  p_a = gf.mem.values
  p_a1 = p_a.dup
  p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
  p_a2 = p_a - p_a1                         # 残り
  p_a3 = [[level, 1, 1], [level - 1, 1, 1], [level - 1, 1, 2]].map {|pos|
      gf.mem[compose_name(*pos)]
  }                                         # 上2段
  p_a2 -= p_a3
  p_a1.sort_by! {|p| p.load_weight}
  p_a2.sort_by! {|p| p.load_weight}
  w_a.sort!

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
    puts "%s : %5.2f kg" % [p.name, w]
  end

  # 土台
  p_a1.reverse.each do |p|
    w = w_a.pop
    p.weight = w
    puts "%s : %5.2f kg" % [p.name, w]
  end

  if p_a2.length != w_a.length
    raise
  end

  # 残り
  p_a2.each do |p|
    w = w_a.shift
    p.weight = w
    puts "%s : %5.2f kg" % [p.name, w]
  end
else # when "2"
  # 土台と2段目以上に分け，負荷の高いところを体重の重い者に割り当てる
  p_a = gf.mem.values
  p_a1 = p_a.dup
  p_a1.delete_if {|p| p.name[0, 2] != "1."} # 土台の人(誰にも負荷をかけない)
  p_a2 = p_a - p_a1                         # 2段目以上の人(誰かに負荷をかける)
  p_a1.sort_by! {|p| p.load_weight}
  p_a2.sort_by! {|p| p.load_weight}
  w_a.sort!

  if $DEBUG
    puts "p_a1: #{p_a1.map{|p| p.name}.inspect}"
    puts "p_a2: #{p_a2.map{|p| p.name}.inspect}"
    puts "w_a: #{w_a.inspect}"
  end

  [p_a2, p_a1].each do |p_aa|
    p_aa.each do |p|
      w = w_a.shift
      p.weight = w
      puts "%s : %5.2f kg" % [p.name, w]
    end
  end
end

puts gf
puts gf.to_s_member
