require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module MaintenancePeriods

        def create_scheduled_maintenances_checks(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          if ids.nil? || ids.empty?
            raise "'create_scheduled_maintenances_checks' requires " \
                  "at least one check id parameter"
          end
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => :start_time, :as => [:required, :time]
            validate :query => :duration,   :as => [:required, :integer]
            validate :query => :summary,    :as => :string
          end
          perform_post("/scheduled_maintenances/checks", ids,
                       :scheduled_maintenances => data)
        end

        def create_unscheduled_maintenances_checks(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          if ids.nil? || ids.empty?
            raise "'create_unscheduled_maintenances_checks' requires " \
                  "at least one check id parameter"
          end
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => :duration,   :as => [:required, :integer]
            validate :query => :summary,    :as => :string
          end
          perform_post("/unscheduled_maintenances/checks", ids,
                       :unscheduled_maintenances => data)
        end

        def update_unscheduled_maintenances_checks(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          if ids.nil? || ids.empty?
            raise "'update_unscheduled_maintenances_checks' requires " \
                  "at least one unscheduled maintenance id parameter"
          end
          validate_params(params) do
            validate :query => :end_time, :as => :time
          end
          ops = update_unscheduled_maintenances_checks_ops(params)
          perform_patch("/unscheduled_maintenances/checks", ids, ops)
        end

        def delete_scheduled_maintenances_checks(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          if ids.nil? || ids.empty?
            raise "'delete_scheduled_maintenances_checks' requires " \
                  "at least one scheduled maintenance id parameter"
          end
          validate_params(params) do
            validate :query => :start_time, :as => [:required, :time]
          end
          perform_delete("/scheduled_maintenances/checks", ids, params)
        end

        private

        def update_unscheduled_maintenances_checks_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            next unless :end_time.eql?(k)
            memo << patch_replace('unscheduled_maintenances', k, v)
          end
          raise "'update_unscheduled_maintenances_checks' did not " \
                'find any valid update fields' if ops.empty?
          ops
        end
      end
    end
  end
end
