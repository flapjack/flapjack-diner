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
            validate :query => [:transport, :address],
              :as => [:required, :string]
            validate :query => [:interval, :rollup_threshold],
                     :as => [:required, :integer]

          end
          perform_post('medium', 'media', "/media", data)
        end

        def media(*ids)
          perform_get('media', '/media', ids)
        end

        def update_media(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => [:address, :transport], :as => :string
            validate :query => [:interval, :rollup_threshold],
                     :as => :integer
          end
          perform_patch('media', "/media", data.merge(:type => 'medium'))
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
