require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Metrics
        # singular resource, no id
        def metrics(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :fields, :as => :string_or_array_of_strings
          end
          perform_get('/metrics', [], data)
        end
      end
    end
  end
end
