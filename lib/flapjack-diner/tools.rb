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

      def perform_get(path, ids = [], data = {}, opts = {})
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
            if opts[:assoc].nil?
              memo << "#{k}:#{value}"
            else
              memo << "#{opts[:assoc]}.#{k}:#{value}"
            end
          end
        end

        incl = data[:include]
        unless incl.nil?
          case incl
          when Array
            raise ArgumentError.new("Include parameters must not contain commas") if incl.any? {|i| i =~ /,/}
            data[:include] = if opts[:assoc].nil?
              incl.join(",")
            else
              incl.map {|i|
                if i.eql?(opts[:assoc].to_s) || (i =~ /^#{opts[:assoc]}\./)
                  i
                else
                  "#{opts[:assoc]}.#{i}"
                end
              }.join(",")
            end
          when String
            raise ArgumentError.new("Include parameters must not contain commas") if incl =~ /,/
            unless opts[:assoc].nil? || (incl.eql?(opts[:assoc].to_s)) || (incl =~ /^#{opts[:assoc]}\./)
              data[:include] = "#{opts[:assoc]}.#{incl}"
            end
          end
        end

        req_uri = build_uri(path, ids, data)
        log_request('GET', req_uri, data)
        handle_response(get(req_uri.request_uri))
      end

      def record_data(source, type, method)
        r_type  = Flapjack::Diner::Resources::Relationships::TYPES[type]
        req_data = {}
        ['id', :id].each do |i|
          req_data[:id] = source[i] if source.has_key?(i)
        end
        req_data[:type] = r_type

        assocs = Flapjack::Diner::Resources::Relationships::ASSOCIATIONS[type] || {}

        rel_singular = assocs.inject([]) do |memo, (assoc_name, assoc)|
          if assoc[method].is_a?(TrueClass) && :singular.eql?(assoc[:number])
            memo << assoc_name
          end
          memo
        end

        rel_multiple = assocs.inject([]) do |memo, (assoc_name, assoc)|
          if assoc[method].is_a?(TrueClass) && :multiple.eql?(assoc[:number])
            memo << assoc_name
          end
          memo
        end

        excluded = [:id, :type] + rel_singular + rel_multiple
        attrs = source.reject do |k,v|
          excluded.include?(k.to_sym)
        end

        req_data[:attributes] = attrs unless attrs.empty?

        rel_data = {}

        rel_singular.each do |singular_link|
          converted = false
          [singular_link, singular_link.to_s].each do |sl|
            next if converted || !source.has_key?(sl)
            rel_data[singular_link] = {:data => {:type => singular_link.to_s, :id => source[sl]}}
            converted = true
          end
        end

        rel_multiple.each do |multiple_link|
          converted = false
          ml_type = Flapjack::Diner::Resources::Relationships::TYPES[multiple_link]
          [multiple_link, multiple_link.to_s].each do |ml|
            next if converted || !source.has_key?(ml)
            rel_data[multiple_link] = {
              :data =>  source[ml].map {|id|
                {:type => ml_type, :id => id}
              }
            }
            converted = true
          end
        end

        req_data[:relationships] = rel_data unless rel_data.empty?

        req_data
      end

      def perform_post(type, path, data = {})
        @last_error = nil
        @context = nil

        jsonapi_ext = ""
        req_data = nil

        case data
        when Array
          req_data = data.collect {|d| record_data(d, type, :post) }
          jsonapi_ext = "; ext=bulk"
        when Hash
          req_data = record_data(data, type, :post)
        end
        req_uri = build_uri(path)
        log_request('POST', req_uri, :data => req_data)

        # TODO send current character encoding in content-type ?
        opts = {:body => prepare_nested_query(:data => req_data).to_json,
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

        req_uri = nil
        req_data = nil

        jsonapi_ext = ""
        case data
        when Hash
          raise "Update data does not contain :id" unless data[:id]
          req_data = record_data(data, type, :patch)
          ids = [data[:id]]
          req_uri = build_uri(path, ids)
        when Array
          ids = []
          req_data = []
          data.each do |d|
            d_id = d.has_key?(:id) ? d[:id] : nil
            ids << d_id unless d_id.nil? || d_id.empty?
            req_data << record_data(d, type, :patch)
          end
          raise "Update data must each contain :id" unless ids.size == data.size
          req_uri = build_uri(path)
          jsonapi_ext = "; ext=bulk"
        end

        log_request('PATCH', req_uri, :data => req_data)

        opts = if req_data.nil?
                 {}
               else
                 {:body => prepare_nested_query(:data => req_data).to_json,
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
        type = Flapjack::Diner::Resources::Relationships::TYPES[type]

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
          return handle_response_data(parsed, strify)
        end
        @last_error = handle_response_errors(parsed, strify)
        nil
      end

      def flatten_jsonapi_data(data, opts = {})
        ret = nil
        case data
        when Array
          ret = data.inject([]) do |memo, d|
            attrs = d['attributes'] || {}
            d.each_pair do |k, v|
              next if 'attributes'.eql?(k)
              attrs.update(k => v)
            end
            memo += [attrs]
            memo
          end
        when Hash
          ret = data['attributes'] || {}
          data.each_pair do |k, v|
            next if 'attributes'.eql?(k)
            ret.update(k => v)
          end
        else
          ret = data
        end
        ret
      end

      def handle_response_errors(parsed, strify)
        return parsed if parsed.nil? || !parsed.is_a?(Hash) ||
         !parsed.has_key?('errors')
        errs = parsed['errors']
        strify ? errs : symbolize(errs)
      end

      def handle_response_data(parsed, strify)
        return parsed if parsed.nil? || !parsed.is_a?(Hash) ||
          !parsed.has_key?('data')
        @context = {}
        if parsed.has_key?('included')
          incl = flatten_jsonapi_data(parsed['included'], :allow_relationships => true)
          @context[:included] = (strify ? incl : symbolize(incl))
        end
        (['relationships', 'meta'] & parsed.keys).each do |k|
          c = parsed[k]
          @context[k.to_sym] = (strify ? c : symbolize(c))
        end
        ret = flatten_jsonapi_data(parsed['data'], :allow_relationships => false)
        strify ? ret : symbolize(ret)
      end

      def validate_params(query = {}, &validation)
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
