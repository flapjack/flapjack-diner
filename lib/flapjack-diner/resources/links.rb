require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Links

        {
          :checks                   => {:many   => [:scheduled_maintenances,
                                                    :tags,
                                                    :unscheduled_maintenances]},
          :contacts                 => {:many   => [:media, :rules]},
          :media                    => {:one    => [:contact],
                                        :many   => [:rules]},
          :rules                    => {:one    => [:contact],
                                        :many   => [:media, :tags]},
          :scheduled_maintenances   => {:one    => [:check]},
          :tags                     => {:many   => [:checks, :rules]},
          :unscheduled_maintenances => {:one    => [:check]},
        }.each_pair do |resource, mappings|

          singular = mappings[:one]  || []
          multiple = mappings[:many] || []

          (singular + multiple).each do |linked|
            define_method("#{resource}_link_#{linked}") do |resource_id|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => :string
              end
              perform_get("#{linked}",
                "/#{resource}/#{resource_id}/#{linked}")
            end
          end

          singular.each do |linked|
            define_method("create_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => :string
                validate :query => :linked_id, :as => :string
              end
              perform_post("#{linked}",
                "/#{resource}/#{resource_id}/links/#{linked}", linked_id)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => :string
                validate :query => :linked_id, :as => :string
              end
              perform_put_links("#{linked}",
                "/#{resource}/#{resource_id}/links/#{linked}", linked_id)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => :string
              end
              perform_delete("/#{resource}/#{resource_id}/links/#{linked}")
            end
          end

          multiple.each do |linked|
            define_method("create_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              linked_ids = linked_ids.first if linked_ids.size == 1
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => :string
                validate :query => :linked_id, :as => :string_or_array_of_strings
              end
              perform_post("#{linked}",
                "/#{resource}/#{resource_id}/links/#{linked}", linked_ids)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => :string
                validate :query => :linked_id, :as => :array_of_strings
              end
              perform_put_links("#{linked}",
                "/#{resource}/#{resource_id}/links/#{linked}", linked_ids)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => :string
                validate :query => :linked_id, :as => :array_of_strings
              end
              perform_delete("/#{resource}/#{resource_id}/links/#{linked}", linked_ids)
            end
          end
        end

      end

    end
  end
end
