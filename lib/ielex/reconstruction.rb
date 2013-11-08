module IELex
  # A subcategory of a semantic class.
  class Reconstruction < IELexObject
    extend IELexClass

    attr_accessor :protoform, :path, :description, :semantic_field
    attr_inspector :protoform, :path, :description
  end
end
