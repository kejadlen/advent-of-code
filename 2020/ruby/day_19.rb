# require "bundler/inline"

# gemfile do
#   source "https://rubygems.org"
#   gem "parslet"
# end

rules, messages = ARGF.read.split("\n\n")

# class Day19 < Parslet::Parser
#   root(:rule_0)
# end

# rules = rules.split("\n").map {|rule| rule.split(": ") }.to_h
# rules["8"] = "42 | 42 8"
# rules["11"] = "42 31 | 42 11 31"
# rules.each do |rule, sub_rules|
#   sub_rules = sub_rules.split(" | ").map {|sub_rule|
#     sub_rule.split(/\s+/).map {|sub_sub_rule|
#       sub_sub_rule =~ /^\d+$/ ? "rule_#{sub_sub_rule}" : "str(#{sub_sub_rule})"
#     }.join(" >> ")
#   }.join(" | ")
#   rule = "rule(:rule_#{rule}) { #{sub_rules} }"
#   p rule

#   Day19.class_eval(rule)
# end

# PARSER = Day19.new
# def parsable?(input)
#   !!PARSER.parse(input)
# rescue
#   false
# end
# puts messages.split("\n").select {|line| parsable?(line) }

# begin
#   p PARSER.parse("bbbbbbbaaaabbbbaaabbabaaa")
# rescue Parslet::ParseFailed => failure
#   puts failure.parse_failure_cause.ascii_tree
# end

rules = rules.split("\n").map {|line|
  line.split(": ")
}.to_h

rule = rules["0"]
while rule =~ /\d/
  rule.gsub!(/\d+/) {|r|
    case r
    when "8"
      "(?:42)+"
    when "11"
      "(?:#{(1..5).map {|i| (Array.new(i, "42") + Array.new(i, "31")).join(" ") }.join(" | ")})"
    else
      value = rules.fetch(r)
      value = value[1..-2] if value =~ /^"\w+"$/
      "(?:#{value})"
    end
  }
end
rule.gsub!(" ", "")
while rule =~ /\(\?:\w+\)/
  rule.gsub!(/\(\?:(\w+)\)/, '\1')
end

p messages.split("\n").count {|m| m =~ /^#{rule}$/ }
