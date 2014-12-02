module Flapjack
  class ArgumentValidator
    attr_reader :query

    def initialize(query = {})
      @errors = []
      @query = query
    end

    def validate(args)
      args = args.dup
      validations = args.delete(:as)
      validations = [validations] unless validations.is_a?(Array)

      elements = args[:query]

      unless elements.nil?
        elements = [elements] unless elements.is_a?(Array)
        validations.each {|v| __send__(v.to_s.downcase, *elements) }
      end

      raise(ArgumentError, @errors.join('; ')) unless @errors.empty?
    end

    private

    def valid_time_str?(str)
      Time.iso8601(str)
      true
    rescue ArgumentError
      false
    end

    def time(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || target.respond_to?(:iso8601) ||
          (target.is_a?(String) && valid_time_str?(target))
        @errors << "'#{target}' should be a time object or ISO " \
                   '8601-formatted string.'
      end
    end

    def boolean(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || [TrueClass, FalseClass].include?(target.class)
        @errors << "'#{target}' should be 'true' or 'false'."
      end
    end

    def array_of_strings(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(Array) &&
          target.all? {|t| t.is_a?(String) })
        @errors << "'#{target}' should be an Array of Strings."
      end
    end

    def required(*elements)
      elements.each do |element|
        next unless @query[element].nil?
        @errors << "'#{element}' is required."
      end
    end

    def respond_to?(name, include_private = false)
      !classify_name(name).nil? || super
    end

    def method_missing(name, *args)
      klass = classify_name(name)
      return super if klass.nil?
      elements = args
      elements.each do |element|
        next if @query[element].nil? || @query[element].is_a?(klass)
        @errors << "'#{element}' is expected to be a #{klass}"
      end
    end

    def classify_name(name)
      class_name = name.to_s.split('_').map(&:capitalize).join
      Module.const_get(class_name)
    rescue NameError
      nil
    end
  end
end
