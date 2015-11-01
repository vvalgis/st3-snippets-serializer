require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)
require './snippets'

include Wrong

test_cases = []

test_cases << [<<-YAML, {'if' => <<-XML1, 'callproc' => <<-XML2}]
---
if:
  scope: racket
  tab: if
  desc: if expression
  content: |+
    (if (${1:predicate})
      ${2:consequent}
      ${3:alternative})
callproc:
  scope: racket
  tab: cc
  desc: Call some procedure
  content: |+
    (${1:name} ${2:argument})
YAML

<snippet>
  <scope>source.racket</scope>
  <tabTrigger>if</tabTrigger>
  <description>if expression</description>
  <content>
    <![CDATA[(if (${1:predicate})
  ${2:consequent}
  ${3:alternative})]]>
  </content>
</snippet>
XML1

<snippet>
  <scope>source.racket</scope>
  <tabTrigger>cc</tabTrigger>
  <description>Call some procedure</description>
  <content>
    <![CDATA[(${1:name} ${2:argument})]]>
  </content>
</snippet>
XML2

test_cases.each do |input, output|
  assert { ST3SS.new.convert(input) == output }
end

# test cli

test_yaml_file = File.expand_path(File.join(__dir__, 'ST3SS_test.yml'))
def check_file(fname)
  File.exists?(File.expand_path("~/ST3SS_test/#{fname}.sublime-snippet"))
end

bin = File.expand_path(File.join(__dir__, 'snippets.rb'))

`ruby #{bin} install #{test_yaml_file}`
existance = %w(callproc if).map { |name| check_file(name) }.all?
assert { existance }

`ruby #{bin} clean #{test_yaml_file}`
non_existance =  %w(callproc if).map { |name| !check_file(name) }.all? && !File.exists?('~/ST3SS_test')
assert { non_existance }
