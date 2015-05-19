require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module States
        def states(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter, :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/states', ids, data)
        end
      end
    end
  end
end
