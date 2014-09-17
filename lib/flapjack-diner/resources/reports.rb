require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Reports

        # 6: Reports

        ['entities', 'checks'].each do |data_type|
          define_method("status_report_#{data_type}") do |*ids|
            extract_get('status_reports', perform_get("/status_report/#{data_type}", ids))
          end

          ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|
            define_method("#{report_type}_report_#{data_type}") do |*args|
              ids, params, data = unwrap_ids_and_params(*args)
              validate_params(params) do
                validate :query => [:start_time, :end_time], :as => :time
              end
              extract_get("#{report_type}_reports", perform_get("/#{report_type}_report/#{data_type}", ids, params))
            end
          end
        end

      end

    end
  end
end
