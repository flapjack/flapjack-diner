require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Events
        def create_acknowledgements(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :duration, :as => :positive_integer
            validate :query => :summary, :as => :non_empty_string
            validate :query => :check, :as => :singular_link_uuid
            validate :query => :tag, :as => :singular_link
          end
          _events_validate_association(data, 'acknowledgement')
          perform_post(:acknowledgements, "/acknowledgements", data)
        end

        def create_test_notifications(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :summary, :as => :non_empty_string
            validate :query => :check, :as => :singular_link_uuid
            validate :query => :tag, :as => :singular_link
          end
          _events_validate_association(data, 'test notification')
          perform_post(:test_notifications, "/test_notifications", data)
        end

        private

        def _events_validate_association(data, type)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:check) || d.has_key?(:tag)
                raise ArgumentError.new("Check or tag association must be provided for all #{type}s")
              end
            end
          when Hash
            unless data.has_key?(:check) || data.has_key?(:tag)
              raise ArgumentError.new("Check or tag association must be provided for #{type}")
            end
          end
        end
      end
    end
  end
end
