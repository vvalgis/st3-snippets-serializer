#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'yaml'
require 'fileutils'

class ST3SS

  def initialize(yaml_file_name: nil, path: default_path)
    if yaml_file_name
      @directory_path = File.expand_path(File.join(path, File.basename(yaml_file_name, '.*')))
      @snippets = generate_xml(YAML.load_file(yaml_file_name))
    end
  end

  def convert(input)
    generate_xml(parse_yaml(input))
  end

  def install
    create_snippets_directory
    write_snippets
  end

  def clean
    FileUtils.rm_rf(@directory_path)
  end

  private

  def default_path
    case RUBY_PLATFORM
    when /darwin/
      '~/Library/Application Support/Sublime Text 3/Packages/User'
    else
      '~/'
    end
  end

  def parse_yaml(yaml)
    YAML.load(yaml)
  end

  def generate_xml(snippets)
    output = {}

    snippets.each do |file_name, snippet|
      doc = Ox::Document.new(:version => '1.0')
      snippet_node = Ox::Element.new('snippet')
      snippet.each do |node_name, node_value|
        snippet_node << modify(node_name, node_value)
      end
      doc << snippet_node
      output[file_name] = Ox.dump(doc, {indent: 2})
    end
    output
  end

  def modify(node_name, node_value)
    name, value = case node_name
    when 'scope' then [node_name, "source.#{node_value}"]
    when 'tab' then ['tabTrigger', node_value]
    when 'desc' then ['description', node_value]
    # when 'content' then [node_name, Ox::CData.new(node_value.gsub(/\n/, "\n  ").strip)]
    when 'content' then [node_name, Ox::CData.new(node_value.strip)]
    else [node_name, node_value]
    end
    Ox::Element.new(name) << value
  end

  def create_snippets_directory
    FileUtils.mkdir_p(@directory_path) unless File.exists?(@directory_path)
  end

  def write_snippets
    @snippets.each do |file_name, content|
      File.open(File.join(@directory_path, "#{file_name}.sublime-snippet"), "wb") { |f| f.write(content) }
    end
  end
end

if $0 == __FILE__
  cmd, yaml_file_name, *_ = ARGV
  ST3SS.new(yaml_file_name: yaml_file_name).send(cmd)
end
