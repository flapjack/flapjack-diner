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
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          raise "'create_test_notifications' requires at least " \
            "one check id parameter" if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => :summary, :as => :string
          end
          perform_post('test_notifications', '/test_notifications', ids,
                       :test_notifications => data)
        end
      end
    end
  end
end
