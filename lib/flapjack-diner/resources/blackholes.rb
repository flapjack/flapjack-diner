require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Blackholes

        def create_blackholes(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            # TODO proper validation of time_restrictions field
            validate :query => :conditions_list, :as => :string
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          _blackholes_validate_association(data)
          perform_post(:blackholes, '/blackholes', data)
        end

        def blackholes(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/blackholes', ids, data)
        end

        def update_blackholes(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            # TODO proper validation of time_restrictions field
            validate :query => :conditions_list, :as => :string
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:blackholes, "/blackholes", data)
        end

        def delete_blackholes(*ids)
          raise "'delete_blackholes' requires at least one blackhole id parameter" if ids.nil? || ids.empty?
          perform_delete(:blackholes, '/blackholes', *ids)
        end

        private

        def _blackholes_validate_association(data)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:contact)
                raise ArgumentError.new("Contact association must be provided for all blackholes")
              end
            end
          when Hash
            unless data.has_key?(:contact)
              raise ArgumentError.new("Contact association must be provided for blackhole")
            end
          end
        end
      end
    end
  end
end
