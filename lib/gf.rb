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
  opt.on("-y", "--yagura=VAL",
         "Build wider tower (a.k.a. yagura)") {|v| h[:yagura] = v.to_i }
  opt.on("-m", "--placement=VAL",
         "Placement Method") {|v| h[:plc] = v.dup}
  opt.on("-z", "--zmax=VAL",
         "Threshold of weight") {|v| h[:zmax] = v.to_f}
  opt.on("-v", "--verbose",
         "Print verbose info") { h[:print] = :verbose }
  opt.on("-r", "--ruby",
         "Print Ruby code") { h[:print] = :ruby }
  opt.on("-d", "--dot",
         "Print DOT (Graphviz) code") { h[:print] = :dot }
  opt.on("-x", "--excel=VAL",
         "Save as Excel file") {|v| h[:workbook_name] = v.dup }
  opt.on("-q", "--quiet",
         "Quiet") { h[:print] = :none }
  opt.on("-A", "--generate",
         "Generate cases") { h[:g] = true }
  opt.on("-E", "--estimate",
         "Estimate typical cases") { h[:e] = true }
  opt.on("-h", "--handfoot=VAL",
         "Hand and foot weighting") {|v| h[:hand_foot] = v.dup }
  opt.on("-s", "--seed=VAL",
         "Random seed") {|v| srand(v.to_i)}
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
    GF::Generator.start(h)
    exit
  elsif h[:e]
    GF::Estimator.start
    exit
  end
  GF::Formation.new(h).start
end
