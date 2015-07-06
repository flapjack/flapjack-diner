require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module MaintenancePeriods

        def create_scheduled_maintenances(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :start_time, :as => [:required, :time]
            validate :query => :end_time,   :as => [:required, :time]
            validate :query => :summary,    :as => :non_empty_string
            validate :query => :check, :as => :singular_link_uuid
            validate :query => :tag, :as => :singular_link
          end
          _maintenance_periods_validate_association(data, 'scheduled maintenance period')
          perform_post(:scheduled_maintenances, '/scheduled_maintenances', data)
        end

        def update_scheduled_maintenances(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:required, :uuid]
            validate :query => [:start_time, :end_time], :as => :time
          end
          perform_patch(:scheduled_maintenances, '/scheduled_maintenances',
                        data)
        end

        def update_unscheduled_maintenances(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:required, :uuid]
            validate :query => :end_time, :as => :time
          end
          perform_patch(:unscheduled_maintenances, '/unscheduled_maintenances',
                        data)
        end

        def delete_scheduled_maintenances(*ids)
          if ids.nil? || ids.empty?
            raise "'delete_scheduled_maintenances' requires " \
                  "at least one scheduled maintenance id parameter"
          end
          perform_delete(:scheduled_maintenances, '/scheduled_maintenances',
            *ids)
        end

        private

        def _maintenance_periods_validate_association(data, type)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:check) || d.has_key?(:tag)
                raise ArgumentError.new("Check or tag association must be provided for all #{type}s")
              end
            end
          when Hash
            unless data.has_key?(:check) || data.has_key?(:tag)
              raise ArgumentError.new("Check or tag association must be provided for #{type}")
            end
          end
        end

      end
    end
  end
end
