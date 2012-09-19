# Flapjack::Diner

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

---

Return a list of monitored entities, and their statuses for all associated checks:

```ruby
Flapjack::Diner.entities
```

The data is returned as a JSON list where each element is an associative array representing an entity.

```
// ID     is an integer, to hold e.g. database id from an external system
// NAME   is a string
// STATUS is an associative array with the format returned from Flapjack::Diner.status(entity, check)
[{"id"     : ID,
  "name"   : NAME,
  "checks" : [STATUS, STATUS, ...]},
 {},
 ...]
```

---

Return a list of checks for an entity:

```ruby
Flapjack::Diner.checks('example.com')
```

The data is returned as a JSON list of strings, where each element is a check name for the provided entity.

```
// CHECK is a string, e.g. 'ssh', 'ping'
[CHECK, CHECK, ...]
```

---

Return the status for a check on an entity

```ruby
Flapjack::Diner.status('example.com', 'ping')
```

The data is returned as a JSON associative array:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// STATE is a string, one of 'critical', 'warning', 'ok', 'unknown'
// the TIMESTAMPs are integers representing UTC times for the named events
{"name" : CHECK,
 "state" : STATE,
 "in_unscheduled_maintenance" : BOOLEAN,
 "in_scheduled_maintenance" : BOOLEAN,
 "last_update" : TIMESTAMP,
 "last_problem_notification" : TIMESTAMP,
 "last_recovery_notification" : TIMESTAMP,
 "last_acknowledgement_notification" : TIMESTAMP}
 ```

---

Return the statuses for all checks on an entity

```ruby
Flapjack::Diner.status('example.com')
```

The data is returned as a JSON list of checks, where each element is an associative array with the format returned from Flapjack::Diner.status(entity, check)

```
// STATUS is an associative array with the format returned from Flapjack::Diner.status(entity, check)
[STATUS, STATUS, ...]
```

---

Return a list of scheduled maintenance periods for a check on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.scheduled_maintenances('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a JSON list of scheduled maintenance periods, with each element of the list being an associative array containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{"start_time" : TIMESTAMP,
  "duration" : DURATION,
  "summary" : SUMMARY,
  "end_time" : TIMESTAMP},
  {...},
  ...]
```

---

Return lists of scheduled maintenance periods for all checks on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.scheduled_maintenances('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a list of associative arrays, where each associative array represents the scheduled maintenance periods for a check under the entity :

```
// CHECK is a string, e.g. 'ssh', 'ping'
// SCHED_MAINT is an associative array with the same format as an individual element of the list returned from Flapjack::Diner.scheduled_maintenances(entity, check)
[{"check" : CHECK,
  "scheduled_maintenance" : [SCHED_MAINT, ...]
 },
 {"check" : CHECK,
  "scheduled_maintenance" : [SCHED_MAINT, ...]
 }]
```

---

Return a list of unscheduled maintenance periods for a check on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a JSON list of unscheduled maintenance periods, with each element of the list being an associative array containing data about that maintenance period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// DURATION is an integer representing the length of the period in seconds
// SUMMARY is a string providing a description of the period, may be empty
[{"start_time" : TIMESTAMP,
  "duration" : DURATION,
  "summary" : SUMMARY,
  "end_time" : TIMESTAMP},
  {...},
  ...]
```

---

Return lists of unscheduled maintenance periods for all checks on an entity:

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.unscheduled_maintenances('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a list of associative arrays, where each associative array represents the unscheduled maintenance periods for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// UNSCHED_MAINT is an associative array with the same format as an individual element of the list returned from Flapjack::Diner.unscheduled_maintenances(entity, check)
[{"check" : CHECK,
  "unscheduled_maintenance" : [UNSCHED_MAINT, ...]
 },
 {"check" : CHECK,
  "unscheduled_maintenance" : [UNSCHED_MAINT, ...]
 }]
```

---

Return a list of outages for a check on an entity (all times for which the check was failing):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.outages('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a JSON list of outage periods, with each element of the list being an associative array containing data about that outage period.

```
// the TIMESTAMPs are integers representing UTC times for the named events
// SUMMARY is a string providing a description of the period, may be empty
[{"start_time" : TIMESTAMP,
  "summary" : SUMMARY,
  "end_time" : TIMESTAMP},
  {...},
  ...]
```

---

Return lists of outages for all checks on an entity (all times for which said checks were failing):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.outages('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a list of associative arrays, where each associative array represents the outages for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// OUTAGE is an associative array with the same format as an individual element of the list returned from Flapjack::Diner.outages(entity, check)
[{"check" : CHECK,
  "outages" : [OUTAGE, ...]
 },
 {"check" : CHECK,
  "outages" : [OUTAGE, ...]
 }]
```

---

Return a list of downtimes for a check on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.downtime('example.com', 'ping', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

Returns an associative array with some statistics about the downtimes, including a list of the downtimes themselves.

```
// TOTAL SECONDS
// PERCENTAGE integer, representing the . Will be null if either start or end time were not provided in the request.
// OUTAGE is an associative array with the same format as an individual element of the list returned from Flapjack::Diner.outages(entity, check)
{"total_seconds" : TOTAL_SECONDS,
 "percentage" : PERCENTAGE,
 "downtime" : [OUTAGE, ...]
}
```

---

Return a list of downtimes for all checks on an entity (outages outside of scheduled maintenance periods):

```ruby
# start time (ISO 8601-formatted String, optional)
# end time (ISO 8601-formatted String, optional)
Flapjack::Diner.downtime('example.com', :start_time => "2012-09-01T00:00:00+09:30", :end_time => "2012-10-01T00:00:00+09:30")
```

The data is returned as a list of associative arrays, where each associative array represents a downtime associative array for a check under the entity:

```
// CHECK is a string, e.g. 'ssh', 'ping'
// DOWNTIME is an associative array with the same format those returned from Flapjack::Diner.downtime(entity, check)
[{"check" : CHECK,
  "downtime" : [DOWNTIME, ...]
 },
 {"check" : CHECK,
  "downtime" : [DOWNTIME, ...]
 }]
```

---

Acknowledge the current state for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.acknowledge!('example.com', 'ping', :summary => 'ack')
```

---

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
