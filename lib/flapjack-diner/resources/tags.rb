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
          perform_post('tags', '/tags', nil, :tags => data)
        end

        def tags(*ids)
          perform_get('tags', '/tags', ids)
        end

        def update_tags(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          raise "'update_tags' requires at least one tag id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => :name,                  :as => :string
          end
          perform_put('tags', "/tags", ids, :tags => data)
        end

        def delete_tags(*ids)
          raise "'delete_tags' requires at least one tag ID " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('/tags', ids)
        end
      end
    end
  end
end
