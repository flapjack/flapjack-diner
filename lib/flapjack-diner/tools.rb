require 'uri'

module Flapjack
  module Diner
    module Tools
      SUCCESS_STATUS_CODES = [200, 201, 204]

      attr_accessor :last_error

      private

      def log_request(method_type, req_uri, data = nil)
        return if logger.nil? || req_uri.nil?
        log_msg = "#{method_type} #{req_uri}"
        unless %w(GET DELETE).include?(method_type) || data.nil?
          log_msg << "\n  Body: #{data.inspect}"
        end
        logger.info log_msg
      end

      def perform_get(name, path, ids = [], data = nil)
        @last_error = nil
        req_uri = build_uri(path, ids, data)
        log_request('GET', req_uri, data)
        handled = handle_response(get(req_uri.request_uri))

        result = (!handled.nil? && handled.is_a?(Hash)) ? handled[name] :
                 handled

        return_keys_as_strings.is_a?(TrueClass) ? result : symbolize(result)
      end

      def perform_post(name, path, data = nil)
        @last_error = nil
        req_uri = build_uri(path)
        log_request('POST', req_uri, name.to_sym => data)
        opts = if data.nil?
                 {}
               else
                 {:body => prepare_nested_query(name.to_sym => data).to_json,
                  :headers => {'Content-Type' => 'application/vnd.api+json'}}
               end
        handled = handle_response(post(req_uri.request_uri, opts))

        result = (!handled.nil? && handled.is_a?(Hash)) ? handled[name.to_s] :
                 handled

        return_keys_as_strings.is_a?(TrueClass) ? result : symbolize(result)
      end

      def perform_put(name, path, data = nil)
        @last_error = nil

        case data
        when Hash
          raise "Update data does not contain :id" unless data[:id]
          ids = [data[:id]]
        when Array
          ids = data.each_with_object([]) do |d, o|
            d_id = d[:id]
            o << d_id unless d_id.nil? || d_id.empty?
          end
          raise "Update data must each contain :id" unless ids.size == data.size
        end

        req_uri = build_uri(path, ids)
        log_request('PUT', req_uri, name.to_sym => data)

        opts = if data.nil?
                 {}
               else
                 {:body => prepare_nested_query(name.to_sym => data).to_json,
                  :headers => {'Content-Type' => 'application/vnd.api+json'}}
               end
        handled = handle_response(put(req_uri.request_uri, opts))

        result = (!handled.nil? && handled.is_a?(Hash)) ? handled[name.to_s] :
                 handled

        return_keys_as_strings.is_a?(TrueClass) ? result : symbolize(result)
      end

      def perform_delete(path, ids = [], data = nil)
        @last_error = nil
        req_uri = build_uri(path, ids, data)
        log_request('DELETE', req_uri, data)
        handle_response(delete(req_uri.request_uri))
      end

      def log_response(response)
        return if logger.nil? || !response.respond_to?(:code)
        response_message = "  Response Code: #{response.code}"
        unless response.message.nil? || (response.message.eql?(''))
          response_message << " #{response.message}"
        end
        logger.info response_message
        return if response.body.nil?
        logger.info "  Response Body: #{response.body[0..300]}"
      end

      def handle_response(response)
        log_response(response)
        return true if 204.eql?(response.code)
        parsed = if response.respond_to?(:parsed_response)
                   response.parsed_response
                 else
                   nil
                 end
        return parsed if [200, 201].include?(response.code)
        @last_error = handle_error(response.code, parsed)
        nil
      end

      def handle_error(code, parsed)
        return parsed unless parsed.is_a?(Hash)
        parsed = parsed['errors'] if parsed.has_key?('errors')
        return parsed if return_keys_as_strings.is_a?(TrueClass)
        symbolize(parsed)
      end

      def validate_params(query = {}, &validation)
        return unless block_given?
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
      def build_nested_query(value, prefix = nil)
        case value
        when Array
          build_array_query(value, prefix)
        when Hash
          build_hash_query(value, prefix)
        else
          build_data_query(value, prefix)
        end
      end

      def build_array_query(value, prefix)
        value.map {|v| build_nested_query(v, "#{prefix}[]") }.join('&')
      end

      def build_hash_query(value, prefix)
        value.map do |k, v|
          data = prefix ? "#{prefix}[#{escape(k)}]" : escape(k)
          build_nested_query(v, data)
        end.join('&')
      end

      def build_data_query(value, prefix)
        if value.respond_to?(:iso8601)
          raise(ArgumentError, 'Value must be a Hash') if prefix.nil?
          "#{prefix}=#{escape(value.iso8601)}"
        elsif value.is_a?(String) || value.is_a?(Integer)
          raise(ArgumentError, 'Value must be a Hash') if prefix.nil?
          "#{prefix}=#{escape(value.to_s)}"
        else
          prefix
        end
      end

      def escaped_ids(ids = [])
        ids.map {|id| URI.escape(id.to_s) }.join(',')
      end

      def escape(s)
        URI.encode_www_form_component(s)
      end

      def unwrap_ids(*args)
        args.select {|a| a.is_a?(String) || a.is_a?(Integer) }
      end

      def unwrap_data(*args)
        data = args.reject {|a| a.is_a?(String) || a.is_a?(Integer) }
        raise "Data must be passed as a Hash, or multiple Hashes" unless data.all? {|a| a.is_a?(Hash) }
        return symbolize(data.first) if data.size == 1
         data.each_with_object([]) {|d, o| o << symbolize(d) }
      end

      # used for the JSON data hashes in POST, PUT, DELETE
      def prepare_nested_query(value)
        case value
        when Array
          prepare_array_query(value)
        when Hash
          prepare_hash_query(value)
        else
          prepare_data_query(value)
        end
      end

      def prepare_array_query(value)
        value.map {|v| prepare_nested_query(v) }
      end

      def prepare_hash_query(value)
        value.each_with_object({}) do |(k, v), a|
          a[k] = prepare_nested_query(v)
        end
      end

      def prepare_data_query(value)
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

      def normalise_port(port_str, protocol)
        if port_str.nil? || port_str.to_i < 1 || port_str.to_i > 65_535
          'https'.eql?(protocol) ? 443 : 80
        else
          port_str.to_i
        end
      end

      def protocol_host_port
        %r{^(?:(?<protocol>https?)://)
           (?<host>[a-zA-Z0-9][a-zA-Z0-9\.\-]*[a-zA-Z0-9])
           (?::(?<port>\d+))?
        }ix =~ base_uri

        protocol = protocol.nil? ? 'http' : protocol.downcase
        [protocol, host, normalise_port(port, protocol)]
      end

      def build_uri(path, ids = [], params = [])
        pr, ho, po = protocol_host_port
        path += '/' + escaped_ids(ids) unless ids.nil? || ids.empty?
        query = if params.nil? || params.empty?
                  nil
                else
                  build_nested_query(params)
                end
        URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => query)
      end

      def symbolize(obj)
        case obj
        when Hash
          obj.each_with_object({}) {|(k, v), a| a[k.to_sym] = symbolize(v) }
        when Array
          obj.each_with_object([]) {|e, a| a << symbolize(e) }
        else
          obj
        end
      end
    end
  end
end
