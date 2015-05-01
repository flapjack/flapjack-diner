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
            validate :query => :name, :as => [:required, :string]
            validate :query => [:checks, :rules], :as => :multiple_link_uuid
          end
          perform_post(:tags, '/tags', data)
        end

        def tags(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/tags', ids, data)
        end

        def update_tags(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => [:checks, :rules], :as => :multiple_link_uuid
          end
          perform_patch(:tags, "/tags", data)
        end

        def delete_tags(*ids)
          raise "'delete_tags' requires at least one tag ID " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete(:tags, '/tags', *ids)
        end
      end
    end
  end
end
