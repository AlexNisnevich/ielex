module IELex
  # A subcategory of a semantic class.
  class Subcategory < IELexObject
    extend IELexClass

    attr_accessor :name, :code, :path, :semantic_field
    attr_inspector :name, :code, :path

    # Returns all Reconstructions corresponding to this Subcategory
    # @return [Array<Reconstruction>] array of Reconstructions corresponding to this Subcategory
    def reconstructions
      @reconstructions ||= Scraper.instance.get_all(Reconstruction, @path, [
        [:protoform, 'span', lambda {|x| Nokogiri::HTML(x).text}],
        [:path, 'a[4]/@href'],
        [:description, 'self::li', lambda {|x|
          Nokogiri::HTML(x)
            .text
            .encode('UTF-8', 'UTF-8', :invalid => :replace)
            .match(/'(.*)'/)[1]
        }],
        [:semantic_field, nil, lambda {|x| @semantic_field}]
      ], "ul")
    end
  end
end
