$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'commonjs_deps/version'

require 'graphviz'
require 'mixlib/cli'
require 'ruby-progressbar'
require 'pathname'
require 'pp'

require 'commonjs_deps/graph.rb'

module CommonjsDeps
  class Cli
    include Mixlib::CLI

    option :target_directory,
    :short => '-d TARGET_DIRECTORY',
    :long => '--directory TARGET_DIRECTORY',
    :required => true,
    :description => 'Target directory to analyze'

    option :extensions,
    :short => '-e EXTENSIONS',
    :long =>  '--extensions EXTENSIONS',
    :default => '.coffee,.hbs',
    :description => 'File extensions to target for analysis'

    option :output_file,
    :short => '-o OUTPUT_FILE',
    :long => '--output-file OUTPUT_FILE',
    :default => 'graph.svg',
    :description => 'Name of file to output'

    option :output_type,
    :short => '-t OUTPUT_TYPE',
    :long => '--output-type OUTPUT_TYPE',
    :default => 'svg',
    :description => 'Type of file output (see Constants module of GraphViz gem)'
  end

  ##
  # Entry point for CLI executables
  #
  def self.main(argv=ARGV)
    cli = CommonjsDeps::Cli.new
    cli.parse_options
    working_dir = File.expand_path(cli.config[:target_directory])
    extensions = cli.config[:extensions].split(/\s*,\s*/)
    output_file = cli.config[:output_file]
    output_type = cli.config[:output_type].to_sym

    puts "Calculating dependency tree for '#{working_dir}'"
    g = CommonjsDeps::Graph
    graph = g::build_dependency_graph(working_dir, extensions)
    puts "Writing graph to file (#{output_file})..."
    g::output_graph(graph, output_file, output_type)
  end
end
