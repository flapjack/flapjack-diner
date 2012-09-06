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
        jsonify( get("/entities") )
      end

      def checks(entity)
        entity_esc = prepare(entity, :required => 'entity')

        jsonify( get("/checks/#{entity_esc}") )
      end

      def status(entity, check = nil)
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check)

        s_url = "/status/#{entity_esc}"
        s_url += "/#{check_esc}" if check_esc

        jsonify( get(s_url) )
      end

      def acknowledge!(entity, check, options = {})
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check, :required => 'check')

        acknowledge_url = "/acknowledgments/#{entity_esc}/#{check_esc}"
        acknowledge_params = ""

        if options[:summary]
          summary_esc = prepare(options[:summary])
          acknowledge_params = "summary=#{summary_esc}"
        end

        jsonify( post(acknowledge_url, :body => acknowledge_params) )
      end

      def create_scheduled_maintenance!(entity, check, options = {})
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check, :required => 'check')
        start_time_esc = prepare(options[:start_time], :required => 'start time')
        duration_esc = prepare(options[:duration], :required => 'duration')

        create_sch_maint_url ="/scheduled_maintenances/#{entity_esc}/#{check_esc}"
        create_sch_maint_params = "start_time=#{start_time_esc}&duration=#{duration_esc}"

        if options[:summary]
          summary_esc = prepare(options[:summary])
          create_sch_maint_params += "&summary=#{summary_esc}"
        end

        jsonify( post(create_sch_maint_url, :body => create_sch_maint_params) )
      end

      def scheduled_maintenances(entity, check = nil)
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check)

        sm_url = "/scheduled_maintenances/#{entity_esc}"
        sm_url += "/#{check_esc}" if check_esc

        jsonify( get(sm_url) )
      end

      def unscheduled_maintenances(entity, check = nil)
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check)

        um_url = "/unscheduled_maintenances/#{entity_esc}"
        um_url += "/#{check_esc}" if check_esc

        jsonify( get(um_url) )
      end

      def outages(entity, check = nil)
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check)

        o_url = "/outages/#{entity_esc}"
        o_url += "/#{check_esc}" if check_esc

        jsonify( get(o_url) )
      end

      def downtime(entity, check = nil)
        entity_esc = prepare(entity, :required => 'entity')
        check_esc = prepare(check)

        d_url = "/downtime/#{entity_esc}"
        d_url += "/#{check_esc}" if check_esc

        jsonify( get(d_url) )
      end

    private

      def prepare(data, opts = {})
        if data.nil?
          raise "#{opts[:required].upcase} is required" if opts[:required]
          return
        end
        URI.escape(data.to_s)
      end

      def jsonify(response)
        return unless response && response.body
        JSON.parse(response.body)
      end

    end

  end
end
