require 'httparty'
require 'json'
require 'uri'
require 'cgi'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    SUCCESS_STATUS_CODES = [200, 201, 204]

    include HTTParty

    format :json

    class << self

      attr_accessor :logger

      # NB: clients will need to handle any exceptions caused by,
      # e.g., network failures or non-parseable JSON data.

      # 1: Contacts
      def create_contacts(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        data.each do |d|
          validate_params(d) do
            validate :query => [:first_name, :last_name, :email], :as => [:required, :string]
            validate :query => :timezone,   :as => :string
            validate :query => :tags,       :as => :array
          end
        end
        perform_post('/contacts', nil, :contacts => data)
      end

      def contacts(*ids)
        perform_get('/contacts', ids)
      end

      def update_contacts(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'update_contacts' requires at least one contact id parameter" if ids.nil? || ids.empty?
        validate_params(params) do
            validate :query => [:first_name, :last_name,
                                :email, :timezone], :as => :string
            validate :query => :tags,       :as => :array
        end
        ops = params.inject([]) do |memo, (k,v)|
          case k
          when :add_entity
            memo << {:op    => 'add',
                     :path  => '/contacts/0/links/entities/-',
                     :value => v}
          when :remove_entity
            memo << {:op    => 'remove',
                     :path  => '/contacts/0/links/entities/-',
                     :value => v}
          when :add_medium
            memo << {:op    => 'add',
                     :path  => '/contacts/0/links/media/-',
                     :value => v}
          when :remove_medium
            memo << {:op    => 'remove',
                     :path  => '/contacts/0/links/media/-',
                     :value => v}
          when :add_notification_rule
            memo << {:op    => 'add',
                     :path  => '/contacts/0/links/notification_rules/-',
                     :value => v}
          when :remove_notification_rule
            memo << {:op    => 'remove',
                     :path  => '/contacts/0/links/notification_rules/-',
                     :value => v}
          when :first_name, :last_name, :email, :timezone, :tags
            memo << {:op    => 'replace',
                     :path  => "/contacts/0/#{k.to_s}",
                     :value => v}
          end
          memo
        end
        raise "'update_contacts' did not find any valid update fields" if ops.empty?
        perform_patch("/contacts/#{escaped_ids(ids)}", nil, ops)
      end

      def delete_contacts(*ids)
        raise "'delete_contacts' requires at least one contact id parameter" if ids.nil? || ids.empty?
        perform_delete('/contacts', ids)
      end


      # 2: Media
      def create_contact_media(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'create_contact_media' requires at least one contact id parameter" if ids.nil? || ids.empty?
        data.each do |d|
          validate_params(d) do
            validate :query => [:type, :address], :as => [:required, :string]
            validate :query => [:interval, :rollup_threshold], :as => [:required, :integer]
          end
        end
        perform_post("/contacts/#{escaped_ids(ids)}/media", nil, :media => data)
      end

      def media(*ids)
        perform_get('/media', ids)
      end

      def update_media(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'update_media' requires at least one media id parameter" if ids.nil? || ids.empty?
        validate_params(params) do
          validate :query => :address,                       :as => :string
          validate :query => [:interval, :rollup_threshold], :as => :integer
        end
        ops = params.inject([]) do |memo, (k,v)|
          case k
          when :address, :interval, :rollup_threshold
            memo << {:op    => 'replace',
                     :path  => "/media/0/#{k.to_s}",
                     :value => v}
          end
          memo
        end
        raise "'update_media' did not find any valid update fields" if ops.empty?
        perform_patch("/media/#{escaped_ids(ids)}", nil, ops)
      end

      def delete_media(*ids)
        raise "'delete_media' requires at least one media id parameter" if ids.nil? || ids.empty?
        perform_delete('/media', ids)
      end


      # 3: Notification Rules
      def create_contact_notification_rules(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'create_contact_notification_rules' requires at least one contact id parameter" if ids.nil? || ids.empty?
        data.each do |d|
          validate_params(d) do
            # TODO check what goes here
          end
        end
        perform_post("/contacts/#{escaped_ids(ids)}/notification_rules", nil, :notification_rules => data)
      end

      def notification_rules(*ids)
        perform_get('/notification_rules', ids)
      end

      def update_notification_rules(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'update_notification_rules' requires at least one notification rule id parameter" if ids.nil? || ids.empty?
        validate_params(params) do
          # TODO check what goes here
        end
        ops = params.inject([]) do |memo, (k,v)|
          case k
          when :entities, :regex_entities, :tags, :regex_tags,
            :time_restrictions, :unknown_media, :warning_media, :critical_media,
            :unknown_blackhole, :warning_blackhole, :critical_blackhole

            memo << {:op    => 'replace',
                     :path  => "/notification_rules/0/#{k.to_s}",
                     :value => v}
          end
          memo
        end
        raise "'update_notification_rules' did not find any valid update fields" if ops.empty?
        perform_patch("/notification_rules/#{escaped_ids(ids)}", nil, ops)
      end

      def delete_notification_rules(*ids)
        raise "'delete_notification_rules' requires at least one notification rule id parameter" if ids.nil? || ids.empty?
        perform_delete('/notification_rules', ids)
      end


      # 4: Entities & 5: Checks
      def create_entities(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        data.each do |d|
          validate_params(d) do
            # TODO check what goes here
          end
        end
        perform_post('/entities', nil, :entities => data)
      end

      def entities(*ids)
        perform_get('/entities', ids)
      end

      def update_entities(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        raise "'update_entities' requires at least one entity id parameter" if ids.nil? || ids.empty?
        validate_params(params) do
          # TODO check what goes here
        end
        ops = params.inject([]) do |memo, (k,v)|
          case k
          when :name
            memo << {:op    => 'replace',
                     :path  => "/entities/0/#{k.to_s}",
                     :value => v}
          end
          memo
        end
        raise "'update_entities' did not find any valid update fields" if ops.empty?
        perform_patch("/entities/#{escaped_ids(ids)}", nil, ops)
      end

      ['entities', 'checks'].each do |data_type|

        define_method("create_scheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_scheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              validate :query => :start_time, :as => [:required, :time]
              validate :query => :duration, :as => [:required, :integer]
            end
          end
          perform_post("/scheduled_maintenances/#{data_type}", ids,
            :scheduled_maintenances => data)
        end

        define_method("create_unscheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_unscheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              # TODO check what goes here
            end
          end
          perform_post("/unscheduled_maintenances/#{data_type}", ids,
            :unscheduled_maintenances => data)
        end

        define_method("create_test_notifications_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_test_notifications_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              # TODO check what goes here
            end
          end
          perform_post("/test_notifications/#{data_type}", ids,
            :test_notifications => data)
        end

        define_method("delete_scheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'delete_scheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            # TODO check what goes here
          end
          perform_delete("/scheduled_maintenances/#{data_type}", ids, params)
        end

        define_method("delete_unscheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'delete_unscheduled_maintenances_#{data_type}' requires at least one #{data_type} id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            # TODO check what goes here
          end
          perform_delete("/unscheduled_maintenances/#{data_type}", ids, params)
        end
      end


      # 6: Reports
      def status_report_entities(*ids)
        perform_get('/status_report/entities', ids)
      end

      def status_report_checks(*ids)
        perform_get('/status_report/checks', ids)
      end

      ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|
        ['entities', 'checks'].each do |data_type|
          define_method("#{report_type}_report_#{data_type}") do |*args|
            ids, params, data = unwrap_ids_and_params(*args)
            validate_params(params) do
              validate :query => [:start_time, :end_time], :as => :time
            end
            perform_get("/#{report_type}_report/#{data_type}", ids, params)
          end
        end
      end

      def last_error
        @last_error
      end

      private

      def perform_get(path, ids = [], data = [])
        req_uri = build_uri(path, ids, data)
        logger.info "GET #{req_uri}" if logger
        response = get(req_uri.request_uri)
        handle_response(response)
      end

      def perform_post(path, ids = [], data = [])
        req_uri = build_uri(path, ids)
        if logger
          log_post = "POST #{req_uri}"
          log_post << "\n  Params: #{data.inspect}" if data
          logger.info log_post
        end
        opts = data ? {:body => prepare_nested_query(data).to_json, :headers => {'Content-Type' => 'application/vnd.api+json'}} : {}
        response = post(req_uri.request_uri, opts)
        handle_response(response)
      end

      def perform_patch(path, ids = [], data = [])
        req_uri = build_uri(path, ids)
        if logger
          log_patch = "PATCH #{req_uri}"
          log_patch << "\n  Params: #{data.inspect}" if data
          logger.info log_patch
        end
        opts = data ? {:body    => prepare_nested_query(data).to_json,
                       :headers => {'Content-Type' => 'application/json-patch+json'}} : {}
        response = patch(req_uri.request_uri, opts)
        handle_response(response)
      end

      def perform_delete(path, ids = [], data = [])
        req_uri = build_uri(path, ids, data)
        logger.info "DELETE #{req_uri}" if logger
        response = delete(req_uri.request_uri)
        handle_response(response)
      end

      def handle_response(response)
        response_body = response.body
        response_start = response_body ? response_body[0..300] : nil
        if logger
          response_message = " #{response.message}" unless (response.message.nil? || response.message == "")
          logger.info "  Response Code: #{response.code}#{response_message}"
          logger.info "  Response Body: #{response_start}" if response_start
        end
        parsed_response = response.respond_to?(:parsed_response) ? response.parsed_response : nil
        unless SUCCESS_STATUS_CODES.include?(response.code)
          self.last_error = {'status_code' => response.code}.merge(parsed_response)
          return nil
        end
        return true unless (response.code == 200) && parsed_response
        parsed_response
      end

      def validate_params(query = {}, &validation)
        ArgumentValidator.new(query).instance_eval(&validation) if block_given?
      end

      # copied from Rack::Utils -- builds the query string for GETs
      def build_nested_query(value, prefix = nil)
        if value.respond_to?(:iso8601)
          raise ArgumentError, "value must be a Hash" if prefix.nil?
          "#{prefix}=#{escape(value.iso8601)}"
        else
          case value
          when Array
            value.map { |v|
              build_nested_query(v, "#{prefix}[]")
            }.join("&")
          when Hash
            value.map { |k, v|
              build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
            }.join("&")
          when String, Integer
            raise ArgumentError, "value must be a Hash" if prefix.nil?
            "#{prefix}=#{escape(value.to_s)}"
          else
            prefix
          end
        end
      end

      def escaped_ids(ids = [])
        ids.collect{|id| CGI.escape(id.to_s)}.join(',')
      end

      def escape(s)
        URI.encode_www_form_component(s)
      end

      def unwrap_ids_and_params(*args)
        ids    = []
        params = {}
        data   = []

        args.each do |arg|
          case arg
          when Array
            raise "Array arguments may only contain data Hashes" unless arg.all? {|a| a.is_a?(Hash)}
            data += arg
          when Hash
            params.update(arg)
          when String, Integer
            ids << arg.to_s
          else
            raise "Arguments must be a Hash (parameters), String/Integer (ids), or Arrays of Hashes (data)"
          end
        end

        [ids, params, data]
      end

      # used for the JSON data hashes in POST, PUT, DELETE
      def prepare_nested_query(value)
        if value.respond_to?(:iso8601)
          value.iso8601
        else
          case value
          when Array
            value.map { |v| prepare_nested_query(v) }
          when Hash
            value.inject({}) do |memo, (k, v)|
              memo[k] = prepare_nested_query(v)
              memo
            end
          when Integer, TrueClass, FalseClass, NilClass
            value
          else
            value.to_s
          end
        end
      end

      def protocol_host_port
        self.base_uri =~ /^(?:(https?):\/\/)?([a-zA-Z0-9][a-zA-Z0-9\.\-]*[a-zA-Z0-9])(?::(\d+))?/i
        protocol = ($1 || 'http').downcase
        host = $2
        port = $3

        if port.nil? || port.to_i < 1 || port.to_i > 65535
          port = 'https'.eql?(protocol) ? 443 : 80
        else
          port = port.to_i
        end

        [protocol, host, port]
      end

      def build_uri(path, ids = [], params = [])
        pr, ho, po = protocol_host_port
        if !ids.nil? && !ids.empty?
          path += '/' + escaped_ids(ids)
        end
        URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => (params.nil? || params.empty? ? nil : build_nested_query(params)))
      end

      def last_error=(error)
        @last_error = error
      end
    end
  end
end
