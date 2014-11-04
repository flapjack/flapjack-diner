require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Reports

        def status_report_checks(*ids)
          perform_get('status_reports', "/status_report/checks", ids)
        end

        %w(scheduled_maintenance unscheduled_maintenance
           downtime outage).each do |report_type|
          define_method("#{report_type}_report_checks") do |*args|
            ids, params = unwrap_ids(*args), unwrap_params(*args)
            validate_params(params) do
              validate :query => [:start_time, :end_time], :as => :time
            end
            perform_get("#{report_type}_reports",
                        "/#{report_type}_report/checks", ids, params)
          end
        end
      end
    end
  end
end
