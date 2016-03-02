#!/usr/bin/env ruby

# gfload.rb : Load Calculator for Gymnastic Formation
#   by takehikom

require 'optparse'

module GFLoad
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
  end

  class Formation
    include GFLoad::Helper

    def initialize(h = nil)
      @mem = {} # name => Personインスタンス
      @opt = h || {}
    end
    attr_accessor :mem, :opt

    def start
      if @opt.key?(:triangle)
        build_pyramid_triangle(@opt[:triangle])
      elsif @opt.key?(:pyramid)
        build_pyramid_trigonal(@opt[:pyramid])
      else
        p11 = GFLoad::Person.new(:name => "1-1"); add_person(p11)
        p12 = GFLoad::Person.new(:name => "1-2"); add_person(p12)
        p13 = GFLoad::Person.new(:name => "1-3"); add_person(p13)
        p21 = GFLoad::Person.new(:name => "2-1"); add_person(p21)
        p21.put_load(p11, 0.5)
        p21.put_load(p12, 0.5)
        p22 = GFLoad::Person.new(:name => "2-2"); add_person(p22)
        p22.put_load(p12, 0.5)
        p22.put_load(p13, 0.5)
        p31 = GFLoad::Person.new(:name => "3-1"); add_person(p31)
        p31.put_load(p21, 0.5)
        p31.put_load(p22, 0.5)
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

    def build_pyramid_trigonal(level = 4)
      # トップダウンで三角錐型（立体型）ピラミッドを構成
      raise if level < 3

      name_top = compose_name(level, 1, 1)
      p = GFLoad::Person.new(:name => name_top)
      add_person(p)

      name_a = [compose_name(level - 1, 1, 1), compose_name(level - 1, 1, 2)]
      name_a.each do |name|
        p = GFLoad::Person.new(:name => name)
        add_person(p)
        @mem[name_top].put_load(p, 0.5)
      end

      until name_a.empty?
        name = name_a.shift
        p = @mem[name]

        i, j, k = decompose_name(name)

        if i >= 3
          i2 = i - 2
          j2 = j + 1
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GFLoad::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, 0.35)
          end
        end

        if i >= 2
          i2 = i - 1
          j2 = j
          [k, k + 1].each do |k2|
            name2 = compose_name(i2, j2, k2)
            if !@mem.key?(name2)
              p2 = GFLoad::Person.new(:name => name2)
              add_person(p2)
              name_a << name2
            else
              p2 = @mem[name2]
            end
            p.put_load(p2, 0.15)
          end
        end
      end
    end

    def to_s
      s = "%d persons, total_weight=%g, max_load=%g" %
        [size, total_weight, max_load_weight]
      h = to_h_load
      a = sort_name(h.keys)
      s2 = "[" + a.map {|name| "#{name}:#{h[name]}"}.join(", ") + "]"
      s2 += "load: #{s}"
      s
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

    def to_ruby
      s = <<"EOS"
#! ruby
require "#{__FILE__}"
g = GFLoad::Formation.new
EOS
      sort_person(member).each do |person|
        s += "g.add_person(GFLoad::Person.new(:name => \"#{person.name}\", :weight => #{person.weight}))\n"
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
    include GFLoad::Helper

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
    def start
      filename_a = []
      summary_a = []

      [[:triangle, 2, 8], [:trigonal, 3, 11]].each do |sym, level_min, level_max|
        level_min.upto(level_max) do |level|
          gf = GFLoad::Formation.new
          case sym
          when :trigonal
            gf.build_pyramid_trigonal(level)
          when :triangle
            gf.build_pyramid_triangle(level)
          end
          summary = "#{sym} human pyramids (level=#{level})... #{gf}"
          puts summary
          summary_a << summary

          basename = [sym, level].join

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
      command = "zip gfload.zip " + filename_a.join(" ")
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
end

if __FILE__ == $0
  opt = OptionParser.new
  h = {}
  opt.on("-t", "--triangle=VAL",
         "Build triangular human pyramid") {|v| h[:triangle] = v.to_i }
  opt.on("-p", "--pyramid=VAL",
         "Build trigonal human pyramid") {|v| h[:pyramid] = v.to_i }
  opt.on("-v", "--verbose",
         "Print verbose info") { h[:print] = :verbose }
  opt.on("-r", "--ruby",
         "Print Ruby code") { h[:print] = :ruby }
  opt.on("-d", "--dot",
         "Print DOT (Graphviz) code") { h[:print] = :dot }
  opt.on("-z", "--generate",
         "Generate cases") { h[:g] = true }
  opt.on("-a", "--from-programmer", "Message from the programmer") {
    puts <<'EOS'
The programmer earnestly hopes that this program is used for evaluating
the load of lofty human pyramids and knotted gymnastic formations
quantitatively and reducing the risk, not for merely highlighting
the dangers.
EOS
    exit
  }
  opt.parse!(ARGV)
  if h[:g]
    GFLoad::Generator.new.start
    exit
  end
  GFLoad::Formation.new(h).start
end
