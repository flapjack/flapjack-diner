require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Contacts
        def create_contacts(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :name, :as => [:required, :string]
            validate :query => :timezone, :as => :string
            validate :query => [:media, :rules], :as => :multiple_link_uuid
          end
          perform_post(:contacts, '/contacts', data)
        end

        def contacts(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter, :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/contacts', ids, data)
        end

        def update_contacts(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => [:name, :timezone], :as => :string
            validate :query => [:media, :rules], :as => :multiple_link_uuid
          end
          perform_patch(:contacts, "/contacts", data)
        end

        def delete_contacts(*ids)
          raise "'delete_contacts' requires at least one contact id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete(:contacts, '/contacts', *ids)
        end

      end
    end
  end
end
