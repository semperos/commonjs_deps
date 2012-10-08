require "commonjs_deps/version"

require 'graphviz'

require 'pp'

module CommonjsDeps
  def self.candidate_files (ext = ".coffee")
    Dir.glob("**/*#{ext}").map { |f| File.expand_path(f) }
  end

  ##
  # Return array of modules that this module requires
  #
  def self.require_statements (working_dir, file, ext = ".coffee")
    rs = []
    File.open(file, 'r').each_line do |line|
      data = line.split(/require/i)
      if data.count > 1
        raw_require = data[1].strip.delete("'\"()")
        rs << File.join(working_dir, "#{raw_require}#{ext}")
      end
    end
    rs
  end

  ##
  # Build tree with require statements for given file
  #
  def self.add_file_entry(tree, working_dir, file)
    tree[file] = {:requires => require_statements(working_dir, file)}
  end

  def self.print_requires(file_entry)
    if file_entry[:requires].count > 0
      puts "  Requires:"
      file_entry[:requires].each do |r|
        puts "    #{r}"
      end
    end
  end

  ##
  # Only add node if it doesn't already exist
  #
  def self.soft_add(graph, name)
    n = graph.get_node(name)
    if n.nil?
      puts "Adding node for #{name} to graph"
      n = graph.add_nodes(name)
    end
    n
  end

  def self.build_graph(tree)
    graph = GraphViz.new( :G, :type => :digraph)

    # Graphviz gem does smart node addition;
    # if it's already there, it doesn't create
    # new objects.
    tree.each do |file, attrs|
      file_node = graph.add_nodes(file)
      requires = attrs[:requires]
      requires.each { |r| graph.add_nodes(r) }
      requires.each do |r|
        r_node = graph.get_node(r)
        graph.add_edges(file_node, r_node)
      end
    end
    graph
  end

  def self.main
    working_dir = File.expand_path(ARGV[0])
    puts "Calculating dependency tree for '#{working_dir}'"
    tree = {}
    Dir.chdir(working_dir) do |path|
      files = candidate_files
      files.each do |f|
        puts "Analyzing file: #{f}"
        add_file_entry tree, working_dir, f
        print_requires tree[f]
      end
    end
    graph = build_graph(tree)
    puts "Full tree:"
    pp tree
    puts "Raw Graph:"
    pp graph
    output_file = File.expand_path ARGV[1]
    puts "Writing graph to SVG file: #{output_file}"
    graph.output( :svg => output_file )
  end
end
