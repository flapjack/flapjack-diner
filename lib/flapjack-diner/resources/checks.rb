require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Checks
        def create_checks(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => :name,    :as => [:required, :string]
            validate :query => :enabled, :as => :boolean
            validate :query => [:initial_failure_delay, :repeat_failure_delay],
                     :as => :integer
          end
          perform_post('checks', '/checks', nil, data)
        end

        def checks(*ids)
          perform_get('checks', '/checks', ids)
        end

        def update_checks(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :name,                  :as => :string
            validate :query => :enabled,               :as => :boolean
            validate :query => [:initial_failure_delay, :repeat_failure_delay],
                     :as => :integer
          end
          perform_put('checks', "/checks", data)
        end

        # TODO should allow DELETE when API does
      end
    end
  end
end
