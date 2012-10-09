require "commonjs_deps/version"

require 'graphviz'

require 'pp'

module CommonjsDeps
  def self.candidate_files (exts = [".coffee", ".hbs"])
    fs = []
    exts.each do |ext|
      fs += Dir.glob("**/*#{ext}").map { |f| File.expand_path(f) }
    end
    fs
  end

  def self.find_existing_files(file_minus_ext, exts = [".coffee", ".hbs"])
    # Prefer the first, take it off the array
    pref_ext = exts[0]
    other_exts = exts[1..-1]
    if File.exists?(file_minus_ext + pref_ext)
      file_minus_ext + pref_ext
    else
      possible_files = other_exts.map { |ext| file_minus_ext + ext }
      possible_files.keep_if { |f| File.exists? f }.first
    end
  end
  
  ##
  # Return array of modules that this module requires
  #
  def self.require_statements (working_dir, file, exts = [".coffee", ".hbs"])
    rs = []
    File.open(file, 'r').each_line do |line|
      data = line.split(/^[^=]+=\s+require\b/i)
      if data.count > 1
        raw_require = data[1].strip.delete("'\"();")
        file_minus_ext = File.join(working_dir, "#{raw_require}")
        file_with_ext = find_existing_files(file_minus_ext, exts)
        rs << file_with_ext
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

  ##
  # Utility to iterate through file entry's requires and print them nicely
  #
  def self.print_requires(file_entry)
    if file_entry[:requires].count > 0
      puts "  Requires:"
      file_entry[:requires].each do |r|
        puts "    #{r}"
      end
    end
  end

  ##
  # Since we're looking at file, absolute paths are too long. Shorten to final paths.
  #
  def self.significant_path(working_dir, file, num_chars = 40)
    # Ensure the path is intelligible
    patt = Regexp.new("#{working_dir}(.*)")
    matches = patt.match(file).to_a
    matches[1] || matches[0]
  end
  
  ##
  # Custom add_node behavior (e.g., shorten label)
  #
  def self.add_node(graph, element, opts)
    n = graph.add_nodes(element, opts)
  end

  ##
  # Given map of {"file name" => {:requires => ["foo", "bar"]}}, build graph
  #
  def self.build_graph(tree, working_dir)
    graph = GraphViz.new( :G, :type => :digraph)

    # Graphviz gem does smart node addition;
    # if it's already there, it doesn't create
    # new objects.
    tree.each do |file, attrs|
      file_label = significant_path(working_dir, file)
      file_node = add_node(graph, file, {'label' => file_label})
      requires = attrs[:requires].delete_if { |x| x.nil? }
      requires.each do |r|
        r_label = significant_path(working_dir, r)
        r_node = add_node(graph, r, {'label' => r_label})
        file_node << r_node
      end
    end
    graph
  end

  ##
  # Entry point for CLI executables
  #
  def self.main
    working_dir = File.expand_path(ARGV[0])
    puts "Calculating dependency tree for '#{working_dir}'"
    tree = {}
    Dir.chdir(working_dir) do |path|
      files = candidate_files
      puts "Total files to analyze: #{files.count}"
      files.each do |f|
        add_file_entry tree, working_dir, f
      end
    end
    puts "Building graph..."
    graph = build_graph(tree, working_dir)
    output_file = File.expand_path ARGV[1]
    puts "Writing graph to SVG file: #{output_file}"
    graph.output( :svg => output_file )
  end
end
