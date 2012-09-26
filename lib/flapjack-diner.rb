require 'httparty'
require 'json'
require 'uri'

require "flapjack-diner/version"

module Flapjack
  module Diner

    include HTTParty
    format :json

    class << self

      # NB: clients will need to handle any exceptions caused by,
      # e.g., network failures or non-parseable JSON data.

      def entities
        parsed( get("/entities") )
      end

      def checks(entity)
        args = prepare(:entity => {:value => entity, :required => true})

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => "/checks/#{args[:entity]}")

        parsed( get(uri.request_uri) )
      end

      def status(entity, options = {})
        args = prepare(:entity     => {:value => entity, :required => true},
                       :check      => {:value => options[:check]})

        path = "/status/#{args[:entity]}"
        path += "/#{args[:check]}" if args[:check]

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path)

        parsed( get(uri.request_uri) )
      end

      def acknowledge!(entity, check, options = {})
        args = prepare(:entity   => {:value => entity, :required => true},
                       :check    => {:value => check, :required => true})
        query = prepare(:summary => {:value => options[:summary]})

        path = "/acknowledgments/#{args[:entity]}/#{args[:check]}"
        params = query.collect{|k,v| "#{k.to_s}=#{v}"}.join('&')

        response = post(path, :body => params)
        response.code == 204
      end

      def create_scheduled_maintenance!(entity, check, start_time, duration, options = {})
        args = prepare(:entity     => {:value => entity, :required => true},
                       :check      => {:value => check, :required => true})
        query = prepare(:start_time => {:value => start_time, :required => true, :class => Time},
                        :duration   => {:value => duration, :required => true, :class => Integer},
                        :summary    => {:value => options[:summary]})

        path ="/scheduled_maintenances/#{args[:entity]}/#{args[:check]}"
        params = query.collect{|k,v| "#{k.to_s}=#{v}"}.join('&')

        response = post(path, :body => params)
        response.code == 204
      end

      def scheduled_maintenances(entity, options = {})
        args = prepare(:entity      => {:value => entity, :required => true},
                       :check       => {:value => options[:check]})
        query = prepare(:start_time => {:value => options[:start_time], :class => Time},
                        :end_time   => {:value => options[:end_time], :class => Time})

        path = "/scheduled_maintenances/#{args[:entity]}"
        path += "/#{args[:check]}" if args[:check]

        params = query.collect{|k,v| "#{k.to_s}=#{v}"}

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => params.empty? ? nil : params.join('&'))

        parsed( get(uri.request_uri) )
      end

      def unscheduled_maintenances(entity, options = {})
        args = prepare(:entity      => {:value => entity, :required => true},
                       :check       => {:value => options[:check]})
        query = prepare(:start_time => {:value => options[:start_time], :class => Time},
                        :end_time   => {:value => options[:end_time], :class => Time})

        path = "/unscheduled_maintenances/#{args[:entity]}"
        path += "/#{args[:check]}" if args[:check]

        params = query.collect{|k,v| "#{k.to_s}=#{v}"}

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => params.empty? ? nil : params.join('&'))

        parsed( get(uri.request_uri) )
      end

      def outages(entity, options = {})
        args = prepare(:entity      => {:value => entity, :required => true},
                       :check       => {:value => options[:check]})
        query = prepare(:start_time => {:value => options[:start_time], :class => Time},
                        :end_time   => {:value => options[:end_time], :class => Time})

        path = "/outages/#{args[:entity]}"
        path += "/#{args[:check]}" if args[:check]

        params = query.collect{|k,v| "#{k.to_s}=#{v}"}

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po, :path => path,
          :query => params.empty? ? nil : params.join('&'))

        parsed( get(uri.request_uri) )
      end

      def downtime(entity, options = {})
        args = prepare(:entity      => {:value => entity, :required => true},
                       :check       => {:value => options[:check]})
        query = prepare(:start_time => {:value => options[:start_time], :class => Time},
                        :end_time   => {:value => options[:end_time], :class => Time})

        path = "/downtime/#{args[:entity]}"
        path += "/#{args[:check]}" if args[:check]

        params = query.collect{|k,v| "#{k.to_s}=#{v}"}

        pr, ho, po = protocol_host_port
        uri = URI::HTTP.build(:protocol => pr, :host => ho, :port => po,
          :path => path, :query => params.empty? ? nil : params.join('&'))

        parsed( get(uri.request_uri) )
      end

    private

      def protocol_host_port
        self.base_uri =~ /$(?:(https?):\/\/)?([a-zA-Z0-9][a-zA-Z0-9\.\-]*[a-zA-Z0-9])(?::\d+)?/i
        protocol = ($1 || 'http').downcase
        host = $2
        port = $3 || ('https'.eql?(protocol) ? 443 : 80)

        [protocol, host, port]
      end

      def prepare(data = {})
        data.inject({}) do |result, (k, v)|
          if value = ensure_valid_value(k,v)
            result[k] = URI.escape(value.respond_to?(:iso8601) ? value.iso8601 : value.to_s)
          end

          result
        end
      end

      def ensure_valid_value(key, value)
        if (result = value[:value]).nil?
          raise "'#{key}' is required" if value[:required]
        else
          case expected_class = value[:class]
          when Time
            raise "'#{key}' should contain some kind of time object." if !value.respond_to?(:iso8601)
          else
            raise "'#{key}' must be a #{expected_class}" if !expected_class.nil? && !result.is_a?(expected_class)
          end
          result
        end
      end

      def parsed(response)
        return unless response && response.respond_to?(:parsed_response)
        response.parsed_response
      end

    end

  end
end
