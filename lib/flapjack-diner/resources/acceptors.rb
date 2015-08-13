require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Acceptors

        def create_acceptors(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :name, :as => :string
            validate :query => :all, :as => :boolean
            validate :query => :conditions_list, :as => :string
            # TODO proper validation of time_restrictions field
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          _acceptors_validate_association(data)
          perform_post(:acceptors, '/acceptors', data)
        end

        def acceptors(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/acceptors', ids, data)
        end

        def update_acceptors(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            validate :query => :name, :as => :string
            validate :query => :all, :as => :boolean
            validate :query => :conditions_list, :as => :string
            # TODO proper validation of time_restrictions field
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:acceptors, "/acceptors", data)
        end

        def delete_acceptors(*ids)
          raise "'delete_acceptors' requires at least one acceptor id parameter" if ids.nil? || ids.empty?
          perform_delete(:acceptors, '/acceptors', *ids)
        end

        private

        def _acceptors_validate_association(data)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:contact)
                raise ArgumentError.new("Contact association must be provided for all acceptors")
              end
            end
          when Hash
            unless data.has_key?(:contact)
              raise ArgumentError.new("Contact association must be provided for acceptor")
            end
          end
        end
      end
    end
  end
end
