require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rules

        def create_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :string
            # TODO proper validation of time_restrictions field
          end
          perform_post('rule', '/rules', data)
        end

        def rules(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :filter,  :as => :hash
            validate :query => :include, :as => :string_or_array_of_strings
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/rules', ids, data)
        end

        def update_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            # TODO proper validation of time_restrictions field
          end
          perform_patch('rules', "/rules", data)
        end

        def delete_rules(*ids)
          raise "'delete_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          perform_delete('rule', '/rules', ids)
        end
      end
    end
  end
end
