require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Events
        def create_acknowledgements(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :duration, :as => :integer
            validate :query => :summary, :as => :string
          end
          perform_post(:acknowledgements, "/acknowledgements", data)
        end

        def create_test_notifications(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :summary, :as => :string
          end
          perform_post(:test_notifications, "/test_notifications", data)
        end
      end
    end
  end
end
