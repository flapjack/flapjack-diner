# Flapjack::Diner

[![Travis CI Status][id_travis_img]][id_travis_link]

[id_travis_link]: https://secure.travis-ci.org/#!/flpjck/flapjack-diner
[id_travis_img]: https://secure.travis-ci.org/flpjck/flapjack-diner.png

Access the API of a [Flapjack](http://flapjack-project.com/) system monitoring server.

## Installation

Add this line to your application's Gemfile:

    gem 'flapjack-diner', :git => 'git://github.com/flpjck/flapjack-diner.git'

And then execute:

    $ bundle

## Usage

Set the URI of the Flapjack server:

```ruby
Flapjack::Diner.base_uri('127.0.0.1:5000')
```

Optionally, set a logger to log requests & responses:

```ruby
Flapjack::Diner.logger = Logger.new('logs/flapjack_diner.log')
```

## Functions

Parameters for all of **flapjack-diner**'s functions are organised into three categories:

* Ids -- One or more String or Integer values
* Query parameters -- Top-level hash values
* Payload data -- Arrays of Hashes

While these can be passed in in any order, the convention is that they will be ordered as listed above.

If any operation fails, `Flapjack::Diner.last_error` will contain an error message regarding the failure.

### Contacts

* [create_contacts](#create_contacts)
* [contacts](#contacts)
* [update_contacts](#update_contacts)
* [delete_contacts](#delete_contacts)

### Media

* [create_contact_media](#create_contact_media)
* [media](#media)
* [update_media](#update_media)
* [delete_media](#delete_media)

### Notification rules

* [create_contact_notification_rules](#create_contact_notification_rules)
* [notification_rules](#notification_rules)
* [update_notification_rules](#update_notification_rules)
* [delete_notification_rules](#delete_notification_rules)

### Entities

* [create_entities](#create_entities)
* [entities](#entities)
* [update_entities](#update_entities)

* [create_scheduled_maintenances_entities](#create_scheduled_maintenances_entities)
* [delete_scheduled_maintenances_entities](#delete_scheduled_maintenances_entities)

* [create_unscheduled_maintenances_entities](#create_unscheduled_maintenances_entities)
* [delete_unscheduled_maintenances_entities](#delete_unscheduled_maintenances_entities)

* [create_test_notifications_entities](#create_test_notifications_entities)

### Checks

* [create_scheduled_maintenances_checks](#create_scheduled_maintenances_checks)
* [delete_scheduled_maintenances_checks](#delete_scheduled_maintenances_checks)

* [create_unscheduled_maintenances_checks](#create_unscheduled_maintenances_checks)
* [delete_unscheduled_maintenances_checks](#delete_unscheduled_maintenances_checks)

* [create_test_notifications_checks](#create_test_notifications_checks)

### Reports

* [status_report_entities](#status_report_entities)
* [scheduled_maintenance_report_entities](#scheduled_maintenance_report_entities)
* [unscheduled_maintenance_report_entities](#unscheduled_maintenance_report_entities)
* [downtime_report_entities](#downtime_report_entities)
* [outage_report_entities](#outage_report_entities)

* [status_report_checks](#status_report_checks)
* [scheduled_maintenance_report_checks](#scheduled_maintenance_report_checks)
* [unscheduled_maintenance_report_checks](#unscheduled_maintenance_report_checks)
* [downtime_report_checks](#downtime_report_checks)
* [outage_report_checks](#outage_report_checks)

---

<a name="create_contacts">&nbsp;</a>
#### create_contacts

Create one or more contacts.

```ruby
Flapjack::Diner.create_contacts([CONTACT, ...])
```

```
CONTACT
{
  :id => STRING,
  :first_name => STRING,
  :last_name => STRING,
  :email => STRING,
  :tags => [STRING, ...]
}
```

Returns true if creation succeeded or false if creation failed.

<a name="contacts">&nbsp;</a>
#### contacts

Return data for one, some or all contacts.

```ruby
contact = Flapjack::Diner.contacts(ID)
some_contacts = Flapjack::Diner.contacts(ID1, ID2, ...)
all_contacts = Flapjack::Diner.contacts
```

<a name="update_contacts">&nbsp;</a>
#### update_contacts

Update data for one or more contacts.

```ruby
# update values for one contact
Flapjack::Diner.update_contacts(ID, :key => value, ...)

# update values for multiple contacts
Flapjack::Diner.update_contacts(ID1, ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:first_name`, `:last_name`, `:email`, and `:tags`

as well as the linkage operations

`:add_entity`, `:remove_entity`
`:add_medium`, `:remove_medium`
`:add_notification_rule`, `:remove_notification_rule`

which take the id of the relevant resource as the value.

Returns true if updating succeeded or false if updating failed.

<a name="delete_contacts">&nbsp;</a>
#### delete_contacts

Delete one or more contacts.

```ruby
# delete one contact
Flapjack::Diner.delete_contacts(ID)

# delete multiple contacts
Flapjack::Diner.delete_contacts(ID1, ID2, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="create_contact_media">&nbsp;</a>
#### create_contact_media

Create one or more notification media.

```ruby
Flapjack::Diner.create_contact_media(CONTACT_ID, [MEDIUM, ...])
```

```
MEDIUM
{
  :type => STRING,
  :address => STRING,
  :interval => INTEGER,
  :rollup_threshold => INTEGER,
}
```

Returns true if creation succeeded or false if creation failed.

<a name="media">&nbsp;</a>
#### media

Return data for one, some or all notification media. Notification media ids are formed by compounding their linked contact's ID and their type in a string (e.g. '23_sms')

```ruby
medium = Flapjack::Diner.media(ID)
some_media = Flapjack::Diner.media(ID1, ID2, ...)
all_media = Flapjack::Diner.media
```

<a name="update_media">&nbsp;</a>
#### update_media

Update data for one or more notification media.

```ruby
# update values for one medium
Flapjack::Diner.update_media(ID, :key => value, ...)

# update values for multiple media
Flapjack::Diner.update_media(ID1, ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:address`, `:interval`, `:rollup_threshold`

Returns true if updating succeeded or false if updating failed.

<a name="delete_media">&nbsp;</a>
#### delete_contacts

Delete one or more notification media.

```ruby
# delete one medium
Flapjack::Diner.delete_media(ID)

# delete multiple contacts
Flapjack::Diner.delete_media(ID1, ID2, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="create_contact_notification_rules">&nbsp;</a>
#### create_contact_notification_rules

Create one or more notification rules.

```ruby
Flapjack::Diner.create_contact_notification_rules(CONTACT_ID, [NOTIFICATION_RULE, ...])
```

```
NOTIFICATION_RULE
{
  :id => STRING,
  :entities => [STRING, ...],
  :regex_entities => [STRING, ...],
  :tags => [STRING, ...],
  :regex_tags => [STRING, ...],
  :time_restrictions => TODO,
  :unknown_media => [STRING, ...],
  :warning_media => [STRING, ...],
  :critical_media => [STRING, ...],
  :unknown_blackhole => BOOLEAN,
  :warning_blackhole => BOOLEAN,
  :critical_blackhole => BOOLEAN
}
```

Returns true if creation succeeded or false if creation failed.

<a name="notification_rules">&nbsp;</a>
#### notification_rules

Return data for one, some or all notification rules.

```ruby
notification_rule = Flapjack::Diner.notification_rules(ID)
some_notification_rules = Flapjack::Diner.notification_rules(ID1, ID2, ...)
all_notification_rules = Flapjack::Diner.notification_rules
```

<a name="update_notification_rules">&nbsp;</a>
#### update_notification_rules

Update data for one or more notification rules.

```ruby
# update values for one notification rule
Flapjack::Diner.update_notification_rules(ID, :key => value, ...)

# update values for multiple notification rules
Flapjack::Diner.update_notification_rules(ID1, ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:entities`, `:regex_entities`, `:tags`, `:regex_tags`, `:time_restrictions`, `:unknown_media`,  `:warning_media`, `:critical_media`, `:unknown_blackhole`, `:warning_blackhole`, and `:critical_blackhole`

Returns true if updating succeeded or false if updating failed.

<a name="delete_notification_rules">&nbsp;</a>
#### delete_contacts

Delete one or more notification rules.

```ruby
# delete one medium
Flapjack::Diner.delete_notification_rules(ID)

# delete multiple contacts
Flapjack::Diner.delete_notification_rules(ID1, ID2, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="create_entities">&nbsp;</a>
### create_entities

Create one or more entities.

```ruby
Flapjack::Diner.create_entities([ENTITY, ...])
```

```
ENTITY
{
  :id => STRING,
  :name => STRING,
  :tags => [STRING, ...]
}
```

Returns true if creation succeeded or false if creation failed.

<a name="entities">&nbsp;</a>
### entities

Return data for one, some or all entities.

```ruby
entity = Flapjack::Diner.entities(ID)
some_entities = Flapjack::Diner.entities(ID1, ID2, ...)
all_entities = Flapjack::Diner.entities
```

<a name="update_entities">&nbsp;</a>
### update_entities

Update data for one or more entities.

```ruby
# update values for one entity
Flapjack::Diner.update_entities(ID, :key => value, ...)

# update values for multiple entities
Flapjack::Diner.update_entities(ID1, ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:name` and `:tags`

as well as the linkage operations

`:add_contact` and `:remove_contact`

which take the id of the relevant contact as the value.

Returns true if updating succeeded or false if updating failed.


<a name="create_scheduled_maintenances_entities">&nbsp;</a>
### create_scheduled_maintenances_entities

<a name="delete_scheduled_maintenances_entities">&nbsp;</a>
### delete_scheduled_maintenances_entities

<a name="create_unscheduled_maintenances_entities">&nbsp;</a>
### create_unscheduled_maintenances_entities

<a name="delete_unscheduled_maintenances_entities">&nbsp;</a>
### delete_unscheduled_maintenances_entities

<a name="create_test_notifications_entities">&nbsp;</a>
### create_test_notifications_entities

---

<a name="create_scheduled_maintenances_checks">&nbsp;</a>
### create_scheduled_maintenances_checks

<a name="delete_scheduled_maintenances_checks">&nbsp;</a>
### delete_scheduled_maintenances_checks

<a name="create_unscheduled_maintenances_checks">&nbsp;</a>
### create_unscheduled_maintenances_checks

<a name="delete_unscheduled_maintenances_checks">&nbsp;</a>
### delete_unscheduled_maintenances_checks

<a name="create_test_notifications_checks">&nbsp;</a>
### create_test_notifications_checks

---

<a name="status_report_entities">&nbsp;</a>
### status_report_entities

<a name="scheduled_maintenance_report_entities">&nbsp;</a>
### scheduled_maintenance_report_entities

<a name="unscheduled_maintenance_report_entities">&nbsp;</a>
### unscheduled_maintenance_report_entities

<a name="downtime_report_entities">&nbsp;</a>
### downtime_report_entities

<a name="outage_report_entities">&nbsp;</a>
### outage_report_entities


<a name="status_report_checks">&nbsp;</a>
### status_report_checks

<a name="scheduled_maintenance_report_checks">&nbsp;</a>
### scheduled_maintenance_report_checks

<a name="unscheduled_maintenance_report_checks">&nbsp;</a>
### unscheduled_maintenance_report_checks

<a name="downtime_report_checks">&nbsp;</a>
### downtime_report_checks

<a name="outage_report_checks">&nbsp;</a>
### outage_report_checks


---


<a name="entities">&nbsp;</a>
Return an array of monitored entities, and their statuses for all associated checks:

```ruby
Flapjack::Diner.entities
```

The data is returned as an array where each element is a hash representing an entity.

```
// ID     is an integer, to hold e.g. database id from an external system
// NAME   is a string
// STATUS is a hash with the format returned from Flapjack::Diner.status(entity, check)
[{'id'     => ID,
  'name'   => NAME,
  'checks' => [STATUS, STATUS, ...]},
 {},
 ...]
```

---

<a name="checks">&nbsp;</a>
Return an array of checks for an entity:

```ruby
Flapjack::Diner.checks('example.com')
```

The data is returned as an array of strings, where each element is a check name for the provided entity.

```
// CHECK is a string, e.g. 'ssh', 'ping'
[CHECK, CHECK, ...]
```

---
<a name="status_check">&nbsp;</a>
Return the status for a check on an entity

```ruby
Flapjack::Diner.status('example.com', :check => 'ping')
```

The data is returned as a hash:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// STATE is a string, one of 'critical', 'warning', 'ok', 'unknown'
// the TIMESTAMPs are integers representing UTC times for the named events
{'name' => CHECK,
 'state' => STATE,
 'in_unscheduled_maintenance' => BOOLEAN,
 'in_scheduled_maintenance' => BOOLEAN,
 'last_update' => TIMESTAMP,
 'last_problem_notification' => TIMESTAMP,
 'last_recovery_notification' => TIMESTAMP,
 'last_acknowledgement_notification' => TIMESTAMP}
 ```

---
<a name="status">&nbsp;</a>
Return the statuses for all checks on an entity

```ruby
Flapjack::Diner.status('example.com')
```

The data is returned as an array of checks, where each element is a hash with the format returned from Flapjack::Diner.status(entity, check)

```
// STATUS is a hash with the format returned from Flapjack::Diner.status(entity, check)
[STATUS, STATUS, ...]
```

---
<a name="status_bulk">&nbsp;</a>
Return the statuses for all checks on some entities and specified checks on others.

```ruby
# :entity - optional, may be a String or an Array of Strings (entity names)
# :check  - optional, Hash, keys are Strings (entity names), values are Strings or Arrays of Strings (check names)
# At least one of the :entity or :check arguments must be provided
Flapjack::Diner.bulk_status(:entity => 'example.com',
                            :check => {'example2.com' => ['PING', 'SSH'],
                                       'example3.com' => 'PING'})
```

The data is returned as an array, where each element is a hash with the format

```
// ENTITY is a string, one of the entity names provided in the entity or check arguments.
// CHECK is a string, e.g. 'ssh', 'ping'
// STATUS is a hash with the format returned from Flapjack::Diner.status(entity, check)
{'entity' => ENTITY
 'check'  => CHECK,
 'status' => STATUS}
```

---
<a name="scheduled_maintenance_check">&nbsp;</a>
Return an array of scheduled maintenance periods for a check on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.scheduled_maintenances('example.com', :check => 'ping',
                                       :start_time => Time.local(2012, 08, 01),
                                       :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of scheduled maintenance periods, with each element of the array being a hash containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{'start_time' => TIMESTAMP,
  'duration' => DURATION,
  'summary' => SUMMARY,
  'end_time' => TIMESTAMP},
  {...},
  ...]
```

---
<a name="scheduled_maintenance">&nbsp;</a>
Return lists of scheduled maintenance periods for all checks on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.scheduled_maintenances('example.com',
                                       :start_time => Time.local(2012, 08, 01),
                                       :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the scheduled maintenance periods for a check under the entity :

```
// CHECK is a string, e.g. 'ssh', 'ping'
// SCHED_MAINT is a hash with the same format as an individual element of
//   the array returned from Flapjack::Diner.scheduled_maintenances(entity, check)
[{'check' => CHECK,
  'scheduled_maintenance' => [SCHED_MAINT, ...]
 },
 {'check' => CHECK,
  'scheduled_maintenance' => [SCHED_MAINT, ...]
 }]
```

---
<a name="scheduled_maintenance_bulk">&nbsp;</a>
Return lists of scheduled maintenance periods for all checks on some entities and specified checks on others.

```ruby
# :entity - optional, may be a String or an Array of Strings (entity names)
# :check  - optional, Hash, keys are Strings (entity names), values are Strings
#             or Arrays of Strings (check names)
# At least one of the :entity or :check arguments must be provided
Flapjack::Diner.bulk_scheduled_maintenances(:entity => 'example.com',
                                            :check => {'example2.com' => ['PING', 'SSH'],
                                                       'example3.com' => 'PING'})
```

The data is returned as an array, where each element is a hash with the format

```
// ENTITY is a string, one of the entity names provided in the entity or check arguments
// CHECK is a string, e.g. 'ssh', 'ping'
// SCHED_MAINT is a hash with the same format as an individual element of the array returned from Flapjack::Diner.scheduled_maintenances(entity, check)
{'entity' => ENTITY
 'check'  => CHECK,
 'scheduled_maintenances' => [SCHED_MAINT, ...]}
```

Please note the plural for the 'scheduled_maintenances' hash key, which is different to
the other methods.

---
<a name="unscheduled_maintenance_check">&nbsp;</a>
Return an array of unscheduled maintenance periods for a check on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', :check => 'ping',
                                         :start_time => Time.local(2012, 08, 01),
                                         :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of unscheduled maintenance periods, with each element of the array being a hash containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{'start_time' => TIMESTAMP,
  'duration' => DURATION,
  'summary' => SUMMARY,
  'end_time' => TIMESTAMP},
  {...},
  ...]
```

---
<a name="unscheduled_maintenance">&nbsp;</a>
Return lists of unscheduled maintenance periods for all checks on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.unscheduled_maintenances('example.com',
                                         :start_time => Time.local(2012, 08, 01),
                                         :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the unscheduled maintenance periods for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// UNSCHED_MAINT is a hash with the same format as an individual element of
//   the array returned from Flapjack::Diner.unscheduled_maintenances(entity, check)
[{'check' => CHECK,
  'unscheduled_maintenance' => [UNSCHED_MAINT, ...]
 },
 {'check' => CHECK,
  'unscheduled_maintenance' => [UNSCHED_MAINT, ...]
 }]
```

---
<a name="unscheduled_maintenance_bulk">&nbsp;</a>
Return lists of unscheduled maintenance periods for all checks on some entities and specified checks on others.

```ruby
# :entity - optional, may be a String or an Array of Strings (entity names)
# :check  - optional, Hash, keys are Strings (entity names), values are Strings
#             or Arrays of Strings (check names)
# At least one of the :entity or :check arguments must be provided
Flapjack::Diner.bulk_unscheduled_maintenances(:entity => 'example.com',
                                              :check => {'example2.com' => ['PING', 'SSH'],
                                                         'example3.com' => 'PING'})
```

The data is returned as an array, where each element is a hash with the format

```
// ENTITY is a string, one of the entity names provided in the entity or check arguments
// CHECK is a string, e.g. 'ssh', 'ping'
// UNSCHED_MAINT is a hash with the same format as an individual element of the
//   array returned from Flapjack::Diner.unscheduled_maintenances(entity, check)
{'entity' => ENTITY
 'check'  => CHECK,
 'unscheduled_maintenances' => [UNSCHED_MAINT, ...]
}
```

Please note the plural for the 'unscheduled_maintenances' hash key, which is different to
the other methods.

---
<a name="outages_check">&nbsp;</a>
Return an array of outages for a check on an entity (all times for which the check was failing):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.outages('example.com', :check => 'ping',
                        :start_time => Time.local(2012, 08, 01),
                        :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of outage periods, with each element of the array being a hash containing data about that outage period.

```
// STATE is a string, one of 'critical', 'warning', 'ok', 'unknown'
// the TIMESTAMPs are integers representing UTC times for the named events
// SUMMARY is a string providing a description of the period, may be empty
[{'state' => STATE,
  'start_time' => TIMESTAMP,
  'end_time' => TIMESTAMP,
  'summary' => SUMMARY},
  {...},
  ...]
```

---
<a name="outages">&nbsp;</a>
Return lists of outages for all checks on an entity (all times for which said checks were failing):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.outages('example.com', :start_time => Time.local(2012, 08, 01),
                                       :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the outages for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// OUTAGE is a hash with the same format as an individual element of the array returned from Flapjack::Diner.outages(entity, check)
[{'check' => CHECK,
  'outages' => [OUTAGE, ...]
 },
 {'check' => CHECK,
  'outages' => [OUTAGE, ...]
 }]
```

---
<a name="outages_bulk">&nbsp;</a>
Return lists of outages for all checks on some entities and specified checks on others.

```ruby
# :entity - optional, may be a String or an Array of Strings (entity names)
# :check  - optional, Hash, keys are Strings (entity names), values are Strings
#             or Arrays of Strings (check names)
# At least one of the :entity or :check arguments must be provided
Flapjack::Diner.bulk_outages(:entity => 'example.com',
                             :check => {'example2.com' => ['PING', 'SSH'],
                                        'example3.com' => 'PING'})
```

The data is returned as an array, where each element is a hash with the format

```
// ENTITY is a string, one of the entity names provided in the entity or check arguments
// CHECK is a string, e.g. 'ssh', 'ping'
// OUTAGE is a hash with the same format as an individual element of the array
//   returned from Flapjack::Diner.outages(entity, check)
{'entity' => ENTITY
 'check'  => CHECK,
 'outages' => [OUTAGE, ...]
}
```

---
<a name="downtimes_check">&nbsp;</a>
Return an array of downtimes for a check on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.downtime('example.com', :check => 'ping',
                         :start_time => Time.local(2012, 08, 01),
                         :end_time => Time.local(2012, 09, 01))
```

Returns a hash with some statistics about the downtimes, including an array of the downtimes themselves. This may not be the same as would be returned from the 'outages' call for the same time period, as if scheduled maintenance periods overlap any of those times then they will be reduced, split or discarded to fit.

```
// TOTAL SECONDS gives the sum of the time spent in that state for each check state.
// PERCENTAGES represents the proportion of the total time that the check was
//   in each state. Will be null if either start or end time were not provided
//   in the request.
// OUTAGE is a hash with the same format as an individual element of the array
//   returned from Flapjack::Diner.outages(entity, check).
{'total_seconds' => {STATE => INTEGER, ...},
 'percentages' => {STATE => INTEGER, ...},
 'downtime' => [OUTAGE, ...]
}
```

---
<a name="downtimes">&nbsp;</a>
Return an array of downtimes for all checks on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.downtime('example.com', :start_time => Time.local(2012, 08, 01),
                         :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents a downtime report for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// DOWNTIME is a hash with the same format those returned from
//   Flapjack::Diner.downtime(entity, check)
[{'check' => CHECK,
  'downtime' => [DOWNTIME, ...]
 },
 {'check' => CHECK,
  'downtime' => [DOWNTIME, ...]
 }]
```

---
<a name="downtimes_bulk">&nbsp;</a>

Return lists of downtimes for all checks on some entities and specified checks on others.

```ruby
# :entity - optional, may be a String or an Array of Strings (entity names)
# :check  - optional, Hash, keys are Strings (entity names), values are Strings
#             or Arrays of Strings (check names)
# At least one of the :entity or :check arguments must be provided
Flapjack::Diner.bulk_downtime(:entity => ['example.com', 'example4.com'],
                              :check => {'example2.com' => ['PING', 'SSH'],
                                         'example3.com' => 'PING'})
```

The data is returned as an array, where each element is a hash with the format

```
// ENTITY is a string, one of the entity names provided in the entity or check arguments
// CHECK is a string, e.g. 'ssh', 'ping'
// DOWNTIME is a hash with the same format as an individual element of the array
//   returned from Flapjack::Diner.downtime(entity, check)
{'entity' => ENTITY
 'check'  => CHECK,
 'downtime' => [DOWNTIME, ...]
}
```

---
<a name="create_scheduled_maintenance">&nbsp;</a>
Create a scheduled maintenance period for a check on an entity:

```ruby
# start_time (Time object, required)
# duration (Integer, required) is measured in seconds
# summary (String, optional)
Flapjack::Diner.create_scheduled_maintenance!('example.com', 'ping',
  :start_time => Time.local(2012, 12, 01), :duration => (60 * 60),
  :summary => 'changing stuff')
```

Returns a boolean value representing the success or otherwise of the creation of the scheduled maintenance period by the server.

---
<a name="create_scheduled_maintenance_bulk">&nbsp;</a>
Create scheduled maintenance periods for all checks on some entities and specified checks on others.

```ruby
# start_time (Time object, required)
# duration (Integer, required) is measured in seconds
# summary (String, optional)
Flapjack::Diner.bulk_create_scheduled_maintenance!(:entity => ['example.com', 'example2.com'],
  :check => {'example3.com' => 'ping'}, :start_time => Time.local(2012, 12, 01),
  :duration => (60 * 60), :summary => 'changing stuff')
```

Returns a boolean value representing the success or otherwise of the creation of the scheduled maintenance periods by the server.

---
<a name="delete_scheduled_maintenance">&nbsp;</a>
Delete a scheduled maintenance period for a check on an entity:

```ruby
# start_time (Time object, required)
Flapjack::Diner.delete_scheduled_maintenance!('example.com', 'ping',
  :start_time => Time.local(2012, 12, 01))
```

Returns a boolean value representing the success or otherwise of the deletion of the scheduled maintenance periods by the server.

---
<a name="delete_scheduled_maintenance_bulk">&nbsp;</a>
Delete a scheduled maintenance period for all checks on some entities and specified checks on others.

```ruby
# start_time (Time object, required)
Flapjack::Diner.bulk_delete_scheduled_maintenance!(:check => {'example.com' => ['ping', 'ssh']},
  :start_time => Time.local(2012, 12, 01))
```

Returns a boolean value representing the success or otherwise of the deletion of the scheduled maintenance periods by the server.

---
<a name="acknowledge">&nbsp;</a>
Acknowledge the current state for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.acknowledge!('example.com', 'ping', :summary => 'ack')
```

Returns a boolean value representing the success or otherwise of the creation of the acknowledgement by the server.

---
<a name="acknowledge_bulk">&nbsp;</a>
Acknowledge the current state for all checks on some entities and specified checks on others.

```ruby
# summary (String, optional)
Flapjack::Diner.bulk_acknowledge!(:entity => 'example.com',
  :check => {'example2.com' => 'ping'}, :summary => 'ack')
```

Returns a boolean value representing the success or otherwise of the creation of the acknowledgements by the server.

---
<a name="delete_unscheduled_maintenance">&nbsp;</a>
Delete an unscheduled maintenance period for a check on an entity:

```ruby
# end_time (Time object, optional)
Flapjack::Diner.delete_unscheduled_maintenance!('example.com', 'ping',
  :end_time => Time.local(2012, 12, 01))
```

Returns a boolean value representing the success or otherwise of the deletion of the scheduled maintenance periods by the server.

---
<a name="delete_unscheduled_maintenance_bulk">&nbsp;</a>
Delete unscheduled maintenance periods for all checks on some entities and specified checks on others.

```ruby
# end_time (Time object, optional)
Flapjack::Diner.bulk_delete_unscheduled_maintenance!(:check => {'example.com' => ['ping', 'ssh']},
  :end_time => Time.local(2012, 12, 01))
```

Returns a boolean value representing the success or otherwise of the deletion of the scheduled maintenance periods by the server.

---
<a name="test_notifications">&nbsp;</a>
Generate test notifications for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.test_notifications!('example.com', 'HOST',
  :summary => 'Testing notifications to all contacts interested in the HOST check on example.com')
```

Returns a boolean value representing the success or otherwise of the creation of the notifications by the server.

---
<a name="test_notifications_bulk">&nbsp;</a>
Generate test notifications for all checks on some entities and specified checks on others.

```ruby
# summary (String, optional)
Flapjack::Diner.bulk_test_notifications!(:entity => 'example.com',
  :check => {'example2.com' => 'ping'}, :summary => 'Testing notifications')
```

Returns a boolean value representing the success or otherwise of the creation of the notifications by the server.

---

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
