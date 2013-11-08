module IELex
  # A semantic class containing a list of IELex reconstructed protoforms.
  class SemanticField < IELexObject
    extend IELexClass

    attr_accessor :name, :description, :path
    attr_inspector :name, :description, :path

    # Returns all Reconstructions corresponding to this SemanticField
    # @return [Array<Reconstruction>] array of Reconstructions corresponding to this SemanticField
    #def reconstructions
    #  @reconstructions ||= Scraper.instance.get_all(Reconstruction, @path, [
    #    [:path, 'td[1]/a/@href'],
    #    [:protoform, 'td[1]/a/text()'],
    #    [:description, 'td[2]/text()'],
    #    [:semantic_field, nil, lambda {|x| self}]
    #  ])
    #end

    # Returns all Subcategories corresponding to this SemanticField
    # @return [Array<Subcategory>] array of Subcategories corresponding to this SemanticField
    def subcategories
      @subcategories ||= Scraper.instance.get_all(Subcategory, @path, [
        [:code, 'text()'],
        [:name, 'a/text()'],
        [:path, 'a/@href'],
        [:semantic_field, nil, lambda {|x| self}]
      ], "ul")
    end

    def reconstructions
      subcategories
        .select {|s| s.path != ''}
        .map {|s| s.reconstructions}
        .inject(&:+)
    end

    # Returns all SemanticFields in IELex.
    # @return [Array<SemanticField>] array of SemanticFields in IELex
    def self.all
      @semantic_fields ||= Scraper.instance.get_all(SemanticField,
        "http://www.utexas.edu/cola/centers/lrc/iedocctr/ie-ling/ie-sem/index.html", [
        [:name, 'a/text()'],
        [:description, 'a/@title'],
        [:path, 'a/@href']
      ], "ol")
    end

    # Counts the number of SemanticFields within IELex
    # @return [Integer] number of SemanticFields in IELex
    def self.count
      self.all.count
    end

    # Looks up all SemanticFields matching a given name
    # @param name [String] term to search for
    # @return [Array<SemanticField>] array of SemanticFields matching the search term
    def self.find_by_name(name)
      self.all.select { |sf| sf.name.downcase.include?(name.downcase) }
    end
  end
end
