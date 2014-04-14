require 'httparty'
require 'json'
require 'uri'
require 'cgi'

require "flapjack-diner/version"
require "flapjack-diner/argument_validator"

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
        validate_params(params) do
          # TODO check what goes here
        end
        perform_post('/contacts', nil, :contacts => data)
      end

      def contacts(*ids)
        perform_get('/contacts', ids)
      end

      def update_contact(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        validate_params(params) do
          # TODO check what goes here
        end

      end

      # def update_contact!(contact_id, contact)
      #   perform_put("/contacts/#{escape(contact_id)}", contact)
      # end

      # # PATCH /contacts/a346e5f8-8260-43bd-820b-fcb91ba6c940
      # # [{"op":"add","path":"/contacts/0/links/entities/-","value":"foo-app-01.example.com"}]
      # def add_entities_to_contact!(contact_id, entities)
      #   entities = [entities] if entities.respond_to?(:keys)
      #   entities.each do |entity_id|
      #     perform_patch("/contacts/#{escape(contact_id)}",
      #                   [{:op    => 'add',
      #                     :path  => '/contacts/0/links/entities/-',
      #                     :value => entity_id}])
      #   end
      # end

      # def delete_contact!(contact_id)
      #   perform_delete("/contacts/#{escape(contact_id)}")
      # end

      def delete_contacts(*ids)
        # TODO error if ids.empty?
        perform_delete('/contacts', ids)
      end


      # 2: Media
      def create_contact_media(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        validate_params(params) do
          # TODO check what goes here
        end
        # TODO raise err if ids.nil? or ids.empty?
        perform_post("/contacts/#{ids.join(',')}/media", nil, :media => data)
      end

      def media(*ids)
        perform_get('/media', ids)
      end

      # def update_contact_medium!(contact_id, media_type, media)
      #   # FIXME: make work with new jsonapi endpoints
      #   raise "unimplemented"
      #   #perform_put("/contacts/#{escape(contact_id)}/media/#{escape(media_type)}", media)
      # end

      def delete_media(*ids)
        # TODO error if ids.empty?
        perform_delete('/media', ids)
      end


      # 3: Notification Rules
      def create_contact_notification_rules(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        validate_params(params) do
          # TODO check what goes here
        end
        # TODO raise err if ids.nil? or ids.empty?
        perform_post("/contacts/#{ids.join(',')}/notification_rules", nil, :notification_rules => data)
      end

      def notification_rules(*ids)
        perform_get('/notification_rules', ids)
      end

      # def update_notification_rule!(rule_id, rule)
      #   perform_put("/notification_rules/#{escape(rule_id)}", {'notification_rules' => [rule]})
      # end

      def delete_notification_rules(*ids)
        # TODO error if ids.empty?
        perform_delete('/notification_rules', ids)
      end


      # 4: Entities
      def create_entities(*args)
        ids, params, data = unwrap_ids_and_params(*args)
        validate_params(params) do
          # TODO check what goes here
        end

        perform_post('/entities', nil, :entities => data)
      end

      def entities(*ids)
        perform_get('/entities', ids)
      end

      ['entities', 'checks'].each do |data_type|

        define_method("create_scheduled_maintenances_#{data_type}") do |*args|
          # ids, data = unwrap_ids_and_params(*args) do |params|
          #   validate_params(params) do
          #     validate :query => :start_time, :as => [:required, :time]
          #     validate :query => :duration, :as => [:required, :integer]
          #   end
          # end

          ids, params, data = unwrap_ids_and_params(*args)
          validate_params(params) do
            # TODO check what goes here
          end

          perform_post("/scheduled_maintenances/#{data_type}", ids,
            :scheduled_maintenances => data)
        end

        define_method("create_unscheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          validate_params(params) do
            # TODO check what goes here
          end
          perform_post("/unscheduled_maintenances/#{data_type}", ids,
            :unscheduled_maintenances => data)
        end

        define_method("create_test_notifications_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          validate_params(params) do
            # TODO check what goes here
          end
          perform_post("/test_notifications/#{data_type}", ids,
            :test_notifications => data)
        end

        define_method("delete_scheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          validate_params(params) do
            # TODO check what goes here
          end
          # TODO err if args.empty? or params.empty?
          perform_delete("/scheduled_maintenances/#{data_type}", ids, params)
        end

        define_method("delete_unscheduled_maintenances_#{data_type}") do |*args|
          ids, params, data = unwrap_ids_and_params(*args)
          validate_params(params) do
            # TODO check what goes here
          end
          # TODO err if args.empty?
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
        req_uri = build_uri(path, args)
        # if logger
        #   log_patch = "PATCH #{req_uri}"
        #   log_patch << "\n  Params: #{data.inspect}" if data
        #   logger.info log_patch
        # end
        # opts = data ? {:body    => prepare_nested_query(data).to_json,
        #                :headers => {'Content-Type' => 'application/json-patch+json'}} : {}
        # response = patch(req_uri.request_uri, opts)
        # handle_response(response)
      end

      def perform_put(path, ids = [], data = [])
        req_uri = build_uri(path, ids, data)
        if logger
          log_put = "PUT #{req_uri}"
          log_put << "\n  Params: #{data.inspect}" if data
          logger.info log_put
        end
        opts = data ? {:body => prepare_nested_query(data).to_json, :headers => {'Content-Type' => 'application/vnd.api+json'}} : {}
        response = put(req_uri.request_uri, opts)
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
            ids  << arg.to_s
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
          path += '/' + ids.collect{|id| id.to_s}.join(',')
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
