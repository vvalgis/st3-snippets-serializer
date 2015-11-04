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
  desc: Apply some procedure
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
  <description>Apply some procedure</description>
  <content>
    <![CDATA[(${1:name} ${2:argument})]]>
  </content>
</snippet>
XML2

test_cases.each do |input, output|
  assert { ST3SS.new.convert_to_snippets(input) == output }
end

test_cases.each do |input, output|
  assert { ST3SS.new.convert_to_yaml(output) == input }
end

# test cli

test_yaml_file = File.expand_path(File.join(__dir__, 'ST3SS_test.yml'))
def check_file(fname)
  File.exists?(File.expand_path("~/ST3SS_test/#{fname}.sublime-snippet"))
end

def check_dir(dir_name)
  File.exists?(File.expand_path("~/#{dir_name}"))
end

bin = File.expand_path(File.join(__dir__, 'snippets.rb'))


# install

`ruby #{bin} install #{test_yaml_file}`
existance = %w(callproc if).map { |name| check_file(name) }.all?
assert { existance }


# clean

`ruby #{bin} clean #{test_yaml_file}`
non_existance =  %w(callproc if).map { |name| !check_file(name) }.all? && !check_dir('ST3SS_test')
assert { non_existance }


# serialize directory

directory = 'ST3SS_test'
yaml_file_name = 'ST3SS_test2.yml'
`ruby #{bin} install #{test_yaml_file}`
`ruby #{bin} serialize #{yaml_file_name} #{directory}`

output = File.expand_path("./#{yaml_file_name}")
existance = File.exists?(output)
assert { existance }
FileUtils.rm(output)

`ruby #{bin} clean #{test_yaml_file}`


# serialize files

# `ruby #{bin} serialize somefile somefile #{yaml_file_name}`
# non_existance =  %w(callproc if).map { |name| !check_file(name) }.all? && !File.exists?('~/ST3SS_test')
# assert { non_existance }