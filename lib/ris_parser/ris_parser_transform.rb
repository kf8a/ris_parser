# encoding: UTF-8
require 'parslet'

module RisParser
  class RisParserTransform < Parslet::Transform
    author_binding = binding
    rule(:contents => simple(:x)) { String(x).chomp }
    rule(:stanza => subtree(:record)) do
      biblio = {}
      biblio[:authors] = []
      record.each do |entry|
        key = entry.keys.first
        if key == :author
          biblio[:authors].push entry[key]
        else
          biblio[key] = entry[key]
        end
      end
      biblio
    end
    rule(:file_name => simple(:x)) do
      parser = RisParser.new
      file = File.open(x.to_s,"r:UTF-8")
      contents = file.read
      file.close
      trans = RisParserTransform.new
      real_contents = contents[1..-1] #the first spot is taken up with nothing
      trans.apply(parser.parse(real_contents))
    end
  end
end
