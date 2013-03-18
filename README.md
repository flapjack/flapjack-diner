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
Flapjack::Diner.logger = Logger.new("logs/flapjack_diner.log")
```

---

Return an array of monitored entities, and their statuses for all associated checks:

```ruby
Flapjack::Diner.entities
```

The data is returned as an array where each element is a hash representing an entity.

```
// ID     is an integer, to hold e.g. database id from an external system
// NAME   is a string
// STATUS is a hash with the format returned from Flapjack::Diner.status(entity, check)
[{"id"     => ID,
  "name"   => NAME,
  "checks" => [STATUS, STATUS, ...]},
 {},
 ...]
```

---

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

Return the status for a check on an entity

```ruby
Flapjack::Diner.status('example.com', :check => 'ping')
```

The data is returned as a hash:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// STATE is a string, one of 'critical', 'warning', 'ok', 'unknown'
// the TIMESTAMPs are integers representing UTC times for the named events
{"name" => CHECK,
 "state" => STATE,
 "in_unscheduled_maintenance" => BOOLEAN,
 "in_scheduled_maintenance" => BOOLEAN,
 "last_update" => TIMESTAMP,
 "last_problem_notification" => TIMESTAMP,
 "last_recovery_notification" => TIMESTAMP,
 "last_acknowledgement_notification" => TIMESTAMP}
 ```

---

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

Return an array of scheduled maintenance periods for a check on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.scheduled_maintenances('example.com', :check => 'ping', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of scheduled maintenance periods, with each element of the array being a hash containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{"start_time" => TIMESTAMP,
  "duration" => DURATION,
  "summary" => SUMMARY,
  "end_time" => TIMESTAMP},
  {...},
  ...]
```

---

Return lists of scheduled maintenance periods for all checks on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.scheduled_maintenances('example.com', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the scheduled maintenance periods for a check under the entity :

```
// CHECK is a string, e.g. 'ssh', 'ping'
// SCHED_MAINT is a hash with the same format as an individual element of the array returned from Flapjack::Diner.scheduled_maintenances(entity, check)
[{"check" => CHECK,
  "scheduled_maintenance" => [SCHED_MAINT, ...]
 },
 {"check" => CHECK,
  "scheduled_maintenance" => [SCHED_MAINT, ...]
 }]
```

---

Return an array of unscheduled maintenance periods for a check on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', :check => 'ping', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of unscheduled maintenance periods, with each element of the array being a hash containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{"start_time" => TIMESTAMP,
  "duration" => DURATION,
  "summary" => SUMMARY,
  "end_time" => TIMESTAMP},
  {...},
  ...]
```

---

Return lists of unscheduled maintenance periods for all checks on an entity:

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the unscheduled maintenance periods for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// UNSCHED_MAINT is a hash with the same format as an individual element of the array returned from Flapjack::Diner.unscheduled_maintenances(entity, check)
[{"check" => CHECK,
  "unscheduled_maintenance" => [UNSCHED_MAINT, ...]
 },
 {"check" => CHECK,
  "unscheduled_maintenance" => [UNSCHED_MAINT, ...]
 }]
```

---

Return an array of outages for a check on an entity (all times for which the check was failing):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.outages('example.com', :check => 'ping', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of outage periods, with each element of the array being a hash containing data about that outage period.

```
// STATE is a string, one of 'critical', 'warning', 'ok', 'unknown'
// the TIMESTAMPs are integers representing UTC times for the named events
// SUMMARY is a string providing a description of the period, may be empty
[{"state" => STATE,
  "start_time" => TIMESTAMP,
  "end_time" => TIMESTAMP,
  "summary" => SUMMARY},
  {...},
  ...]
```

---

Return lists of outages for all checks on an entity (all times for which said checks were failing):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.outages('example.com', :start_time => :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents the outages for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// OUTAGE is a hash with the same format as an individual element of the array returned from Flapjack::Diner.outages(entity, check)
[{"check" => CHECK,
  "outages" => [OUTAGE, ...]
 },
 {"check" => CHECK,
  "outages" => [OUTAGE, ...]
 }]
```

---

Return an array of downtimes for a check on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.downtime('example.com', :check => 'ping', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

Returns a hash with some statistics about the downtimes, including an array of the downtimes themselves. This may not be the same as would be returned from the 'outages' call for the same time period, as if scheduled maintenance periods overlap any of those times then they will be reduced, split or discarded to fit.

```
// TOTAL SECONDS gives the sum of the time spent in that state for each check state.
// PERCENTAGES represents the proportion of the total time that the check was in each state. Will be null if either start or end time were not provided in the request.
// OUTAGE is a hash with the same format as an individual element of the array returned from Flapjack::Diner.outages(entity, check).
{"total_seconds" => {STATE => INTEGER, ...},
 "percentages" => {STATE => INTEGER, ...},
 "downtime" => [OUTAGE, ...]
}
```

---

Return an array of downtimes for all checks on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (Time object, optional)
# end time (Time object, optional)
Flapjack::Diner.downtime('example.com', :start_time => Time.local(2012, 08, 01), :end_time => Time.local(2012, 09, 01))
```

The data is returned as an array of hashes, where each hash represents a downtime report for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// DOWNTIME is a hash with the same format those returned from Flapjack::Diner.downtime(entity, check)
[{"check" => CHECK,
  "downtime" => [DOWNTIME, ...]
 },
 {"check" => CHECK,
  "downtime" => [DOWNTIME, ...]
 }]
```

---

Acknowledge the current state for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.acknowledge!('example.com', 'ping', :summary => 'ack')
```

Returns a boolean value representing the success or otherwise of the creation of the acknowledgement by the server.

---

Generate test notifications for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.test_notifications!('example.com', 'HOST', :summary => 'Testing notifications to all contacts interested in the HOST check on example.com')
```

Returns a boolean value representing the success or otherwise of the creation of the acknowledgement by the server.

---
---

Create a scheduled maintenance period for a check on an entity:

```ruby
# start time (Time object, optional)
# duration (Integer, required) is measured in seconds
# summary (String, optional)
Flapjack::Diner.create_scheduled_maintenance!('example.com', 'ping',
  :start_time => Time.local(2012, 12, 01), :duration => (60 * 60),
  :summary => 'changing stuff')
```

Returns a boolean value representing the success or otherwise of the creation of the scheduled maintenance period by the server.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
