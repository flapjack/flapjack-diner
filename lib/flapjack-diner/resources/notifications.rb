require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Notifications
        %w(entities checks).each do |data_type|
          define_method("create_test_notifications_#{data_type}") do |*args|
            ids, data = unwrap_ids(*args), unwrap_create_data(*args)
            raise "'create_test_notifications_#{data_type}' requires at " \
              "least one #{data_type} id parameter" if ids.nil? || ids.empty?
            validate_params(data) do
              validate :query => :summary, :as => :string
            end
            perform_post("/test_notifications/#{data_type}", ids,
                         :test_notifications => data)
          end
        end
      end
    end
  end
end
