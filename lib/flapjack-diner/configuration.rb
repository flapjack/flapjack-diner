require 'flapjack-diner/request'
require 'flapjack-diner/response'

require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Configuration

      RESOURCES_GET = {
        [:fields, :sort, :include] => :string_or_array_of_strings,
        :filter                    => :hash,
        [:page, :per_page]         => :positive_integer
      }

      # relationships are extracted from flapjack data models'
      # "jsonapi_associations" class methods

      RESOURCES = {
        :acknowledgements => {
          :resource => 'acknowledgement',
          :requests => {
            :post => {
              :duration      => :positive_integer,
              :summary       => :non_empty_string,
              [:check, :tag] => :singular_link_uuid
            },
          },
          :request_validations => {
            :post => proc {
              # _events_validate_association(data, 'acknowledgement')
            }
          },
          :relationships => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          }
        },

        :checks => {
          :resource => 'check',
          :requests => {
            :post => {
              :id       => :uuid,
              :name     => [:required, :non_empty_string],
              :enabled  => :boolean,
              :tags     => :multiple_link_uuid
            },
            :get => RESOURCES_GET,
            :patch => {
              :id       => [:required, :uuid],
              :name     => :non_empty_string,
              :enabled  => :boolean,
              :tags     => :multiple_link_uuid
            },
            :delete => {}
          },
          :relationships => {
            :alerting_media => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :contacts => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :current_scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :current_state => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :current_unscheduled_maintenance => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :latest_notifications => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :states => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :unscheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            }
          }
        },

        :contacts => {
          :resource => 'contact',
          :requests => {
            :post => {
              :id       => :uuid,
              :name     => [:required, :non_empty_string],
              :timezone => :non_empty_string,
              :tags     => :multiple_link_uuid
            },
            :get => RESOURCES_GET,
            :patch => {
              :id                => [:required, :uuid],
              [:name, :timezone] => :non_empty_string
            },
            :delete => {}
          },
          :relationships => {
            :checks => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :media => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :rules => {
              :get => :true,
              :number => :multiple, :link => true, :includable => true
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          }
        },

        :media => {
          :resource => 'medium',
          :requests => {
            :post => {
              :id                       => :uuid,
              :transport                => [:non_empty_string, :required],
              [:address, :pagerduty_subdomain,
               :pagerduty_token]        => :non_empty_string,
              [:interval, :rollup_threshold,
               :pagerduty_ack_duration] => :positive_integer,
              :contact                  => [:singular_link_uuid, :required],
              :rules                    => :multiple_link_uuid
            },
            :get => RESOURCES_GET,
            :patch => {
              :id                       => [:uuid, :required],
              [:address, :pagerduty_subdomain,
               :pagerduty_token]        => :non_empty_string,
              [:interval, :rollup_threshold,
               :pagerduty_ack_duration] => :positive_integer,
              :rules                    => :multiple_link_uuid
            },
            :delete => {}
          },
          :relationships => {
            :alerting_checks => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :contact => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          }
        },

        :metrics => {
          :resource => 'metrics',
          :requests => {
            :get => {
              :fields => :string_or_array_of_strings
            }
          }
        },

        :rules => {
          :resource => 'rule',
          :requests => {
            :post => {
              :id                    => :uuid,
              :name                  => :string,
              :enabled               => :boolean,
              :blackhole             => :boolean,
              :strategy              => :string,
              :conditions_list       => :string,
              :time_restriction_ical => :string,
              :contact               => [:singular_link_uuid, :required],
              [:media, :tags]        => :multiple_link_uuid
            },
            :get => RESOURCES_GET,
            :patch => {
              :id                    => [:uuid, :required],
              :name                  => :string,
              :enabled               => :boolean,
              :blackhole             => :boolean,
              :strategy              => :string,
              :conditions_list       => :string,
              :time_restriction_ical => :string,
              [:media, :tags]        => :multiple_link_uuid
            },
            :delete => {}
          },
          :relationships => {
            :contact => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :media => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          }
        },

        :scheduled_maintenances => {
          :resource => 'scheduled_maintenance',
          :requests => {
            :post => {
              :id                      => :uuid,
              [:start_time, :end_time] => [:required, :time],
              :summary                 => :non_empty_string,
              [:check, :tag]           => :singular_link_uuid
            },
            :request_validations => {
              :post => proc {
                # _maintenance_periods_validate_association(data, 'scheduled maintenance period')
              }
            },
            :patch => {
              :id                      => [:required, :uuid],
              [:start_time, :end_time] => :time
            },
            :delete => {}
          },
          :relationships => {
            :check => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          }
        },

        :states => {
          :resource => 'state',
          :requests => {
            :get => RESOURCES_GET
          },
          :relationships => {
            :check => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            }
          }
        },

        :statistics => {
          :resource => 'statistic',
          :requests => {
            :get => RESOURCES_GET
          }
        },

        :tags => {
          :resource => 'tag',
          :requests => {
            :post => {
              :id                          => :uuid,
              :name                        => [:required, :non_empty_string],
              [:checks, :contacts, :rules] => :multiple_link_uuid
            },
            :get => RESOURCES_GET,
            :patch => {
              :id                          => [:required, :uuid],
              :name                        => :non_empty_string,
              [:checks, :contacts, :rules] => :multiple_link_uuid
            },
            :delete => {}
          },
          :relationships => {
            :checks => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :contacts => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :states => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :unscheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            }
          }
        },

        :test_notifications => {
          :resource => 'test_notification',
          :requests => {
            :post => {
              :summary       => :non_empty_string,
              [:check, :tag] => :singular_link_uuid
            }
          },
          :request_validations => {
            :post => proc {
              # _events_validate_association(data, 'test notification')
            }
          },
          :relationships => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          }
        },

        :unscheduled_maintenances => {
          :resource => 'unscheduled_maintenance',
          :requests => {
            :patch => {
              :id       => [:required, :uuid],
              :end_time => [:required, :time]
            }
          },
          :relationships => {
            :check => {
              :get => true,
              :number => :singular, :link => false, :includable => true
            }
          }
        }
      }
    end
  end
end
