require 'httparty'
require 'json'
require 'uri'

require "flapjack-diner/version"
require "flapjack-diner/argument_validator"

module Flapjack
  module Diner
    SUCCESS_STATUS_CODE = 204

    include HTTParty
    extend ArgumentValidator::Helper

    format :json

    validate_all :path => :entity, :as => :required
    validate_all :query => [:start_time, :end_time], :as => :time

    class << self

      # NB: clients will need to handle any exceptions caused by,
      # e.g., network failures or non-parseable JSON data.

      def entities
        parsed( get("/entities") )
      end

      def checks(entity)
        perform_get_request('checks', :path => {:entity => entity})
      end

      def status(entity, options = {})
        args = {:entity => entity, :check => options.delete(:check)}
        perform_get_request('status', :path => args)
      end

      def acknowledge!(entity, check, options = {})
        args = {:entity => entity, :check => check}
        perform_post_request('acknowledgements', :path => args, :query => options)
      end

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

      private

      def perform_get_request(action, options, &validation)
        path, params = prepare_request(action, options, &validation)
        parsed( get(build_uri(path, params).request_uri) )
      end

      def perform_post_request(action, options, &validation)
        path, params = prepare_request(action, options, &validation)
        post(path, :body => params).code == SUCCESS_STATUS_CODE
      end

      def prepare_request(action, options, &validation)
        args = options[:path]
        query = options[:query]

        (block_given? ? [validation] : @validations).each do |validation|
          ArgumentValidator.new(args, query).instance_eval(&validation)
        end

        [prepare_path(action, args), prepare_query(query)]
      end

      def protocol_host_port
        self.base_uri =~ /$(?:(https?):\/\/)?([a-zA-Z0-9][a-zA-Z0-9\.\-]*[a-zA-Z0-9])(?::\d+)?/i
        protocol = ($1 || 'http').downcase
        host = $2
        port = $3 || ('https'.eql?(protocol) ? 443 : 80)

        [protocol, host, port]
      end

      def build_uri(path, params)
        pr, ho, po = protocol_host_port
        URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => (params && params.empty? ? nil : params))
      end

      def prepare_value(value)
        URI.escape value.respond_to?(:iso8601) ? value.iso8601 : value.to_s
      end

      def prepare_path(action, args)
        ["/#{action}", args[:entity], args[:check]].compact.map do |value|
          prepare_value(value)
        end.join('/')
      end

      def prepare_query(query)
        query.collect do |key, value|
          [key, prepare_value(value)].join('=')
        end.join('&') if query
      end

      def parsed(response)
        return unless response && response.respond_to?(:parsed_response)
        response.parsed_response
      end
    end
  end
end
