require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Reports

        def status_reports_checks(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :filter,  :as => :hash
            validate :query => :include, :as => :string_or_array_of_strings
          end
          perform_get("/status_reports/checks", ids, data)
        end

        %w(scheduled_maintenance unscheduled_maintenance
           downtime outage).each do |report_type|
          define_method("#{report_type}_reports_checks") do |*args|
            ids, data = unwrap_ids(*args), unwrap_data(*args)
            validate_params(data) do
              validate :query => :filter,  :as => :hash
              validate :query => :include, :as => :string_or_array_of_strings
              validate :query => [:start_time, :end_time], :as => :time
            end
            perform_get("/#{report_type}_reports/checks", ids, data)
          end
        end
      end
    end
  end
end
