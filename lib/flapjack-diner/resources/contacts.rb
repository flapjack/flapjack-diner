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
            validate :query => :id,         :as => :string
            validate :query => :name,       :as => [:required, :string]
            validate :query => :timezone,   :as => :string
          end
          perform_post('contact', 'contacts', '/contacts', data)
        end

        def contacts(*ids)
          perform_get('contacts', '/contacts', ids)
        end

        def update_contacts(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => [:name, :timezone], :as => :string
          end
          perform_patch('contacts', "/contacts", data.merge(:type => 'contact'))
        end

        def delete_contacts(*ids)
          raise "'delete_contacts' requires at least one contact id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('contact', '/contacts', ids)
        end

      end
    end
  end
end
