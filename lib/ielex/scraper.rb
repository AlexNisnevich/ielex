module IELex
  # Singleton object for scraping IEL, caching the results, and extracting data.
  class Scraper
    include Singleton

    attr_accessor :verbose

    # Instantiates a cache of size 100 for storing scraped pages.
    def initialize()
      @cache = LRUCache.new(:max_size => 100, :default => nil)
      @verbose = false
    end

    # Opens the given Pollex page, either by retrieving it from the cache
    # or by making a request with Nokogiri and then storing it in the cache.
    # @param path [String] relative path from <tt>http://pollex.org.nz</tt>
    # @return [Nokogiri::HTML::Document] the requested page, parsed with Nokogiri
    def open_with_cache(path)
      if @cache[path]
        if @verbose
          puts "Opening cached contents of #{path} ..."
        end
        @cache[path]
      else
        if @verbose
          puts "Connecting to #{path} ..."
        end
        page = Nokogiri::HTML(open("#{path}"))
        @cache[path] = page
        page
      end
    end

    # Gets arbitrary data from a page, with optional post-processing.
    # @param path [String] absolute path
    # @param attr_infos [Array<Array<Symbol, String, (Proc, nil)>>] an array that,
    #   for each element to be scraped, contains an array of:
    #   * a key for the element
    #   * the XPath to the element, from the <tt>div#content</tt> tag of the page
    #   * (optionally) a Proc to be performed on the element's contents
    # @return [Array<Symbol, String>] array of key-value pairs
    # @example Return information about the level of a given reconstruction
    #   Scraper.instance.get(@reconstruction_path, [
    #     [:level_token, "table[1]/tr[2]/td/a/text()", lambda {|x| x.split(':')[0]}],
    #     [:level_path, "table[1]/tr[2]/td/a/@href"]
    #   ])
    def get(path, attr_infos)
      page = open_with_cache(path)
      contents = page.css('#contentmain')

      attrs = {}
      attr_infos.each do |name, xpath, post_processor|
        attrs[name] = ''
        if xpath
          attrs[name] = contents.at_xpath(xpath).to_s.strip
        end
        if post_processor
          attrs[name] = post_processor.call(attrs[name])
        end
      end
      attrs
    end

    # Gets all elements from a table within a page, with optional post-processing.
    # The results are returned as either an array of key-value pairs or as an
    # array of objects, if a klass is specifed. If more than one page of results is
    # found, the first page of results is returned as a PaginatedArray.
    # @param klass [Class] (optional) class of objects to be instantiated
    # @param path [String] absolute path
    # @param attr_infos [Array<Array<Symbol, String, (Proc, nil)>>] an array that,
    #   for each element to be scraped, contains an array of:
    #   * a key for the element
    #   * the XPath to the element, from a given table
    #   * (optionally) a Proc to be performed on the element's contents
    # @param table_num [Integer] the number of the table on the page to process
    #   (default: 0 - that is, the first table on the page)
    # @return [Array<klass>] if a klass is specified
    # @return [Array<Array<Symbol, String>>] if no klass is specified
    # @example Return an array of all SemanticFields in Pollex
    #   Scraper.instance.get_all(SemanticField, "/category/", [
    #     [:id, 'td[1]/a/text()'],
    #     [:path, 'td[1]/a/@href'],
    #     [:name, 'td[2]/a/text()'],
    #     [:count, 'td[3]/text()']
    #   ])
    def get_all(klass, path, attr_infos, elt = "table", elt_num = 0)
      page = open_with_cache(path)
      contents = page.css('#contentmain')

      if elt == "table"
        rows = contents.css('table')[elt_num].css('tr')
        rows = rows[1..-1]
      elsif ["ol", "ul"].include? elt
        rows = contents.css(elt)[elt_num].css('li')
      end

      results = rows.map do |row|
        attrs = {}
        attr_infos.each do |name, xpath, post_processor|
          attrs[name] = ''
          if xpath
            attrs[name] = row.at_xpath(xpath).to_s.strip
          end
          if post_processor
            attrs[name] = post_processor.call(attrs[name])
          end
        end
        attrs
      end

      if klass
        results.map! {|x| klass.new(x) }
      end

      results
    end
  end
end
