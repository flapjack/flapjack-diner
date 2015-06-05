require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Relationships

        TYPES = {:checks => 'check',
                 :contacts => 'contact',
                 :media => 'medium',
                 :rules => 'rule',
                 :scheduled_maintenances   => 'scheduled_maintenance',
                 :states => 'state',
                 :tags => 'tag',
                 :test_notifications => 'test_notification',
                 :unscheduled_maintenances => 'unscheduled_maintenance'}

        # copied from flapjack data models' "jsonapi_associations" &
        # "jsonapi_linked_methods" class methods
        ASSOCIATIONS = {
          :checks => {
            :read_only  => {
              :singular => [:current_state, :current_unscheduled_maintenance],
              :multiple => [:alerting_media, :contacts, :current_scheduled_maintenances,
                            :latest_notifications, :states]
            },
            :read_write => {
              :singular => [],
              :multiple => [:scheduled_maintenances, :tags,
                            :unscheduled_maintenances]
            }
          },
          :contacts =>         {
            :read_only => {
              :singular => [],
              :multiple => [:checks]
            },
            :read_write => {
              :singular => [],
              :multiple => [:media, :rules]
            }
          },
          :media => {
            :read_only => {
              :singular => [],
              :multiple => [:alerting_checks]
            },
            :read_write => {
              :singular => [:contact],
              :multiple => [:rules]
            }
          },
          :rules => {
            :read_only => {
              :singular => [],
              :multiple => []
            },
            :read_write => {
              :singular => [:contact],
              :multiple => [:media, :tags]
            }
          },
          :scheduled_maintenances => {
            :read_only => {
              :singular => [],
              :multiple => []
            },
            :read_write => {
              :singular => [:check],
              :multiple => []
            }
          },
          :states => {
            :read_only => {
              :singular => [:check],
              :multiple => []
            },
            :read_write => {
              :singular => [],
              :multiple => []
            }
          },
          :tags => {
            :read_only => {
              :singular => [],
              :multiple => []
            },
            :read_write => {
              :singular => [],
              :multiple => [:checks, :rules]
            }
          },
          :unscheduled_maintenances => {
            :read_only => {
              :singular => [],
              :multiple => []
            },
            :read_write => {
              :singular => [:check],
              :multiple => []
            }
          }

        }

        ASSOCIATIONS.each_pair do |resource, mappings|

          read_only_singular  = mappings[:read_only][:singular]
          read_only_multiple  = mappings[:read_only][:multiple]

          read_write_singular = mappings[:read_write][:singular]
          read_write_multiple = mappings[:read_write][:multiple]

          resource_id_validator  = :tags.eql?(resource) ? :string : :uuid

          (read_only_singular + read_write_singular +
           read_only_multiple + read_write_multiple).sort.each do |linked|

            define_method("#{resource}_link_#{linked}") do |resource_id|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => resource_id_validator
              end
              perform_get("/#{resource}/#{resource_id}/#{linked}")
            end

          end

          read_write_singular.each do |linked|
            linked_id_validator  = :tags.eql?(linked) ? :string : :uuid

            define_method("create_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_post_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_patch_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", true, linked_id)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_delete_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
            end
          end

          read_write_multiple.each do |linked|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("create_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              linked_ids = linked_ids.first if linked_ids.size == 1
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_post_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", *linked_ids)
            end

            define_method("update_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_ids_validator
              end
              perform_patch_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", false, *linked_ids)
            end

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_delete_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", *linked_ids)
            end
          end
        end

      end

    end
  end
end
