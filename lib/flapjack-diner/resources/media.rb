require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Media
        def create_contact_media(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          raise "'create_contact_media' requires at least one contact id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => [:type, :address], :as => [:required, :string]
            validate :query => [:interval, :rollup_threshold],
                     :as => [:required, :integer]
          end
          perform_post("/contacts/#{escaped_ids(ids)}/media", nil,
                       :media => data)
        end

        def media(*ids)
          perform_get('media', '/media', ids)
        end

        def update_media(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_media' requires at least one media id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :address,                       :as => :string
            validate :query => [:interval, :rollup_threshold], :as => :integer
          end
          perform_patch("/media/#{escaped_ids(ids)}", nil,
                        update_media_ops(params))
        end

        def delete_media(*ids)
          raise "'delete_media' requires at least one media id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('/media', ids)
        end

        private

        def update_media_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            next unless [:address, :interval, :rollup_threshold].include?(k)
            memo << patch_replace('media', k, v)
          end
          raise "'update_media' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end
      end
    end
  end
end
