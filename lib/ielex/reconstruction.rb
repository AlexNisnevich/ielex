module IELex
  # A subcategory of a semantic class.
  class Reconstruction < IELexObject
    extend IELexClass

    attr_accessor :protoform, :path, :description, :semantic_field
    attr_inspector :protoform, :path, :description

    def etymon
      begin
        @etymon_candidates ||= Scraper.instance.get(@path, [
          [:bold, "p[starts-with(b,'Pokorny')]/b[2]/text()"],
          [:last, "p[starts-with(b,'Pokorny')]/text()[last()]"]
        ])

        if @etymon_candidates[:bold] != ""
          @etymon_candidates[:bold]
        else
          @etymon_candidates[:last]
        end
      rescue
        ""
      end
    end

    def entries
      @lang = ''

      @reflexes ||= Scraper.instance.get_all(Entry, @path, [
        [:language, 'td[1]/text()', lambda {|l|
          l = l.encode Encoding.find('ASCII'), {:invalid => :replace, :undef => :replace, :replace => ' '}
          if l.strip != ''
            @lang = l.gsub(/:/, '')
          end
          @lang
        }],
        [:reflex, 'td[3]/span/text()'],
        [:pos, 'td[5]/text()'],
        [:gloss, 'td[7]/text()'],
        [:source, 'td[9]/text()'],
        [:protoform, nil, lambda {|x| self}]
      ]).select {|e| e.gloss.strip != '' && !e.gloss.include?('Tolkien')}
    end
  end
end
