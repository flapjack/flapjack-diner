# Flapjack::Diner

[![Travis CI Status][id_travis_img]][id_travis_link]

[id_travis_link]: https://travis-ci.org/flapjack/flapjack-diner
[id_travis_img]: https://travis-ci.org/flapjack/flapjack-diner.png

Access the JSON API of a [Flapjack](http://flapjack.io/) system monitoring server.

Please note that the following documentation has not yet been updated for the upcoming `v2.0.0alpha1` release of this gem. You may instead be looking for [documentation for the latest released version](https://github.com/flapjack/flapjack-diner/blob/maint/1.x/README.md).

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

If you want to alter timeout periods for HTTP connection open and reading responses:

```ruby
# Set HTTP connect timeout to 30 seconds
Flapjack::Diner.open_timeout(30)

# Set HTTP read timeout to 5 minutes
Flapjack::Diner.read_timeout(300)
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

If any operation fails (returning nil), `Flapjack::Diner.last_error` will contain an error message regarding the failure.

### Checks

* [create_checks](#create_checks)
* [checks](#checks)
* [update_checks](#update_checks)
* [delete_checks](#delete_checks)

### Contacts

* [create_contacts](#create_contacts)
* [contacts](#contacts)
* [update_contacts](#update_contacts)
* [delete_contacts](#delete_contacts)

### Media

* [create_media](#create_media)
* [media](#media)
* [update_media](#update_media)
* [delete_media](#delete_media)

### Rules

* [create_rules](#create_rules)
* [rules](#rules)
* [update_rules](#update_rules)
* [delete_rules](#delete_rules)

### Tags

* [create_tags](#create_tags)
* [tags](#tags)
* [update_tags](#update_tags)
* [delete_tags](#delete_tags)

### Maintenance periods

* [create_scheduled_maintenances](#create_scheduled_maintenances)
* [update_scheduled_maintenances](#update_scheduled_maintenances)
* [delete_scheduled_maintenances](#delete_scheduled_maintenances)

* [update_unscheduled_maintenances](#update_unscheduled_maintenances)

### Events

* [create_acknowledgements](#create_acknowledgements)
* [create_test_notifications](#create_test_notifications)

### Check states

* [states](#states)

### Metrics

* [metrics](#metrics)
* [statistics](#statistics)

---

<a name="section_checks">&nbsp;</a>
### Checks

<a name="create_checks">&nbsp;</a>
### create_checks

Create one or more checks.

```ruby
Flapjack::Diner.create_checks(CHECK, ...)
```

```
CHECK
{
  :id      => STRING,
  :name    => STRING,
  :enabled => BOOLEAN,
  :tags    => [TAG_NAME, ...]
}
```

FIXME create return values

Returns an array of check ids if creation succeeded, or false if creation failed.

<a name="checks">&nbsp;</a>
### checks

Return data for one, some or all checks.

```ruby
check = Flapjack::Diner.checks(CHECK_ID)
some_checks = Flapjack::Diner.checks(CHECK_ID, CHECK_ID, ...)
first_page_of_checks = Flapjack::Diner.checks
```

<a name="update_checks">&nbsp;</a>
### update_checks

Update data for one or more checks.

```ruby
# update values for one check
Flapjack::Diner.update_checks(CHECK_ID, KEY => VALUE, ...)

# update values for multiple checks
Flapjack::Diner.update_checks({CHECK_ID, KEY => VALUE, ...}, {CHECK_ID, KEY => VALUE, ...})
```

Acceptable update field keys are

`:enabled`, `:name` and `:tags`

Returns true if updating succeeded or false if updating failed.

<a name="delete_checks">&nbsp;</a>
#### delete_checks

Delete one or more checks.

```ruby
# delete one check
Flapjack::Diner.delete_checks(CHECK_ID)

# delete multiple check
Flapjack::Diner.delete_checks(CHECK_ID, CHECK_ID, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="section_contacts">&nbsp;</a>
### Contacts

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
  :name => STRING,
  :timezone => STRING,
  :tags => [TAG_NAME, ...]
}
```

FIXME create return values

Returns an array of contact ids if creation succeeded, or false if creation failed.

<a name="contacts">&nbsp;</a>
#### contacts

Return data for one, some or all contacts.

```ruby
contact = Flapjack::Diner.contacts(CONTACT_ID)
some_contacts = Flapjack::Diner.contacts(CONTACT_ID, CONTACT_ID, ...)
first_page_of_contacts = Flapjack::Diner.contacts
```

<a name="update_contacts">&nbsp;</a>
#### update_contacts

Update data for one or more contacts.

```ruby
# update values for one contact
Flapjack::Diner.update_contacts(CONTACT_ID, KEY => VALUE, ...)

# update values for multiple contacts
Flapjack::Diner.update_contacts({CONTACT_ID, KEY => VALUE, ...}, {CONTACT_ID, KEY => VALUE, ...})
```

Acceptable update field keys are

`:name`, `:timezone` and `:tags`

Returns true if updating succeeded, false if updating failed.

<a name="delete_contacts">&nbsp;</a>
#### delete_contacts

Delete one or more contacts.

```ruby
# delete one contact
Flapjack::Diner.delete_contacts(CONTACT_ID)

# delete multiple contacts
Flapjack::Diner.delete_contacts(CONTACT_ID, CONTACT_ID, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="section_media">&nbsp;</a>
### Media

<a name="create_media">&nbsp;</a>
#### create_media

Create one or more notification media.

```ruby
Flapjack::Diner.create_media(MEDIUM, MEDIUM, ...)
```

```ruby
# MEDIUM
{
  :id => UUID,
  :transport => STRING,               # required
  :address => STRING,                 # required (context depends on transport)
  :interval => INTEGER,               # required (if transport != 'pagerduty')
  :rollup_threshold => INTEGER,       # required (if transport != 'pagerduty')
  :pagerduty_subdomain => STRING,     # required (if transport == 'pagerduty')
  :pagerduty_token => STRING,         # required (if transport == 'pagerduty')
  :pagerduty_ack_duration => INTEGER, # required (if transport == 'pagerduty')
  :contact => CONTACT_ID,             # required
  :rules => [RULE_ID, RULE_ID, ...]
}
```

Returns an array of media ids if creation succeeded, or false if creation failed.

<a name="media">&nbsp;</a>
#### media

Return data for one, some or all notification media.

```ruby
medium = Flapjack::Diner.media(MEDIUM_ID)
some_media = Flapjack::Diner.media(MEDIUM_ID, MEDIUM_ID, ...)
first_page_of_media = Flapjack::Diner.media
```

<a name="update_media">&nbsp;</a>
#### update_media

Update data for one or more notification media.

```ruby
# update values for one medium
Flapjack::Diner.update_media(MEDIUM_ID, KEY => VALUE, ...)

# update values for multiple media
Flapjack::Diner.update_media({MEDIUM_ID, KEY => VALUE, ...}, {MEDIUM_ID, KEY => VALUE, ...})
```

Acceptable update field keys are

`:address`, `:interval`, `:rollup_threshold`, `:pagerduty_subdomain`, `:pagerduty_token`, `:pagerduty_ack_duration` and `:rules`

Returns true if updating succeeded or false if updating failed.

<a name="delete_media">&nbsp;</a>
#### delete_media

Delete one or more notification media.

```ruby
# delete one medium
Flapjack::Diner.delete_media(MEDIUM_ID)

# delete multiple media
Flapjack::Diner.delete_media(MEDIUM_ID, MEDIUM_ID, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="section_checks">&nbsp;</a>
### Rules

<a name="create_rules">&nbsp;</a>
#### create_rules

Create one or more notification rules.

```ruby
Flapjack::Diner.create_rules(RULE, ...)
```

FIXME accept conditions_list as an array of strings and create the array that Flapjack accepts here

```ruby
# RULE
{
  :id              => UUID_STRING,
  :conditions_list => STRING,
  :is_blackhole    => BOOLEAN,
  :contact         => CONTACT_ID,       # required
  :media           => [MEDIUM_ID, ...]
  :tags            => [TAG_NAME, ...]
}
```

FIXME create return values

Returns a single rule or array of rules (depending on what was passed in), or false if creation failed.

<a name="rules">&nbsp;</a>
#### rules

Return data for one, some or all notification rules.

FIXME convert the conditions_list string to an array

```ruby
rule = Flapjack::Diner.rules(RULE_ID)
some_rules = Flapjack::Diner.rules(RULE_ID, RULE_ID, ...)
first_page_of_rules = Flapjack::Diner.rules
```

<a name="update_rules">&nbsp;</a>
#### update_rules

Update data for one or more notification rules.

FIXME accept conditions_list as an array of strings and create the array that Flapjack accepts here

```ruby
# update values for one rule
Flapjack::Diner.update_rules(:id => RULE_ID, KEY => VALUE, ...)

# update values for multiple rules
Flapjack::Diner.update_rules({:id => RULE_ID, KEY => VALUE, ...}, {:id => RULE_ID, KEY => VALUE, ...})
```

Acceptable update field keys are

  `:conditions_list`, `:is_blackhole`, `:media` and `:tags`

Returns true if updating succeeded or false if updating failed.

<a name="delete_rules">&nbsp;</a>
#### delete_rules

Delete one or more notification rules.

```ruby
# delete one rule
Flapjack::Diner.delete_rules(RULE_ID)

# delete multiple rules
Flapjack::Diner.delete_rules(RULE_ID, RULE_ID, ...)
```

Returns true if deletion succeeded or false if deletion failed.

---

<a name="section_maintenance_periods">&nbsp;</a>
### Maintenance periods

<a name="create_scheduled_maintenances">&nbsp;</a>
### create_scheduled_maintenances

Create one or more scheduled maintenance periods (`duration` seconds in length) on one or more checks.

```ruby
Flapjack::Diner.create_scheduled_maintenances(SCHEDULED_MAINTENANCE, ...)
```

```ruby
SCHEDULED_MAINTENANCE
{
  :id => UUID,
  :start_time => DATETIME, # required
  :duration => INTEGER,    # defaults to 14400 (i.e. 4 hours in seconds)
  :summary => STRING,
  :check => CHECK_ID,      # one (and only one) of :check or :tag must be provided
  :tag => TAG_NAME         # :tag will create scheduled maintenance periods for all checks that this tag is associated with
}
```

FIXME create return values

Returns true if creation succeeded or false if creation failed.

<a name="update_scheduled_maintenances">&nbsp;</a>
### update_scheduled_maintenances

FIXME documentation needed here

<a name="delete_scheduled_maintenances">&nbsp;</a>
### delete_scheduled_maintenances

Delete one or more scheduled maintenance periods.

```ruby
Flapjack::Diner.delete_scheduled_maintenances(SCHEDULED_MAINTENANCE_ID)
Flapjack::Diner.delete_scheduled_maintenances(SCHEDULED_MAINTENANCE_ID, SCHEDULED_MAINTENANCE_ID, ...)
```

Returns true if deletion succeeded or false if deletion failed.

<a name="create_acknowledgements">&nbsp;</a>
### create_acknowledgements

Acknowledges any failing checks from those passed and sets up unscheduled maintenance (`duration` seconds long) on them.

```ruby
Flapjack::Diner.create_acknowledgements(ACKNOWLEDGEMENT, ...)
```

```ruby
# ACKNOWLEDGEMENT
{
  :summary => STRING,
  :duration => INTEGER,
  :check => CHECK_ID,   # one (and only one) of :check or :tag must be provided
  :tag => TAG_NAME      # :tag will acknowledge all failing checks that this tag is associated with
}
```

FIXME create return values

Returns true if creation succeeded or false if creation failed.

<a name="update_unscheduled_maintenances">&nbsp;</a>
### update_unscheduled_maintenances

Finalises currently existing unscheduled maintenance periods for acknowledged checks. The periods end at the time provided in the `:end_time` parameter.

```ruby
Flapjack::Diner.update_unscheduled_maintenances(:id => UNSCHEDULED_MAINTENANCE_ID, KEY => VALUE)

Flapjack::Diner.update_unscheduled_maintenances({:id => UNSCHEDULED_MAINTENANCE_ID, KEY => VALUE},
  {:id => UNSCHEDULED_MAINTENANCE_ID, KEY => VALUE}, ...)
```

Returns true if the finalisation succeeded or false if deletion failed.

<a name="create_test_notifications">&nbsp;</a>
### create_test_notifications

Instructs Flapjack to issue test notifications on the passed checks. These notifications will be sent to contacts configured to receive notifications for those checks.

```ruby
Flapjack::Diner.create_test_notifications(TEST_NOTIFICATION, ...)
```

```ruby
# TEST_NOTIFICATION
{
  :summary => STRING,
  :check => CHECK_ID, # one (and only one) of :check or :tag must be provided
  :tag => TAG_NAME    # :tag will send test notifications for all checks that this tag is associated with
}
```

FIXME create return values

Returns true if creation succeeded or false if creation failed.

---

<a name="common_options_get">&nbsp;</a>
### Common options for all GET requests

| Option       |  Type                       | Description |
|--------------|-----------------------------|-------------|
| `:fields`    |  String or Array of Strings | Limit the fields of `:include`d records |
| `:filter`    |  Hash                       | Resources must match query terms |
| `:include`   |  String or Array of Strings | Full resources to return with the response |
| `:sort`      |  String or Array of Strings | How the resources should be sorted |
| `:page`      |  Integer, > 0               | Page number |
| `:per_page`  |  Integer, > 0               | Number of resources per page |

---

<a name="object_relationships_read">&nbsp;</a>
### Retrieving object relationships

The following operations are supported: they will all return data in the format

```ruby
{:type => LINKED_TYPE, :id => UUID}
```

(for singular resources), or

```ruby
[{:type => LINKED_TYPE, :id => UUID}, {:type => LINKED_TYPE, :id => UUID}, ...]
```

for multiple resources.

```
check_link_alerting_media(check_id, opts = {})
check_link_contacts(check_id, opts = {})
check_link_current_scheduled_maintenances(check_id, opts = {})
check_link_current_state(check_id, opts = {})
check_link_current_unscheduled_maintenance(check_id, opts = {})
check_link_latest_notifications(check_id, opts = {})
check_link_scheduled_maintenances(check_id, opts = {})
check_link_states(check_id, opts = {})
check_link_tags(check_id, opts = {})
check_link_unscheduled_maintenances(check_id, opts = {})

contact_link_checks(contact_id, opts = {})
contact_link_media(contact_id, opts = {})
contact_link_rules(contact_id, opts = {})

medium_link_alerting_checks(medium_id, opts = {})
medium_link_contact(medium_id, opts = {})
medium_link_rules(medium_id, opts = {})

rule_link_contact(rule_id, opts = {})
rule_link_media(rule_id, opts = {})
rule_link_tags(rule_id, opts = {})

state_link_check(state_id, opts = {})

tag_link_checks(tag_name, opts = {})
tag_link_rules(tag_name, opts = {})
```

All returned results are paginated, and the [common options for GET requests](#common_options_get) apply here too. (`:include` and `:sort` option strings must start with the type of the related resource (FIXME flapjack-diner should prepend this automatically.))

<a name="object_relationships_write">&nbsp;</a>
### Manipulating object relationships

The following operations are supported; please note that some associations (e.g. associating a rule with a contact) must be made on object creation, via the secondary resource's create method, and cannot be altered later.

```
create_check_link_tags(check_id, *tags_names)
update_check_link_tags(check_id, *tags_names)
delete_check_link_tags(check_id, *tags_names)

create_medium_link_rules(medium_id, *rules_ids)
update_medium_link_rules(medium_id, *rules_ids)
delete_medium_link_rules(medium_id, *rules_ids)

create_rule_link_media(rule_id, *media_ids)
update_rule_link_media(rule_id, *media_ids)
delete_rule_link_media(rule_id, *media_ids)

create_rule_link_tags(rule_id, *tags_names)
update_rule_link_tags(rule_id, *tags_names)
delete_rule_link_tags(rule_id, *tags_names)

create_tag_link_checks(tag_name, *checks_ids)
update_tag_link_checks(tag_name, *checks_ids)
delete_tag_link_checks(tag_name, *checks_ids)

create_tag_link_rules(tag_name, *rules_ids)
update_tag_link_rules(tag_name, *rules_ids)
delete_tag_link_rules(tag_name, *rules_ids)
```

<a name="object_relationships_write_create">&nbsp;</a>
#### `create_{resource}_link_{related}`

Creates new links between the `resource` represented by the first argument and the `related` resources represented by the rest of the arguments. At least one `related` resource identifier must be provided. If the `related` resource is already linked, it is skipped. (FIXME check JSONAPI spec)

<a name="object_relationships_write_update">&nbsp;</a>
#### `update_{resource}_link_{related}`

Replace all current links between the `resource` represented by the first argument with the `related` resources represented by the rest of the arguments. If there are no further arguments, removes all current links of that type for the `resource`, otherwise removes any not present in the passed `related` resources and adds any that are passed but not already present.

<a name="object_relationships_write_delete">&nbsp;</a>
#### `delete_{resource}_link_{related}`

Remove the link between the `resource` represented by the first argument, and the `related` resources represented by the rest of the arguments. If there is no link for a related resource, deletion is skipped. (FIXME check JSONAPI spec)

---

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
