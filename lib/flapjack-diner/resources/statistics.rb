require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Statistics
        def statistics(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :fields,  :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/statistics', ids, data)
        end
      end
    end
  end
end
