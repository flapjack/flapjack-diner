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

    def uuid(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target =~ /^#{Flapjack::Diner::UUID_RE}$/i)
        @errors << "'#{target}' must be a RFC 4122-compliant UUID."
      end
    end

    def time(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || target.respond_to?(:iso8601) ||
          (target.is_a?(String) && valid_time_str?(target))
        @errors << "'#{target}' must be a time object or ISO " \
                   '8601-formatted String.'
      end
    end

    def boolean(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || [TrueClass, FalseClass].include?(target.class)
        @errors << "'#{target}' must be 'true' or 'false'."
      end
    end

    def positive_integer(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(Integer) && (target > 0))
        @errors << "'#{target}' must be an Integer greater than 0."
      end
    end

    def non_empty_string(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(String) && !target.empty?)
        @errors << "'#{target}' must be a non-empty String."
      end
    end

    def array_of_strings(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(Array) && !target.empty? &&
          target.all? {|t| t.is_a?(String) && !t.empty? })
        @errors << "'#{target}' must be an Array of non-empty Strings."
      end
    end

    def string_or_array_of_strings(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(String) && !target.empty?) ||
         (target.is_a?(Array) && !target.empty? &&
          target.all? {|t| t.is_a?(String) && !t.empty? })
        @errors << "'#{target}' must be a non-empty String, or an Array of non-empty Strings."
      end
    end

    def uuid_or_array_of_uuids(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(String) && (target =~ /^#{Flapjack::Diner::UUID_RE}$/i)) ||
         (target.is_a?(Array) && !target.empty? &&
          target.all? {|t| t.is_a?(String) && (t =~ /^#{Flapjack::Diner::UUID_RE}$/i)})
        @errors << "'#{target}' must be a RFC 4122-compliant UUID, or an Array of RFC 4122-compliant UUIDs."
      end
    end

    def hash(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(Hash) &&
          target.keys.all? {|t| (t.is_a?(String) && !t.empty?) || t.is_a?(Symbol) })
        @errors << "'#{target}' must be a Hash with String or Symbol keys."
      end
    end

    def singular_link_uuid(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(String) &&
          (target =~ /^#{Flapjack::Diner::UUID_RE}$/i))
        @errors << "'#{target}' association must be a RFC 4122-compliant UUID."
      end
    end

    def multiple_link_uuid(*elements)
      elements.each do |element|
        target = @query[element]
        next if target.nil? || (target.is_a?(Array) &&
          target.all? {|t| t =~ /^#{Flapjack::Diner::UUID_RE}$/i })
        @errors << "'#{target}' association must be an Array of RFC 4122-compliant UUIDs."
      end
    end

    def required(*elements)
      elements.each do |element|
        @errors << "'#{element}' is required." if @query[element].nil?
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
