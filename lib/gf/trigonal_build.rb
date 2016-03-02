#!/usr/bin/env ruby

# pyramid_build.rb - How to Build Trigonal Human Pyramids
#   by takehikom
# see also:
#   https://gist.github.com/takehiko/a32f51e2eabba4f821d8
#   http://d.hatena.ne.jp/takehikom/20151020/1445266800
# usage:
#   ruby lib/gf/pyramid_build.rb
#   ruby lib/gf/pyramid_build.rb -p 11

require_relative "root.rb"
require "optparse"

class GFBuild
  include GFLoad::Helper

  def initialize(param = {})
    @level = param[:level] || 5 # 三角錐型人間ピラミッドの段数
  end

  def start(opt_noprint = false)
    init_pyramid
    setup_row
    print_precedure
  end

  def init_pyramid
    @gf = GFLoad::Formation.new
    @gf.build_pyramid_trigonal(@level)
  end

  def setup_row
    @num = Hash.new(0) # row name => number of persons
    @key_a = []        # list of topologically sorted rows
    @key_hardest = ""

    @gf.mem.each_pair do |n, p|
      n2 = rowname(n)
      puts "Found person: #{n} (#{n2})" if $DEBUG
      @num[n2] += 1
      if p.load_weight == @gf.max_load_weight
        @key_hardest = n2
      end
    end

    @key_a = @num.keys.sort_by {|key|
      a = decompose_name(key)
      "%04d%04d" % [a.first + a.last, 9999 - a.first]
    }

    if $DEBUG
      puts @num.inspect
      puts @key_a.inspect
    end
  end

  def print_precedure
    puts "#{@level}段の三角錐タイプのピラミッドをつくるには、#{@gf.size}人が協力して行います。"

    @key_a.each do |key|
      a = decompose_name(key)
      if a.first == @level && a.last == 1
        puts "#{@level}段目の人が、#{@level - 1}段目の2人の背に足を乗せて立ちます。"
        next
      end
      if a.first == 1 && a.last == 1
        print "はじめに、"
      end
      puts "#{a.first}段目で前から#{a.last}列目の#{@num[key]}人が並びます。"
      if a.first == 1
        puts "　　四つんばいで地面につきます。"
      else
        print "　　中腰の姿勢で、"
        if a.first == 2
          puts "手は、1段目の#{a.last}列目の人の背中に乗せ、足は地面です。"
        else
          print "手は、#{a.first - 1}段目で前から#{a.last}列目の人の背中に乗せ、"
          puts "足は、#{a.first - 2}段目で前から#{a.last + 1}列目の人の背中（肩）の上です。"
        end
      end
      if key == @key_hardest
        puts "　　この列に最も負荷がかかりますので、協力し合いましょう。"
      end
    end

    puts "最後に1列目の人がポーズを決めたら、完成です。"
  end

  def rowname(name)
    # rowname("1.2.3") == "1.2"
    compose_name(*decompose_name(name)[0..-2])
  end
end

if __FILE__ == $0
  opt = OptionParser.new
  h = {}
  opt.on("-p", "--pyramid=VAL",
         "Level of human pyramid") {|v| h[:level] = v.to_i}
  opt.parse!(ARGV)
  GFBuild.new(h).start
end
