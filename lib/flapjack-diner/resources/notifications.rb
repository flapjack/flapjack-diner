require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Notifications
        def create_test_notifications(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :summary, :as => :string
          end
          perform_post('test_notification', '/test_notifications', data)
        end
      end
    end
  end
end
