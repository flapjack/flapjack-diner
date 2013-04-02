require 'httparty'
require 'json'
require 'uri'
require 'cgi'

require "flapjack-diner/version"
require "flapjack-diner/argument_validator"

module Flapjack
  module Diner
    SUCCESS_STATUS_CODES = [200, 204]

    include HTTParty
    extend ArgumentValidator::Helper

    format :json

    validate_all :path => :entity, :as => :required
    validate_all :query => [:start_time, :end_time], :as => :time

    class << self

      attr_accessor :logger

      # NB: clients will need to handle any exceptions caused by,
      # e.g., network failures or non-parseable JSON data.

      def entities
        perform_get_simple('entities')
      end

      def checks(entity)
        perform_get_request('checks', :path => {:entity => entity})
      end

      def status(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('status', :path => args)
      end

      # maybe rename 'create_acknowledgement!' ?
      def acknowledge!(entity, check, options = {})
        args = {:entity => entity, :check => check}
        perform_post_request('acknowledgements', :path => args, :query => options)
      end

      # maybe rename 'create_test_notifications!' ?
      def test_notifications!(entity, check, options = {})
        args = {:entity => entity, :check => check}
        perform_post_request('test_notifications', :path => args, :query => options)
      end

      def create_scheduled_maintenance!(entity, check, options = {})
        args = {:entity => entity, :check => check}

        perform_post_request('scheduled_maintenances', :path => args, :query => options) do
          validate :path  => [:entity, :check], :as => :required
          validate :query => :start_time, :as => :required
          validate :query => :duration, :as => [:required, :integer]
        end
      end

      def scheduled_maintenances(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('scheduled_maintenances', :path => args, :query => options)
      end

      def unscheduled_maintenances(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('unscheduled_maintenances', :path => args, :query => options)
      end

      def outages(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('outages', :path => args, :query => options)
      end

      def downtime(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('downtime', :path => args, :query => options)
      end

      def contacts
        perform_get_simple('contacts')
      end

      def contact(contact_id)
        perform_get_simple("contacts/#{contact_id}")
      end

      def notification_rules(contact_id)
        perform_get_simple("contacts/#{contact_id}/notification_rules")
      end

      def notification_rule(rule_id)
        perform_get_simple("notification_rules/#{rule_id}")
      end

      def create_notification_rule!(rule)
        perform_post_json('notification_rules', rule.to_json)
      end

      def update_notification_rule!(rule_id, rule)
        perform_put_json("notification_rules/#{rule_id}", rule.to_json)
      end

      def delete_notification_rule!(rule_id)
        perform_delete_request('notification_rules/#{rule_id}')
      end

      def contact_media(contact_id, media_type = nil)
        path = media_type ? "contacts/#{contact_id}/media/#{media_type}" :
                            "contacts/#{contact_id}/media"
        perform_get_simple(path)
      end

      def create_contact_media!(contact_id, media_type, media)
        perform_post_json("contacts/#{contact_id}/media/#{media_type}", media.to_json)
      end

      def update_contact_media!(contact_id, media_type, media)
        perform_put_json("contacts/#{contact_id}/media/#{media_type}", media.to_json)
      end

      def delete_contact_media!(contact_id, media_type)
        perform_delete("contacts/#{contact_id}/media/#{media_type}")
      end

      def contact_timezone(contact_id, options = {})
        perform_get_simple("contacts/#{contact_id}/timezone")
      end

      def update_contact_timezone!(contact_id, options = {})
        perform_put_json("contacts/#{contact_id}/timezone",
                         { :timezone => options[:timezone] }.to_json)
      end

      def delete_contact_timezone!(contact_id, options = {})
        perform_delete("contacts/#{contact_id}/timezone")
      end

      private

      def perform_get_simple(path)
        req_uri = build_uri("/#{path}")
        logger.info "GET #{req_uri}" if logger
        response = get(req_uri.request_uri)
        if logger
          logger.info "  Response Code: #{response.code}#{response.message ? response.message : ''}"
          if response.body
            logger.info "  Response Body: " + response.body[0..300]
          end
        end
        parsed(response)
      end

      def perform_get_request(action, options = {}, &validation)
        path, params = prepare_request(action, options, &validation)
        req_uri = build_uri(path, params)
        logger.info "GET #{req_uri}" if logger
        response = get(req_uri.request_uri)
        if logger
          logger.info "  Response Code: #{response.code}#{response.message ? response.message : ''}"
          if response.body
            logger.info "  Response Body: " + response.body[0..300]
          end
        end
        parsed(response)
      end

      def perform_post_request(action, options = {}, &validation)
        path, params = prepare_request(action, options, &validation)
        req_uri = build_uri(path)
        logger.info "POST #{req_uri}\n  Params: #{params.inspect}" if logger
        code = post(path, :body => params).code
        logger.info "  Response code: #{code}" if logger
        SUCCESS_STATUS_CODES.include?(code)
      end

      def perform_put_json(path, body)
        req_uri = build_uri("/#{path}")
        logger.info "PUT /#{req_uri}\n  #{body}" if logger
        response = put(req_uri.request_uri, :body => body, :headers => {'Content-Type' => 'application/json'})
        if logger
          logger.info "  Response Code: #{response.code}#{response.message ? response.message : ''}"
          response_body = response.body ? response.body[0..300] : nil
          if response_body
            logger.info "  Response Body: " + response_body
          end
        end
        SUCCESS_STATUS_CODES.include?(response.code)
      end

      def perform_post_json(path, body)
        req_uri = build_uri("/#{path}")
        logger.info "POST /#{req_uri}\n  #{body}" if logger
        response = post(req_uri.request_uri, :body => body, :headers => {'Content-Type' => 'application/json'})
        if logger
          logger.info "  Response Code: #{response.code}#{response.message ? response.message : ''}"
          response_body = response.body ? response.body[0..300] : nil
          if response_body
            logger.info "  Response Body: " + response_body
          end
        end
        SUCCESS_STATUS_CODES.include?(response.code)
      end

      def perform_delete(path)
        req_uri = build_uri("/#{path}")
        logger.info "DELETE /#{req_uri}" if logger
        response = delete(req_uri.request_uri)
        if logger
          logger.info "  Response Code: #{response.code}#{response.message ? response.message : ''}"
        end
        SUCCESS_STATUS_CODES.include?(response.code)
      end

      def prepare_request(action, options = {}, &validation)
        args = options[:path]
        query = options[:query]

        (block_given? ? [validation] : @validations).each do |validation|
          ArgumentValidator.new(args, query).instance_eval(&validation)
        end

        [prepare_path(action, args), prepare_query(query)]
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

      def build_uri(path, params = nil)
        pr, ho, po = protocol_host_port
        URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => (params && params.empty? ? nil : params))
      end

      def prepare_value(value)
        value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
      end

      def prepare_path(action, args)
        ["/#{action}", args[:entity], args[:check]].compact.map do |value|
          prepare_value(value)
        end.join('/')
      end

      def prepare_query(query)
        query.collect do |key, value|
          [CGI.escape(key.to_s), CGI.escape(prepare_value(value))].join('=')
        end.join('&') if query
      end

      def parsed(response)
        return unless response && response.respond_to?(:parsed_response)
        response.parsed_response
      end
    end
  end
end
