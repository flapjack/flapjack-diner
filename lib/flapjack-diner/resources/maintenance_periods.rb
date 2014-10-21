require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module MaintenancePeriods
        %w(entities checks).each do |data_type|
          define_method("create_scheduled_maintenances_#{data_type}") do |*args|
            ids, data = unwrap_ids(*args), unwrap_create_data(*args)
            if ids.nil? || ids.empty?
              raise "'create_scheduled_maintenances_#{data_type}' requires " \
                    "at least one #{data_type} id parameter"
            end
            validate_params(data) do
              validate :query => :start_time, :as => [:required, :time]
              validate :query => :duration,   :as => [:required, :integer]
              validate :query => :summary,    :as => :string
            end
            perform_post("/scheduled_maintenances/#{data_type}", ids,
                         :scheduled_maintenances => data)
          end

          define_method("create_unscheduled_maintenances_#{data_type}") do |*a|
            ids, data = unwrap_ids(*a), unwrap_create_data(*a)
            if ids.nil? || ids.empty?
              raise "'create_unscheduled_maintenances_#{data_type}' requires " \
                    "at least one #{data_type} id parameter"
            end
            validate_params(data) do
              validate :query => :duration,   :as => [:required, :integer]
              validate :query => :summary,    :as => :string
            end
            perform_post("/unscheduled_maintenances/#{data_type}", ids,
                         :unscheduled_maintenances => data)
          end

          define_method("update_unscheduled_maintenances_#{data_type}") do |*a|
            ids, params = unwrap_ids(*a), unwrap_params(*a)
            if ids.nil? || ids.empty?
              raise "'update_unscheduled_maintenances_#{data_type}' requires " \
                    "at least one #{data_type} id parameter"
            end
            validate_params(params) do
              validate :query => :end_time, :as => :time
            end
            ops = update_unscheduled_maintenances_ops(data_type, params)
            perform_patch("/unscheduled_maintenances/#{data_type}", ids, ops)
          end

          define_method("delete_scheduled_maintenances_#{data_type}") do |*args|
            ids, params = unwrap_ids(*args), unwrap_params(*args)
            if ids.nil? || ids.empty?
              raise "'delete_scheduled_maintenances_#{data_type}' requires " \
                    "at least one #{data_type} id parameter"
            end
            validate_params(params) do
              validate :query => :start_time, :as => [:required, :time]
            end
            perform_delete("/scheduled_maintenances/#{data_type}", ids, params)
          end
        end

        private

        def update_unscheduled_maintenances_ops(data_type, params)
          ops = params.each_with_object([]) do |(k, v), memo|
            next unless :end_time.eql?(k)
            memo << patch_replace('unscheduled_maintenances', k, v)
          end
          raise "'update_unscheduled_maintenances_#{data_type}' did not " \
                'find any valid update fields' if ops.empty?
          ops
        end
      end
    end
  end
end
