# Flapjack::Diner

[![Travis CI Status][id_travis_img]][id_travis_link]

[id_travis_link]: https://travis-ci.org/flapjack/flapjack-diner
[id_travis_img]: https://travis-ci.org/flapjack/flapjack-diner.png

Access the JSON API of a [Flapjack](http://flapjack.io/) system monitoring server.

Note that flapjack-diner [releases](https://github.com/flapjack/flapjack-diner/releases) after [1.0.0.rc1](https://github.com/flapjack/flapjack-diner/releases/tag/v1.0.0.rc1) require the [JSONAPI](http://flapjack.io/docs/jsonapi) gateway of Flapjack to connect to. All previous releases (0.x) require the older [API](http://flapjack.io/docs/0.9/API) Flapjack gateway.


## Installation

Add this line to your application's Gemfile:

    gem 'flapjack-diner', :github => 'flapjack/flapjack-diner'

And then execute:

    $ bundle

Note, you can also install from [RubyGems.org](https://rubygems.org/gems/flapjack-diner) as usual.

## Usage

Set the URI of the Flapjack server:

```ruby
Flapjack::Diner.base_uri('127.0.0.1:5000')
```

Optionally, set a logger to log requests & responses:

```ruby
Flapjack::Diner.logger = Logger.new('logs/flapjack_diner.log')
```

If you want the old behaviour wrt returning hashes with keys as strings (they're now symbols by default) then:

```ruby
Flapjack::Diner.return_keys_as_strings = true
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

### Pagerduty credentials

* [create_contact_pagerduty_credentials](#create_contact_pagerduty_credentials)
* [pagerduty_credentials](#pagerduty_credentials)
* [update_pagerduty_credentials](#update_pagerduty_credentials)
* [delete_pagerduty_credentials](#delete_pagerduty_credentials)

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
* [update_unscheduled_maintenances_entities](#update_unscheduled_maintenances_entities)

* [create_test_notifications_entities](#create_test_notifications_entities)

### Checks

* [create_checks](#create_checks)
* [checks](#checks)
* [update_checks](#update_checks)

* [create_scheduled_maintenances_checks](#create_scheduled_maintenances_checks)
* [delete_scheduled_maintenances_checks](#delete_scheduled_maintenances_checks)

* [create_unscheduled_maintenances_checks](#create_unscheduled_maintenances_checks)
* [update_unscheduled_maintenances_checks](#update_unscheduled_maintenances_checks)

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

`:first_name`, `:last_name`, `:email`

as well as the linkage operations

`:add_entity`, `:remove_entity`
`:add_notification_rule`, `:remove_notification_rule`
`:add_tag`, `:remove_tag`

which take the id (for entity and notification rule) or name (for tag) of the relevant resource as the value.

(NB: `:add_medium` and `:remove_medium` are not supported in Flapjack v1.0 but should be in future versions.)

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
  :rollup_threshold => INTEGER
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
#### delete_media

Delete one or more notification media.

```ruby
# delete one medium
Flapjack::Diner.delete_media(ID)

# delete multiple media
Flapjack::Diner.delete_media(ID1, ID2, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="create_contact_pagerduty_credentials">&nbsp;</a>
#### create_contact_media

Create pagerduty credentials for a contact.

```ruby
Flapjack::Diner.create_contact_pagerduty_credentials(CONTACT_ID, PAGERDUTY_CREDENTIALS)
```

```
PAGERDUTY_CREDENTIALS
{
  :service_key => STRING,
  :subdomain => STRING,
  :username => STRING,
  :password => STRING
}
```

Returns true if creation succeeded or false if creation failed.

<a name="pagerduty_credentials">&nbsp;</a>
#### pagerduty_credentials

Return pagerduty credentials for a contact.

```ruby
pagerduty_credentials = Flapjack::Diner.pagerduty_credentials(CONTACT_ID)
some_pagerduty_credentials = Flapjack::Diner.pagerduty_credentials(CONTACT_ID1, CONTACT_ID2, ...)
all_pagerduty_credentials = Flapjack::Diner.pagerduty_credentials
```

<a name="update_pagerduty_credentials">&nbsp;</a>
#### update_pagerduty_credentials

Update pagerduty credentials for one or more contacts.

```ruby
# update pagerduty_credentials for one contact
Flapjack::Diner.update_pagerduty_credentials(CONTACT_ID, :key => value, ...)

# update pagerduty_credentials for multiple contacts
Flapjack::Diner.update_pagerduty_credentials(CONTACT_ID1, CONTACT_ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:service_key`, `:subdomain`, `:username`, `:password`

Returns true if updating succeeded or false if updating failed.

<a name="delete_pagerduty_credentials">&nbsp;</a>
#### delete_pagerduty_credentials

Delete pagerduty credentials for one or more contacts

```ruby
# delete pagerduty_credentials for one contact
Flapjack::Diner.delete_pagerduty_credentials(CONTACT_ID)

# delete pagerduty_credentials for multiple contacts
Flapjack::Diner.delete_pagerduty_credentials(CONTACT_ID1, CONTACT_ID2, ...)
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

There are no valid update field keys yet.

The linkage operations

`:add_contact` and `:remove_contact`
`:add_tag` and `:remove_tag`

take the id (for contact) or the name (for tag) of the relevant resource as the value.

Returns true if updating succeeded or false if updating failed.


<a name="create_scheduled_maintenances_entities">&nbsp;</a>
### create_scheduled_maintenances_entities

Create one or more scheduled maintenance periods (`duration` seconds in length) on all checks for the provided entities.

```ruby
Flapjack::Diner.create_scheduled_maintenances_entities(ENTITY_ID(S), [SCHEDULED_MAINTENANCE, ...])
```

```
SCHEDULED_MAINTENANCE
{
  :start_time => DATETIME,
  :duration => INTEGER,
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

<a name="delete_scheduled_maintenances_entities">&nbsp;</a>
### delete_scheduled_maintenances_entities

Delete scheduled maintenance periods starting at a specific time for checks across one or more entities.

```ruby
Flapjack::Diner.delete_scheduled_maintenances_entities(ENTITY_ID(S), :start_time => DATETIME)
```

Returns true if deletion succeeded or false if deletion failed. Raises an exception if the `:start_time` parameter is not supplied.

<a name="create_unscheduled_maintenances_entities">&nbsp;</a>
### create_unscheduled_maintenances_entities

Acknowledges any failing checks on the passed entities and sets up unscheduled maintenance (`duration` seconds long) on them.

```ruby
Flapjack::Diner.create_unscheduled_maintenances_entities(ENTITY_ID(S), [SCHEDULED_MAINTENANCE, ...])
```

```
UNSCHEDULED_MAINTENANCE
{
  :duration => INTEGER,
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

<a name="update_unscheduled_maintenances_entities">&nbsp;</a>
### update_unscheduled_maintenances_entities

Finalises currently existing unscheduled maintenance periods for all acknowledged checks in the provided entities. The periods end at the time provided in the `:end_time` parameter.

```ruby
Flapjack::Diner.update_unscheduled_maintenances_entities(ENTITY_ID(S), :end_time => DATETIME)
```

Returns true if the finalisation succeeded or false if deletion failed.

<a name="create_test_notifications_entities">&nbsp;</a>
### create_test_notifications_entities

Instructs Flapjack to issue test notifications on all checks for the passed entities. These notifications will be sent to contacts configured to receive notifications for those checks.

```ruby
Flapjack::Diner.create_test_notifications_entities(ENTITY_ID(S), [TEST_NOTIFICATION, ...])
```

```
TEST_NOTIFICATION
{
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

---

<a name="create_checks">&nbsp;</a>
### create_checks

Create one or more checks.

```ruby
Flapjack::Diner.create_checks([CHECK, ...])
```

```
CHECK
{
  :entity_id => STRING,
  :name      => STRING,
  :tags      => [STRING, ...]
}
```

Returns true if creation succeeded or false if creation failed.

<a name="checks">&nbsp;</a>
### checks

Return basic identity data for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
check = Flapjack::Diner.checks(ID)
some_checks = Flapjack::Diner.checks(ID1, ID2, ...)
all_checks = Flapjack::Diner.checks
```

<a name="update_checks">&nbsp;</a>
### update_checks

Update data for one or more checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
# update values for one checks
Flapjack::Diner.update_checks(ID, :key => value, ...)

# update values for multiple checks
Flapjack::Diner.update_checks(ID1, ID2, ..., :key => value, ...)
```

Acceptable update field keys are

`:enabled`

as well as the linkage operations

`:add_tag` and `:remove_tag`

which take the name of the tag as the value.

Returns true if updating succeeded or false if updating failed.

---

<a name="create_scheduled_maintenances_checks">&nbsp;</a>
### create_scheduled_maintenances_checks

Create one or more scheduled maintenance periods (`duration` seconds in length) on one or more checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
Flapjack::Diner.create_scheduled_maintenances_checks(CHECK_ID(S), [SCHEDULED_MAINTENANCE, ...])
```

```
SCHEDULED_MAINTENANCE
{
  :start_time => DATETIME,
  :duration => INTEGER,
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

<a name="delete_scheduled_maintenances_checks">&nbsp;</a>
### delete_scheduled_maintenances_checks

Delete scheduled maintenance periods starting at a specific time for one or more checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
Flapjack::Diner.delete_scheduled_maintenances_checks(CHECK_ID(S), :start_time => DATETIME)
```

Returns true if deletion succeeded or false if deletion failed. Raises an exception if the `:start_time` parameter is not supplied.

<a name="create_unscheduled_maintenances_checks">&nbsp;</a>
### create_unscheduled_maintenances_checks

Acknowledges any failing checks from those passed and sets up unscheduled maintenance (`duration` seconds long) on them. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
Flapjack::Diner.create_unscheduled_maintenances_checks(CHECK_ID(S), [SCHEDULED_MAINTENANCE, ...])
```

```
UNSCHEDULED_MAINTENANCE
{
  :duration => INTEGER,
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

<a name="update_unscheduled_maintenances_checks">&nbsp;</a>
### update_unscheduled_maintenances_checks

Finalises currently existing unscheduled maintenance periods for acknowledged checks. The periods end at the time provided in the `:end_time` parameter. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
Flapjack::Diner.update_unscheduled_maintenances_checks(CHECK_ID(S), :end_time => DATETIME)
```

Returns true if the finalisation succeeded or false if deletion failed.

<a name="create_test_notifications_checks">&nbsp;</a>
### create_test_notifications_checks

Instructs Flapjack to issue test notifications on the passed checks. These notifications will be sent to contacts configured to receive notifications for those checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
Flapjack::Diner.create_test_notifications_checks(CHECK_ID(S), [TEST_NOTIFICATION, ...])
```

```
TEST_NOTIFICATION
{
  :summary => STRING
}
```

Returns true if creation succeeded or false if creation failed.

---

<a name="status_report_entities">&nbsp;</a>
### status_report_entities

Return a report on status data for checks in one, some or all entities.

```ruby
report = Flapjack::Diner.status_report_entities(ENTITY_ID)
report_some = Flapjack::Diner.status_report_entities(ENTITY_ID1, ENTITY_ID2, ...)
report_all = Flapjack::Diner.status_report_entities
```

<a name="scheduled_maintenance_report_entities">&nbsp;</a>
### scheduled_maintenance_report_entities

Return a report on scheduled maintenance periods for checks in one, some or all entities.

```ruby
report = Flapjack::Diner.scheduled_maintenance_report_entities(ENTITY_ID)
report_some = Flapjack::Diner.scheduled_maintenance_report_entities(ENTITY_ID1, ENTITY_ID2, ...)
report_all = Flapjack::Diner.scheduled_maintenance_report_entities
```

<a name="unscheduled_maintenance_report_entities">&nbsp;</a>
### unscheduled_maintenance_report_entities

Return a report on unscheduled maintenance periods for checks in one, some or all entities.

```ruby
report = Flapjack::Diner.unscheduled_maintenance_report_entities(ENTITY_ID)
report_some = Flapjack::Diner.unscheduled_maintenance_report_entities(ENTITY_ID1, ENTITY_ID2, ...)
report_all = Flapjack::Diner.unscheduled_maintenance_report_entities
```

<a name="downtime_report_entities">&nbsp;</a>
### downtime_report_entities

Return a report on downtime data for checks in one, some or all entities.

```ruby
report = Flapjack::Diner.downtime_report_entities(ENTITY_ID)
report_some = Flapjack::Diner.downtime_report_entities(ENTITY_ID1, ENTITY_ID2, ...)
report_all = Flapjack::Diner.downtime_report_entities
```

<a name="outage_report_entities">&nbsp;</a>
### outage_report_entities

Return a report on outage data for checks in one, some or all entities.

```ruby
report = Flapjack::Diner.outage_report_entities(ENTITY_ID)
report_some = Flapjack::Diner.outage_report_entities(ENTITY_ID1, ENTITY_ID2, ...)
report_all = Flapjack::Diner.outage_report_entities
```

<a name="status_report_checks">&nbsp;</a>
### status_report_checks

Return a report on status data for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
report = Flapjack::Diner.status_report_checks(CHECK_ID)
report_some = Flapjack::Diner.status_report_checks(CHECK_ID1, CHECK_ID2, ...)
report_all = Flapjack::Diner.status_report_checks
```

<a name="scheduled_maintenance_report_checks">&nbsp;</a>
### scheduled_maintenance_report_checks

Return a report on scheduled maintenance periods for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
report = Flapjack::Diner.scheduled_maintenance_report_checks(CHECK_ID)
report_some = Flapjack::Diner.scheduled_maintenance_report_checks(CHECK_ID1, CHECK_ID2, ...)
report_all = Flapjack::Diner.scheduled_maintenance_report_checks
```

<a name="unscheduled_maintenance_report_checks">&nbsp;</a>
### unscheduled_maintenance_report_checks

Return a report on unscheduled maintenance periods for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
report = Flapjack::Diner.unscheduled_maintenance_report_checks(CHECK_ID)
report_some = Flapjack::Diner.unscheduled_maintenance_report_checks(CHECK_ID1, CHECK_ID2, ...)
report_all = Flapjack::Diner.unscheduled_maintenance_report_checks
```

<a name="downtime_report_checks">&nbsp;</a>
### downtime_report_checks

Return a report on downtim data for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
report = Flapjack::Diner.downtime_report_checks(CHECK_ID)
report_some = Flapjack::Diner.downtime_report_checks(CHECK_ID1, CHECK_ID2, ...)
report_all = Flapjack::Diner.downtime_report_checks
```

<a name="outage_report_checks">&nbsp;</a>
### outage_report_checks

Return a report on outage data for one, some or all checks. (Check ids are composed by joining together the check's entity's name, the character ':' and the check's name.)

```ruby
report = Flapjack::Diner.outage_report_checks(CHECK_ID)
report_some = Flapjack::Diner.outage_report_checks(CHECK_ID1, CHECK_ID2, ...)
report_all = Flapjack::Diner.outage_report_checks
```

---

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
