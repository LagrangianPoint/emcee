module Emcee
  # ScriptProcessor scans a document for external script references and inlines
  # them into the current document.
  class ScriptProcessor
    # Match a script tag.
    #
    #   <script src="assets/example.js"></script>
    #
    SCRIPT_PATTERN = /^\s*<script .*src=["'].+\.js["']><\/script>$/

    # Match the source path from a script tag. Captures the actual path.
    #
    #   src="/assets/example.js"
    #
    SRC_PATH_PATTERN = /src=["'](?<path>[\w\.\/-]+)["']/

    # Match the indentation whitespace of a line
    #
    INDENT_PATTERN = /^(?<indent>\s*)/

    def process(context, data, directory)
      tags = find_tags(data)
      paths = get_paths(tags)
      indents = get_indents(tags)
      contents = get_contents(paths, directory)
      inline_scripts(data, tags, indents, contents)
    end

    private

    def read_file(path)
      File.read(path)
    end

    def find_tags(data)
      data.scan(SCRIPT_PATTERN).map do |tag|
        tag
      end
    end

    def get_paths(tags)
      tags.map do |tag|
        tag[SRC_PATH_PATTERN, :path]
      end
    end

    def get_indents(tags)
      tags.map do |tag|
        tag[INDENT_PATTERN, :indent] || ""
      end
    end

    def get_contents(paths, directory)
      paths.map do |path|
        absolute_path = File.absolute_path(path, directory)
        read_file(absolute_path)
      end
    end

    def inline_scripts(data, tags, indents, contents)
      tags.each_with_index.reduce(data) do |output, (tag, i)|
        indent, content = indents[i], contents[i]
        output.gsub(tag, "#{indent}<script>#{content}\n#{indent}</script>")
      end
    end
  end
end