require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Links

        TYPES = {:checks => 'check',
                 :contacts => 'contact',
                 :media => 'medium',
                 :rules => 'rule',
                 :scheduled_maintenances   => 'scheduled_maintenance',
                 :tags => 'tag',
                 :test_notifications => 'test_notification',
                 :unscheduled_maintenances => 'unscheduled_maintenance'}

        ASSOCIATIONS = {
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
        }

        ASSOCIATIONS.each_pair do |resource, mappings|

          singular = mappings[:one]  || []
          multiple = mappings[:many] || []

          resource_id_validator  = :tags.eql?(resource) ? :string : :uuid

          (singular + multiple).each do |linked|
            define_method("#{resource}_link_#{linked}") do |resource_id|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => resource_id_validator
              end
              perform_get("/#{resource}/#{resource_id}/#{linked}")
            end
          end

          singular.each do |linked|
            linked_id_validator  = :tags.eql?(linked) ? :string : :uuid

            define_method("create_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_post_links(linked,
                "/#{resource}/#{resource_id}/links/#{linked}", linked_id)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_patch_links(linked,
                "/#{resource}/#{resource_id}/links/#{linked}", true, linked_id)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_delete_links(linked,
                "/#{resource}/#{resource_id}/links/#{linked}", linked_id)
            end
          end

          multiple.each do |linked|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("create_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              linked_ids = linked_ids.first if linked_ids.size == 1
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_post_links(type,
                "/#{resource}/#{resource_id}/links/#{linked}", *linked_ids)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_ids_validator
              end
              perform_patch_links(type,
                "/#{resource}/#{resource_id}/links/#{linked}", false, *linked_ids)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_delete_links(type,
                "/#{resource}/#{resource_id}/links/#{linked}", *linked_ids)
            end
          end
        end

      end

    end
  end
end
