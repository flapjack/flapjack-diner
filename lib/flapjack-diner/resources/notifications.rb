require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Notifications
        %w(checks tags).each do |resource_type|
          define_method("create_test_notifications_#{resource_type}") do |*args|
            ids  = 'tags'.eql?(resource_type) ? unwrap_ids(*args) : unwrap_uuids(*args)
            data = unwrap_data(*args)
            # TODO raise error unless ids.size == 1
            validate_params(data) do
              validate :query => :summary, :as => :string
            end
            perform_post('test_notification',
              "/test_notifications/#{resource_type}/#{ids.first}", data)
          end
        end
      end
    end
  end
end
