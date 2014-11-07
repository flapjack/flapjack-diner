require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Media
        def create_media(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => [:type, :address], :as => [:required, :string]
            validate :query => [:interval, :rollup_threshold],
                     :as => [:required, :integer]

          end
          perform_post('media', "/media", nil, :media => data)
        end

        def media(*ids)
          perform_get('media', '/media', ids)
        end

        def update_media(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          raise "'update_media' requires at least one check id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => :address, :as => :string
            validate :query => [:interval, :rollup_threshold],
                     :as => :integer
          end
          perform_put('media', "/media", ids, :media => data)
        end

        def delete_media(*ids)
          raise "'delete_media' requires at least one medium id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('/media', ids)
        end

      end
    end
  end
end
