#!/usr/bin/env ruby

# collect_excel.rb : Excel file aggregator
#   by takehikom

# http://d.hatena.ne.jp/maluboh/20080704
# http://seesaawiki.jp/w/kou1okada/d/Ruby%20-%20win32ole%20-%20Excel

require "win32ole"

env_a = ["USERPROFILE", "HOMEDRIVE", "HOMEPATH"]
prop_a = ["Process", "Volatile", "User", "System"]
wso = WIN32OLE.new("WScript.Shell")
env_a.each do |k|
  wso.Environment("Process").setproperty("item", k, (prop_a.map{|t| wso.Environment(t).Item(k)} << ENV[k]).bsearch{|x| x != ""})
end

xl = WIN32OLE.new("Excel.Application")
fso = WIN32OLE.new("Scripting.FileSystemObject")

xl.Workbooks.Add
book = xl.ActiveWorkbook

filename_a = (2..8).map {|i| "triangle#{i}.xlsx"} +
  (3..11).map {|i| "trigonal#{i}.xlsx"} +
  [5, 7, 9, 21].map {|i| "yagura#{i}.xlsx"}

filename_a.reverse.each do |filename|
  puts filename
  basename = filename.sub(/.xlsx$/, "")
  book2 = xl.Workbooks.Open(fso.GetAbsolutePathName(filename))
  sheet = book2.Worksheets(1)
  sheet.Copy "after" => book.Worksheets(1)
  book.Worksheets(2).Name = basename
  book2.Close("SaveChanges" => false)
end

all_file = "all.xlsx"
if test(?f, all_file)
  File.unlink(all_file)
end
book.SaveAs("Filename" => fso.GetAbsolutePathName(all_file))
book.Close("SaveChanges" => true)

xl.Quit
