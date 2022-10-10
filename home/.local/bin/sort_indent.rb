module IndentParser
  def self.parse(content)
    root = Node.new
    stack = [root]

    content.split(/\r?\n/).each do |line|
      next if line.match?(/^\s*$/)

      node = Node.new(line)
      depth = stack.length - 1

      # node is 1 deeper
      if node.depth > depth
        stack.last.add_child node
        stack << node

      # node is shallower
      else
        (depth - node.depth).times { stack.pop }
        stack.last.add_child node
        stack << node
      end
    end

    root.to_struct
  end

  class Node
    include Enumerable

    attr_accessor :content, :depth

    def initialize(str = nil)
      if str && (m = str.match(/^(\s*)(.*)$/))
        @depth = (m[1].length / 2)
        @content = m[2]
      else
        @depth = -1
      end
    end

    def children
      @children ||= []
    end

    def add_child(node)
      children << node
    end

    def to_struct
      {
        content: content,
        depth: depth,
        children: (children || []).collect { |c| c.to_struct }
      }
    end
  end
end
