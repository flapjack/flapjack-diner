require 'set'
require 'uri'

require 'flapjack-diner/query'

module Flapjack
  module Diner
    class Request

      def initialize(type, path, opts = {})
        @type   = type
        @path   = path
        @ids    = opts.key?(:ids) ? opts[:ids] :
          (opts[:data].nil? ? nil : Flapjack::Diner::Query.unwrap_uuids(*opts[:data]))
        @data   = opts[:data].nil? ? nil : Flapjack::Diner::Query.unwrap_data(*opts[:data])
        @assoc  = opts[:assoc]

        unless @data.nil?
          validations = opts[:validations]
          unless validations.nil?
            Flapjack::Diner::Query.validate_params(@data) do
              validations.each_pair { |k,v| validate :query => k, :as => v }
            end
          end
        end

        validations_proc = opts[:validations_proc]
        validations_proc.call unless validations_proc.nil?
      end

      def post
        req_data = nil
        jsonapi_ext = ""

        case @data
        when Array
          req_data = @data.collect {|d| record_data(d, :post) }
          jsonapi_ext = "; ext=bulk"
        when Hash
          req_data = record_data(@data, :post)
        end
        req_uri = build_uri

        # TODO send current character encoding in content-type ?
        Flapjack::Diner.post(req_uri.request_uri,
          :body => Flapjack::Diner::Query.prepare_nested(:data => req_data).to_json,
          :headers => {'Content-Type' => "application/vnd.api+json#{jsonapi_ext}"})
      end

      def post_links
        @data = @ids.collect {|id| {:type => @type, :id => id}}
        @ids = nil
        req_uri = build_uri
        Flapjack::Diner.post(req_uri.request_uri,
          :body => Flapjack::Diner::Query.prepare_nested(:data => @data).to_json,
          :headers => {'Content-Type' => 'application/vnd.api+json'})
      end

      def get
        @data = @data.reduce({}, &:merge) if @data.is_a?(Array)
        if !@ids.nil? && (@ids.size > 1)
          if @data[:filter].nil?
            @data[:filter] = {:id => @ids}
          elsif !data[:filter].key?(:id)
            @data[:filter][:id] = @ids
          else
            @data[:filter][:id] |= @ids
          end
        end

        filt = @data.delete(:filter)
        unless filt.nil?
          @data[:filter] = filt.each_with_object([]) do |(k, v), memo|
            value = case v
            when Array, Set
              v.to_a.join("|")
            else
              v.to_s
            end
            memo << (@assoc.nil? ? "#{k}:#{value}" :  "#{@assoc}.#{k}:#{value}")
          end
        end

        incl = @data[:include]
        unless incl.nil?
          case incl
          when Array
            raise ArgumentError.new("Include parameters must not contain commas") if incl.any? {|i| i =~ /,/}
            @data[:include] = if @assoc.nil?
              incl.join(",")
            else
              incl.map {|i|
                if i.eql?(@assoc.to_s) || (i =~ /^#{@assoc}\./)
                  i
                else
                  "#{@assoc}.#{i}"
                end
              }.join(",")
            end
          when String
            raise ArgumentError.new("Include parameters must not contain commas") if incl =~ /,/
            unless @assoc.nil? || (incl.eql?(@assoc.to_s)) || (incl =~ /^#{@assoc}\./)
              @data[:include] = "#{@assoc}.#{incl}"
            end
          end
        end

        req_uri = build_uri(@data)
        Flapjack::Diner.get(req_uri.request_uri)
      end

      def patch
        req_uri = nil
        req_data = nil

        jsonapi_ext = ""
        case @data
        when Hash
          raise "Update data does not contain :id" unless @data[:id]
          req_data = record_data(@data, :patch)
          @ids = [@data[:id]]
          req_uri = build_uri
        when Array
          ids = []
          req_data = []
          @data.each do |d|
            d_id = d.key?(:id) ? d[:id] : nil
            @ids << d_id unless d_id.nil? || d_id.empty?
            req_data << record_data(d, :patch)
          end
          raise "Update data must each contain :id" unless @ids.size == @data.size
          req_uri = build_uri
          jsonapi_ext = "; ext=bulk"
        end

        opts = if req_data.nil?
                 {}
               else
                 {:body => Flapjack::Diner::Query.prepare_nested(:data => req_data).to_json,
                  :headers => {'Content-Type' => "application/vnd.api+json#{jsonapi_ext}"}}
               end
        Flapjack::Diner.patch(req_uri.request_uri, opts)
      end

      def patch_links
        # data = if opts[:single]
        #   raise "Must provide one ID for a singular link" unless @ids.size == 1
        #   [nil].eql?(@ids) ? nil : {:type => @type, :id => @ids.first}
        # else
        data = [[]].eql?(@ids) ? [] : @ids.collect {|id| {:type => @type, :id => id}}
        # end
        @ids = nil

        req_uri = build_uri

        opts = {:body => Flapjack::Diner::Query.prepare_nested(:data => data).to_json,
                :headers => {'Content-Type' => 'application/vnd.api+json'}}
        Flapjack::Diner.patch(req_uri.request_uri, opts)
      end

      def delete
        type = Flapjack::Diner::Configuration::RESOURCES[@type][:resource]

        req_uri = build_uri
        opts = if @ids.size == 1
                 {}
               else
                 data = @ids.collect {|id| {:type => type, :id => id} }
                 {:body => Flapjack::Diner::Query.prepare_nested(:data => data).to_json,
                  :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'}}
               end
        Flapjack::Diner.delete(req_uri.request_uri, opts)
      end

      def delete_links
        data = @ids.collect {|id| {:type => @type, :id => id}}
        @ids = nil
        req_uri = build_uri
        opts = {:body => Flapjack::Diner::Query.prepare_nested(:data => data).to_json,
                :headers => {'Content-Type' => 'application/vnd.api+json'}}
        Flapjack::Diner.delete(req_uri.request_uri, opts)
      end

      private

      def record_data(source, method)
        res = Flapjack::Diner::Configuration::RESOURCES[@type]
        r_type = res[:resource]

        req_data = {}
        ['id', :id].each do |i|
          req_data[:id] = source[i] if source.key?(i)
        end
        req_data[:type] = r_type

        assocs = res[:relationships] || {}

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
        attrs = source.reject do |k, _|
          excluded.include?(k.to_sym)
        end

        req_data[:attributes] = attrs unless attrs.empty?

        rel_data = {}

        rel_singular.each do |singular_link|
          converted = false
          [singular_link, singular_link.to_s].each do |sl|
            next if converted || !source.key?(sl)
            rel_data[singular_link] = {
              :data => {
                :type => singular_link.to_s,
                :id => source[sl]
              }
            }
            converted = true
          end
        end

        rel_multiple.each do |multiple_link|
          converted = false
          ml_type = Flapjack::Diner::Configuration::RESOURCES[multiple_link][:resource]
          [multiple_link, multiple_link.to_s].each do |ml|
            next if converted || !source.key?(ml)
            rel_data[multiple_link] = {
              :data => source[ml].map {|id| {:type => ml_type, :id => id} }
            }
            converted = true
          end
        end

        req_data[:relationships] = rel_data unless rel_data.empty?

        req_data
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
        }ix =~ Flapjack::Diner.base_uri

        protocol = protocol.nil? ? 'http' : protocol.downcase
        [protocol, host, normalise_port(port, protocol)]
      end

      def build_uri(params = [])
        pr, ho, po = protocol_host_port
        @path += "/#{URI.escape(@ids.first.to_s)}" if !@ids.nil? && @ids.size == 1
        params = params.reduce({}, &:merge) if params.is_a?(Array)
        query = params.empty? ? nil : Flapjack::Diner::Query.build_nested(params)
        URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
                        :path => @path, :query => query)
      end
    end
  end
end
