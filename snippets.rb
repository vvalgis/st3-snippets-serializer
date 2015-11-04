#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'yaml'
require 'fileutils'

class ST3SS

  def initialize(yaml_file_name: nil, path: default_path)
    @yaml_file_name = yaml_file_name.to_s
    @sublime_directory_path = File.expand_path(path)
    @directory_path = File.join(@sublime_directory_path, File.basename(@yaml_file_name, '.*'))
  end

  def convert_to_snippets(yaml_or_file_name, from_file: false)
    parse_yaml = choose_yaml_load_method(predicate: from_file)
    generate_snippets(parse_yaml[yaml_or_file_name])
  end

  def convert_to_yaml(snippets)
    snippets = Hash[snippets.to_a.map { |(file_name, xml)| [file_name, xml_to_object(xml)] }]
    YAML.dump(snippets).gsub(/\|-/, '|+').gsub(/\n\s*?SPECIAL_MARK_OF_CONVERTER/, '')
  end

  def install
    @snippets = convert_to_snippets(@yaml_file_name, from_file: true) if @yaml_file_name
    create_snippets_directory
    write_snippets
  end

  def serialize(files: [])
    files = files.map { |path| Dir.glob(File.join(@sublime_directory_path, path, '**', '*.sublime-snippet')) }.flatten
    snippets = Hash[files.map { |file_name| [File.basename(file_name, '.*'), File.read(file_name)] }]
    write_yaml(convert_to_yaml(snippets))
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

  def choose_yaml_load_method(predicate:)
    predicate ? YAML.method(:load_file) : YAML.method(:load)
  end

  def generate_snippets(snippets)
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

  def xml_to_object(xml)
    obj, doc = {}, Ox.parse(xml)
    doc.nodes.each do |node|
      value = node.name == 'content' ? node.nodes.first.value : node.text
      name, value = modify_back(node.name, value)
      obj[name] = value
    end
    obj
  end

  def modify(node_name, node_value)
    name, value = case node_name
    when 'scope' then [node_name, "source.#{node_value}"]
    when 'tab' then ['tabTrigger', node_value]
    when 'desc' then ['description', node_value]
    when 'content' then [node_name, Ox::CData.new(node_value.strip)]
    else [node_name, node_value]
    end
    Ox::Element.new(name) << value
  end

  def modify_back(node_name, node_value)
    case node_name
    when 'scope' then [node_name, node_value.gsub(/source\./, '')]
    when 'tabTrigger' then ['tab', node_value]
    when 'description' then ['desc', node_value]
    when 'content' then [node_name, (node_value.match("\n") ? node_value : node_value + "\nSPECIAL_MARK_OF_CONVERTER")]
    else [node_name, node_value]
    end
  end

  def create_snippets_directory
    FileUtils.mkdir_p(@directory_path) unless File.exists?(@directory_path)
  end

  def write_snippets
    @snippets.each do |file_name, content|
      File.open(File.join(@directory_path, "#{file_name}.sublime-snippet"), "wb") { |f| f.write(content) }
    end
  end

  def write_yaml(content)
    File.open(File.join(__dir__, @yaml_file_name), "wb") { |f| f.write(content) }
  end
end

if $0 == __FILE__
  # raise RuntimeError, ARGV
  cmd, yaml_file_name, *files = ARGV
  cmd_and_args = [cmd]
  if cmd == 'serialize'
    cmd_and_args = [cmd, {files: files}]
  end
  ST3SS.new(yaml_file_name: yaml_file_name).send(*cmd_and_args)
end
