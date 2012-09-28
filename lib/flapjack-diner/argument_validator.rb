module Flapjack
  class ArgumentValidator
    module Helper
      def validate_all(validation_hash)
        @validations ||= []
        @validations << Proc.new do
          validate(validation_hash)
        end
      end
    end

    attr_reader :path, :query

    def initialize(path, query)
      @data = {
        :path => path,
        :query => query
      }

      @errors = []
    end

    def validate(args)
      args = args.dup
      validations = args.delete(:as)
      validations = [validations] unless validations.is_a?(Array)

      @data.keys.each do |key|
        if elements = args[key]
          elements = [elements] unless elements.is_a?(Array)
          validations.each do |validation|
            __send__(validation.to_s.downcase, key, elements)
          end
        end
      end

      raise ArgumentError.new(@errors.join(' ; ')) unless @errors.empty?
    end

    private

    def time(key, elements)
      elements.each do |element|
        if target = @data[key] && @data[key][element]
          @errors << "'#{target}' should contain some kind of time object which responds to." unless target.respond_to?(:iso8601)
        end
      end
    end

    def required(key, elements)
      elements.each do |element|
        @errors << "'#{element}' is required." if @data[key][element].nil?
      end
    end

    def method_missing(name, *args)
      if klass = classify_name(name)
        key, elements = args
        elements.each do |element|
          @errors << "'#{element}' is expected to be a #{klass}" unless @data[key][element].is_a?(klass)
        end
      else
        super
      end
    end

    def classify_name(name)
      class_name = name.to_s.split('_').map(&:capitalize).join
      Module.const_get(class_name)
    rescue NameError
    end
  end
end
