module IELex
  # Superclass for IELex objects providing helper instance methods.
  class IELexObject
    # Initializes objects with a hash of attributes.
    # @see https://github.com/neweryankee/nextbus/blob/master/lib/instantiate_with_attrs.rb
    # @author neweryankee
    def initialize(attrs={})
      super()
      attrs.each do |name, value|
        setter = "#{name.to_s}=".to_sym
        self.send(setter, value) if self.respond_to?(setter)
      end
      self
    end

    # Overrides <tt>Object#inspect</tt> to only show the attributes defined
    # by <tt>IELexClass#attr_inspector</tt>.
    # @see IELexClass#attr_inspector
    def inspect
      inspectables = self.class.inspectables
      if inspectables
        "#<#{self.class}:0x#{object_id.to_s(16)} " + inspectables.map {|i| "@#{i}=\"#{send(i) rescue nil}\""}.join(' ') + ">"
      else
        super
      end
    end
  end

  # Provides helper class methods for IELex classes.
  module IELexClass
    attr_reader :inspectables

    # Defines the list of attributes whose values are displayed by <tt>IELexObject#inspect</tt>.
    # @param *attrs [Array<Symbol>] array of attribute labels
    # @see IELexObject#inspect
    def attr_inspector(*attrs)
      @inspectables = attrs
    end
  end
end
