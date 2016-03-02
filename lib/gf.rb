#!/usr/bin/env ruby

require_relative "gf/root.rb"

if __FILE__ == $0
  require 'optparse'
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
