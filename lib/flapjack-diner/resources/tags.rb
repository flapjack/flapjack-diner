require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Tags
        def create_tags(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id,   :as => :string
            validate :query => :name, :as => [:required, :string]
          end
          perform_post('tag', '/tags', data)
        end

        def tags(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :filter,  :as => :hash
            validate :query => :include, :as => :string_or_array_of_strings
          end
          perform_get('/tags', ids, data)
        end

        # tags cannot be updated

        def delete_tags(*ids)
          raise "'delete_tags' requires at least one tag ID " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('tag', '/tags', ids)
        end
      end
    end
  end
end
