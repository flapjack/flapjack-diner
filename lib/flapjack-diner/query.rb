require 'flapjack-diner/utility'

module Flapjack
  module Diner
    module Query

      def self.validate_params(query = {}, &validation)
        return unless block_given?
        query = {} if [].eql?(query)
        case query
        when Array
          query.each do |q|
            ArgumentValidator.new(q).instance_eval(&validation)
          end
        else
          ArgumentValidator.new(query).instance_eval(&validation)
        end
      end

      # copied from Rack::Utils -- builds the query string for GETs
      def self.build_nested(value, prefix = nil)
        case value
        when Array
          build_array(value, prefix)
        when Hash
          build_hash(value, prefix)
        else
          build_data(value, prefix)
        end
      end

      # used for the JSON data hashes in POST, PUT, DELETE
      def self.prepare_nested(value)
        case value
        when Array
          prepare_array(value)
        when Hash
          prepare_hash(value)
        else
          prepare_data(value)
        end
      end

      def self.unwrap_uuids(*args)
        ids = args.select {|a| a.is_a?(String) }
        raise "IDs must be RFC 4122-compliant UUIDs" unless ids.all? {|id|
          id =~ /^#{Flapjack::Diner::UUID_RE}$/i
        }
        ids
      end

      def self.unwrap_data(*args)
        data = args.reject {|a| a.is_a?(String) || a.is_a?(Integer) }
        unless data.all? {|a| a.is_a?(Hash) }
          raise 'Data must be passed as a Hash, or multiple Hashes'
        end
        return Flapjack::Diner::Utility.symbolize(data.first) if data.size == 1
        data.each_with_object([]) {|d, o| o << Flapjack::Diner::Utility.symbolize(d) }
      end

      private

      def self.build_array(value, prefix)
        value.map {|v| build_nested(v, "#{prefix}[]") }.join('&')
      end

      def self.build_hash(value, prefix)
        value.map do |k, v|
          data = prefix ? "#{prefix}[#{k}]" : k
          build_nested(v, data)
        end.join('&')
      end

      def self.build_data(value, prefix)
        if value.respond_to?(:iso8601)
          raise(ArgumentError, 'Value must be a Hash') if prefix.nil?
          "#{escape(prefix)}=#{escape(value.iso8601)}"
        elsif value.is_a?(String) || value.is_a?(Integer)
          raise(ArgumentError, 'Value must be a Hash') if prefix.nil?
          "#{escape(prefix)}=#{escape(value.to_s)}"
        else
          prefix
        end
      end

      def self.escape(s)
        URI.encode_www_form_component(s)
      end

      def self.prepare_array(value)
        value.map {|v| prepare_nested(v) }
      end

      def self.prepare_hash(value)
        value.each_with_object({}) do |(k, v), a|
          a[k] = prepare_nested(v)
        end
      end

      def self.prepare_data(value)
        if value.respond_to?(:iso8601)
          value.iso8601
        else
          case value
          when Integer, TrueClass, FalseClass, NilClass
            value
          else
            value.to_s
          end
        end
      end
    end
  end
end
