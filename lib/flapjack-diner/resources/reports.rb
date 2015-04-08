require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Reports
        %w(checks tags).each do |resource_type|
          define_method("status_reports_#{resource_type}") do |*args|
            ids  = 'tags'.eql?(resource_type) ? unwrap_ids(*args) : unwrap_uuids(*args)
            data = unwrap_data(*args)
            validate_params(data) do
              validate :query => :filter, :as => :hash
              validate :query => :include, :as => :string_or_array_of_strings
              validate :query => [:page, :per_page], :as => :positive_integer
            end
            perform_get("/status_reports/#{resource_type}", ids, data)
          end

          %w(scheduled_maintenance unscheduled_maintenance
             downtime outage).each do |report_type|
            define_method("#{report_type}_reports_#{resource_type}") do |*args|
              ids  = 'tags'.eql?(resource_type) ? unwrap_ids(*args) : unwrap_uuids(*args)
              data = unwrap_data(*args)
              validate_params(data) do
                validate :query => :filter,  :as => :hash
                validate :query => :include, :as => :string_or_array_of_strings
                validate :query => [:page, :per_page], :as => :positive_integer
                validate :query => [:start_time, :end_time], :as => :time
              end
              perform_get("/#{report_type}_reports/#{resource_type}", ids, data)
            end
          end
        end
      end
    end
  end
end
