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
            validate :query => :transport, :as => [:string, :required]
            validate :query => [:address, :pagerduty_subdomain,
                                :pagerduty_token], :as => :non_empty_string
            validate :query => [:interval, :rollup_threshold,
                                :pagerduty_ack_duration], :as => :positive_integer
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :rules, :as => :multiple_link_uuid
          end
          # FIXME mirror Flapjack's data validation for pagerduty/non-pagerduty
          # transport is known, so only check for that case
          perform_post(:media, "/media", data)
        end

        def media(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/media', ids, data)
        end

        def update_media(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            validate :query => [:address, :pagerduty_subdomain,
                                :pagerduty_token], :as => :non_empty_string
            validate :query => [:interval, :rollup_threshold,
                                :pagerduty_ack_duration], :as => :positive_integer
            validate :query => :rules, :as => :multiple_link_uuid
          end
          # FIXME mirror Flapjack's data validation for pagerduty/non-pagerduty --
          # transport is not known, so test for both cases and at least one must pass
          perform_patch(:media, "/media", data)
        end

        def delete_media(*ids)
          raise "'delete_media' requires at least one medium id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete(:media, '/media', *ids)
        end

        private

        # def _validate_media_non_pagerduty(data)
        # end

        # def _validate_media_pagerduty(data)
        # end

      end
    end
  end
end
