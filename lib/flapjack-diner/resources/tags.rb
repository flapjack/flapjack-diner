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
          data = unwrap_create_data(*args)
          validate_params(data) do
            validate :query => :id,   :as => :string
            validate :query => :name, :as => [:required, :string]
          end
          perform_post('/tags', nil, :checks => data)
        end

        def tags(*names)
          perform_get('tags', '/tags', names)
        end

        # NB tags cannot be renamed

        def delete_tags(*names)
          raise "'delete_tags' requires at least one tag name " \
                'parameter' if names.nil? || names.empty?
          perform_delete('/tags', names)
        end
      end
    end
  end
end
