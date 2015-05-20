require 'uri'

module Flapjack
  module Diner
    module Tools
      SUCCESS_STATUS_CODES = [200, 201, 204]

      attr_accessor :last_error, :context

      private

      def log_request(method_type, req_uri, data = nil)
        return if logger.nil? || req_uri.nil?
        log_msg = "#{method_type} #{req_uri}"
        unless %w(GET DELETE).include?(method_type) || data.nil?
          log_msg << "\n  Body: #{data.inspect}"
        end
        logger.info log_msg
      end

      def perform_get(path, ids = [], data = {})
        @last_error = nil
        @context = nil

        data = data.reduce({}, &:merge) if data.is_a?(Array)
        if (ids.size > 1)
          if data[:filter].nil?
            data[:filter] = {:id => ids}
          elsif !data[:filter].has_key?(:id)
            data[:filter][:id] = ids
          else
            data[:filter][:id] |= ids
          end
        end

        filt = data.delete(:filter)
        unless filt.nil?
          data[:filter] = filt.each_with_object([]) do |(k, v), memo|
            value = case v
            when Array, Set
              v.to_a.join("|")
            else
              v.to_s
            end
            memo << "#{k}:#{value}"
          end
        end

        req_uri = build_uri(path, ids, data)
        log_request('GET', req_uri, data)
        handle_response(get(req_uri.request_uri))
      end

      def populate_link_data(data, links)
        link_data = {}

        if links.has_key?(:singular)
          links[:singular].each do |singular_link|
            converted = false
            [singular_link, singular_link.to_s].each do |sl|
              if data.has_key?(sl)
                sl_data = data.delete(sl)
                link_data[singular_link] = {:linkage => {:type => singular_link.to_s, :id => sl_data}}
                converted = true
              end
            end
            next if converted
          end
        end

        if links.has_key?(:multiple)
          links[:multiple].each do |multiple_link|
            converted = false
            ml_type = Flapjack::Diner::Resources::Links::TYPES[multiple_link]
            [multiple_link, multiple_link.to_s].each do |ml|
              if data.has_key?(ml)
                ml_data = data.delete(ml)
                link_data[multiple_link] = {:linkage => ml_data.map {|id|
                  {:type => ml_type, :id => id}}
                }
                converted = true
              end
            end
            next if converted
          end
        end

        data[:links] = link_data unless link_data.empty?
      end

      def perform_post(type, path, data = {})
        @last_error = nil
        @context = nil
        links = Flapjack::Diner::Resources::Links::ASSOCIATIONS[type]
        type  = Flapjack::Diner::Resources::Links::TYPES[type]
        jsonapi_ext = ""
        case data
        when Array
          data.each do |d|
            d[:type] = type
            populate_link_data(d, links[:read_write]) unless links.nil?
          end
          jsonapi_ext = "; ext=bulk"
        when Hash
          data[:type] = type
          populate_link_data(data, links[:read_write]) unless links.nil?
        end
        req_uri = build_uri(path)
        log_request('POST', req_uri, :data => data)

        # TODO send current character encoding in content-type ?
        opts = {:body => prepare_nested_query(:data => data).to_json,
                :headers => {'Content-Type' => "application/vnd.api+json#{jsonapi_ext}"}}
        handle_response(post(req_uri.request_uri, opts))
      end

      def perform_post_links(type, path, *ids)
        @last_error = nil
        @context = nil
        data = ids.collect {|id| {:type => type, :id => id}}
        req_uri = build_uri(path)
        log_request('POST', req_uri, :data => data)
        opts = {:body => prepare_nested_query(:data => data).to_json,
                :headers => {'Content-Type' => 'application/vnd.api+json'}}
        handle_response(post(req_uri.request_uri, opts))
      end

      def perform_patch(type, path, data = nil)
        @last_error = nil
        @context = nil
        links = Flapjack::Diner::Resources::Links::ASSOCIATIONS[type]
        type = Flapjack::Diner::Resources::Links::TYPES[type]

        req_uri = nil

        jsonapi_ext = ""
        case data
        when Hash
          raise "Update data does not contain :id" unless data[:id]
          data[:type] = type
          populate_link_data(data, links[:read_write]) unless links.nil?
          ids = [data[:id]]
          req_uri = build_uri(path, ids)
        when Array
          ids = []
          data.each do |d|
            d[:type] = type
            populate_link_data(d, links[:read_write]) unless links.nil?
            d_id = d[:id]
            ids << d_id unless d_id.nil? || d_id.empty?
          end
          raise "Update data must each contain :id" unless ids.size == data.size
          req_uri = build_uri(path)
          jsonapi_ext = "; ext=bulk"
        end

        log_request('PATCH', req_uri, :data => data)

        opts = if data.nil?
                 {}
               else
                 {:body => prepare_nested_query(:data => data).to_json,
                  :headers => {'Content-Type' => "application/vnd.api+json#{jsonapi_ext}"}}
               end
        handle_response(patch(req_uri.request_uri, opts))
      end

      def perform_patch_links(type, path, single, *ids)
        @last_error = nil
        @context = nil
        data = if single
          raise "Must provide one ID for a singular link" unless ids.size == 1
          [nil].eql?(ids) ? nil : {:type => type, :id => ids.first}
        else
          [[]].eql?(ids) ? [] : ids.collect {|id| {:type => type, :id => id}}
        end

        req_uri = build_uri(path)

        opts = {:body => prepare_nested_query(:data => data).to_json,
                :headers => {'Content-Type' => 'application/vnd.api+json'}}
        log_request('PATCH', req_uri, opts)
        handle_response(patch(req_uri.request_uri, opts))
      end

      def perform_delete(type, path, *ids)
        @last_error = nil
        @context = nil
        type = Flapjack::Diner::Resources::Links::TYPES[type]

        req_uri = build_uri(path, ids)
        opts = if ids.size == 1
                 {}
               else
                 data = ids.collect {|id| {:type => type, :id => id} }
                 {:body => prepare_nested_query(:data => data).to_json,
                  :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'}}
               end
        log_request('DELETE', req_uri, opts)
        handle_response(delete(req_uri.request_uri, opts))
      end

      def perform_delete_links(type, path, *ids)
        @last_error = nil
        @context = nil
        req_uri = build_uri(path)
        data = ids.collect {|id| {:type => type, :id => id}}
        opts = {:body => prepare_nested_query(:data => data).to_json,
                :headers => {'Content-Type' => 'application/vnd.api+json'}}
        log_request('DELETE', req_uri, opts)
        handle_response(delete(req_uri.request_uri, opts))
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
        strify = return_keys_as_strings.is_a?(TrueClass)
        if [200, 201].include?(response.code)
          return handle_response_data(parsed, 'data', strify)
        end
        @last_error = handle_response_data(parsed, 'errors', strify)
        nil
      end

      def handle_response_data(parsed, key, strify)
        return parsed if parsed.nil? || !parsed.is_a?(Hash) ||
          !parsed.has_key?(key)
        @context = {}
        (['included', 'links', 'meta'] & parsed.keys).each do |k|
          c = parsed[k]
          @context[k.to_sym] = (strify ? c : symbolize(c))
        end
        parsed = parsed[key]
        return parsed if strify
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
          data = prefix ? "#{prefix}[#{k}]" : k
          build_nested_query(v, data)
        end.join('&')
      end

      def build_data_query(value, prefix)
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

      def escape(s)
        URI.encode_www_form_component(s)
      end

      def unwrap_ids(*args)
        args.select {|a| a.is_a?(String) || a.is_a?(Integer) }
      end

      def unwrap_uuids(*args)
        ids = args.select {|a| a.is_a?(String) || a.is_a?(Integer) }
        raise "IDs must be RFC 4122-compliant UUIDs" unless ids.all? {|id|
          id =~ /^#{Flapjack::Diner::UUID_RE}$/i
        }
        ids
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
         if ids.size == 1
          path += "/#{URI.escape(ids.first.to_s)}"
        end
        params = params.reduce({}, &:merge) if params.is_a?(Array)
        query = params.empty? ? nil : build_nested_query(params)
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
