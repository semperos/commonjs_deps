module CommonjsDeps
  module Render
    class Graphml
      attr_reader :graph

      def initialize(graph)
        @graph = graph
        @doc = Nokogiri::XML::Builder.new do |xml|
          xml.graphml(:xmlns => "http://graphml.graphdrawing.org/xmlns") do
            xml.graph(:id => "G", :edgedefault => "directed") do
              # Add custom data fields like label
              xml.key(:id => "d0", :for => "node", "attr.name" => "label", "attr.type" => "string")
            end
          end
        end.doc
      end

      def strip_quotes(s)
        s.delete "'\""
      end

      def build_document
        Nokogiri::XML::Builder.with(@doc.at('graph')) do |xml|
          @graph.each_node do |name, n|
            xml.node(:id => name) #do
              # Add label data entry
              # xml.data(n.label, :key => "d0")
            # end
          end
          @graph.each_edge do |e|
            source = strip_quotes(e.tail_node)
            target = strip_quotes(e.head_node)
            xml.edge(:source => source, :target => target)
          end
        end
      end

      def output_xml
        @doc.to_xml
      end
    end
  end
end
