require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Media

        # 2: Media
        def create_contact_media(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_contact_media' requires at least one contact id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              validate :query => [:type, :address], :as => [:required, :string]
              validate :query => [:interval, :rollup_threshold], :as => [:required, :integer]
            end
          end
          perform_post("/contacts/#{escaped_ids(ids)}/media", nil, :media => data)
        end

        def media(*ids)
          extract_get('media', perform_get('/media', ids))
        end

        def update_media(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'update_media' requires at least one media id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :address,                       :as => :string
            validate :query => [:interval, :rollup_threshold], :as => :integer
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :address, :interval, :rollup_threshold
              memo << {:op    => 'replace',
                       :path  => "/media/0/#{k.to_s}",
                       :value => v}
            end
            memo
          end
          raise "'update_media' did not find any valid update fields" if ops.empty?
          perform_patch("/media/#{escaped_ids(ids)}", nil, ops)
        end

        def delete_media(*ids)
          raise "'delete_media' requires at least one media id parameter" if ids.nil? || ids.empty?
          perform_delete('/media', ids)
        end

      end

    end
  end
end
