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
            validate :query => :id, :as => :uuid
            validate :query => [:transport, :address],
              :as => [:required, :string]
            validate :query => [:interval, :rollup_threshold],
                     :as => [:required, :integer]

          end
          perform_post('medium', "/media", data)
        end

        def media(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :filter,  :as => :hash
            validate :query => :include, :as => :string_or_array_of_strings
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/media', ids, data)
        end

        def update_media(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => [:address, :transport], :as => :string
            validate :query => [:interval, :rollup_threshold],
                     :as => :integer
          end
          perform_patch('medium', "/media", data)
        end

        def delete_media(*ids)
          raise "'delete_media' requires at least one medium id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('medium', '/media', *ids)
        end

      end
    end
  end
end
