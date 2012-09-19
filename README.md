# Flapjack::Diner

Access the API of a [Flapjack](http://flapjack-project.com/) system monitoring server.

## Installation

Add this line to your application's Gemfile:

    gem 'flapjack-diner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flapjack-diner

## Usage

Set the URI of the Flapjack server:

```ruby
Flapjack::Diner.base_uri('127.0.0.1:5000')
```

---

Return a list of monitored entities, and their statuses for all associated checks:

```ruby
Flapjack::Diner.entities
```

The data is returned as a JSON list where each element is an associative array representing an entity:

```json
// ID    is an integer, to hold e.g. database id from an external system
// NAME  is a string
// CHECK is as defined under Flapjack::Diner.status(entity, check)
[{"id"     : ID,
  "name"   : NAME,
  "checks" : [CHECK, CHECK, ...]},
 {},
 ...]
```
---

Return a list of checks for an entity:

```ruby
Flapjack::Diner.checks('example.com')
```

---

Return the statuses for all checks on an entity

```ruby
Flapjack::Diner.status('example.com')
```

Return the status for a check on an entity

```ruby
Flapjack::Diner.status('example.com', 'ping')
```

Return lists of scheduled maintenance periods for all checks on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.scheduled_maintenances('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return a list of scheduled maintenance periods for a check on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.scheduled_maintenances('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return lists of unscheduled maintenance periods for all checks on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return a list of unscheduled maintenance periods for a check on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return lists of outages for all checks on an entity (all times for which said checks failed):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.outages('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return a list of outages for a check on an entity (all times for which the check failed):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.outages('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return a list of downtimes for all checks on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.downtime('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Return a list of downtimes for a check on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.downtime('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Acknowledge the current state for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.acknowledge!('example.com', 'ping', :summary => 'ack')
```

Create a scheduled maintenance period for a check on an entity:

```ruby
# start time (ISO 8601-formatted String, required)
# duration (Integer, required) is measured in seconds
# summary (String, optional)
Flapjack::Diner.create_scheduled_maintenance!('example.com', 'ping',
  :start_time => Time.now.to_i - (30 * 60), :duration => (60 * 60),
  :summary => 'changing stuff')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
