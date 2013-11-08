module IELex
  # A subcategory of a semantic class.
  class Entry < IELexObject
    extend IELexClass

    attr_accessor :language, :reflex, :pos, :gloss, :source, :protoform
    attr_inspector :language, :reflex, :pos, :gloss, :source
  end
end
