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

Return a list of monitored entities, and their statuses:

```ruby
Flapjack::Diner.entities
```

Return a list of checks for an entity:

```ruby
Flapjack::Diner.checks('example.com')
```

Return a list of check statuses for an entity

```ruby
Flapjack::Diner.status('example.com')
```

Return a single check status for an entity

```ruby
Flapjack::Diner.check_status('example.com', 'ping')
```

Return a list of scheduled maintenance periods for a check on an entity:

```ruby
Flapjack::Diner.scheduled_maintenances('example.com', 'ping')
```

Return a list of unscheduled maintenance periods for a check on an entity:

```ruby
Flapjack::Diner.unscheduled_maintenances('example.com', 'ping')
```

Acknowledge the current state for a check on an entity:

```ruby
# summary (String, optional)
Flapjack::Diner.acknowledge!('example.com', 'ping', :summary => 'ack')
```

Create a scheduled maintenance period for a check on an entity:

```ruby
# start time (Integer, required) is a UTC timestamp
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
