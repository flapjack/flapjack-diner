require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }
  let(:entity) { 'ex-abcd-data-17.example.com' }
  let(:check)  { 'ping'}

  let(:rule_data) {
    {"contact_id"         => "21",
     "entity_tags"        => ["database","physical"],
     "entities"           => ["foo-app-01.example.com"],
     "time_restrictions"  => nil,
     "warning_media"      => ["email"],
     "critical_media"     => ["sms", "email"],
     "warning_blackhole"  => false,
     "critical_blackhole" => false
    }
  }

  let(:response)      { '{"key":"value"}' }
  let(:response_body) { {'key' => 'value'} }

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
  end

  after(:each) do
    WebMock.reset!
  end

  it "returns a json list of entities" do
    req = stub_request(:get, "http://#{server}/entities").to_return(
      :body => response)

    result = Flapjack::Diner.entities
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a json list of entities from a non-standard port" do
    Flapjack::Diner.base_uri('flapjack.com:54321')

    req = stub_request(:get, "http://#{server}:54321/entities").to_return(
      :body => response)

    result = Flapjack::Diner.entities
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a json list of checks for an entity" do
    req = stub_request(:get, "http://#{server}/checks/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.checks(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a json list of check statuses for an entity" do
    req = stub_request(:get, "http://#{server}/status/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.status(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a single check status for an entity" do
    req = stub_request(:get, "http://#{server}/status/#{entity}/#{check}").to_return(
      :body => response)

    result = Flapjack::Diner.status(entity, :check => check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of scheduled maintenance periods for all checks on an entity" do
    req = stub_request(:get, "http://#{server}/scheduled_maintenances/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.scheduled_maintenances(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of scheduled maintenance periods for a check on an entity" do
    req = stub_request(:get, "http://#{server}/scheduled_maintenances/#{entity}/#{check}").to_return(
      :body => response)

    result = Flapjack::Diner.scheduled_maintenances(entity, :check => check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of unscheduled maintenance periods for all checks on an entity" do
    req = stub_request(:get, "http://#{server}/unscheduled_maintenances/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.unscheduled_maintenances(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of unscheduled maintenance periods for a check on an entity" do
    req = stub_request(:get, "http://#{server}/unscheduled_maintenances/#{entity}/#{check}").to_return(
      :body => response)

    result = Flapjack::Diner.unscheduled_maintenances(entity, :check => check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of outages for all checks on an entity" do
    req = stub_request(:get, "http://#{server}/outages/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.outages(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of outages for a check on an entity" do
    req = stub_request(:get, "http://#{server}/outages/#{entity}/#{check}").to_return(
      :body => response)

    result = Flapjack::Diner.outages(entity, :check => check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of downtimes for all checks on an entity" do
    req = stub_request(:get, "http://#{server}/downtime/#{entity}").to_return(
      :body => response)

    result = Flapjack::Diner.downtime(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of downtimes for all checks on an entity between two times" do
    start_str  = '2011-08-01T00:00:00+10:00'
    finish_str = '2011-08-31T00:00:00+10:00'

    start  = Time.iso8601(start_str)
    finish = Time.iso8601(finish_str)

    start_enc = URI.encode(start.iso8601)
    finish_enc = URI.encode(finish.iso8601)

    req = stub_request(:get, "http://#{server}/downtime/#{entity}?end_time=#{finish_enc}&start_time=#{start_enc}").to_return(
      :body => response)

    result = Flapjack::Diner.downtime(entity, :start_time => start, :end_time => finish)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a list of downtimes for a check on an entity" do
    req = stub_request(:get, "http://#{server}/downtime/#{entity}/#{check}").to_return(
      :body => response)

    result = Flapjack::Diner.downtime(entity, :check => check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "acknowledges a check's state for an entity" do
    req = stub_request(:post, "http://#{server}/acknowledgements/#{entity}/#{check}").with(
      :body => {:summary => 'dealing with it'}).to_return(
      :status => 204)

    result = Flapjack::Diner.acknowledge!(entity, check, :summary => 'dealing with it')
    req.should have_been_requested
    result.should be_true
  end

  it "generates test notifications for a check on an entity" do
    req = stub_request(:post, "http://#{server}/test_notifications/#{entity}/#{check}").with(
      :body => {:summary => 'testing notifications'}).to_return(
      :status => 204)

    result = Flapjack::Diner.test_notifications!(entity, check, :summary => 'testing notifications')
    req.should have_been_requested
    result.should be_true
  end

  it "creates a scheduled maintenance period for an entity" do
    start_time = Time.now
    duration = 60 * 30 # in seconds, so 30 minutes
    summary = "fixing everything"

    req = stub_request(:post, "http://#{server}/scheduled_maintenances/#{entity}/#{check}").with(
      :body => "start_time=#{CGI.escape(start_time.iso8601)}&duration=#{duration}&summary=fixing+everything").to_return(
      :status => 204)

    result = Flapjack::Diner.create_scheduled_maintenance!(entity, check,
      :start_time => start_time, :duration => duration, :summary => summary)
    req.should have_been_requested
    result.should be_true
  end

  it "returns a list of contacts" do
    req = stub_request(:get, "http://#{server}/contacts").to_return(
      :body => response)

    result = Flapjack::Diner.contacts
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a single contact" do
    contact_id = '21'
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}").to_return(
      :body => response)

    result = Flapjack::Diner.contact(contact_id)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns notification rules for a contact" do
    contact_id = '21'
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/notification_rules").to_return(
      :body => response)

    result = Flapjack::Diner.notification_rules(contact_id)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns a single notification rule" do
    rule_id = '00001'
    req = stub_request(:get, "http://#{server}/notification_rules/#{rule_id}").to_return(
      :body => response)

    result = Flapjack::Diner.notification_rule(rule_id)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "creates a notification rule" do
    rule_result = rule_data.merge('id' => '00001')

    req = stub_request(:post, "http://#{server}/notification_rules").with(
      :body => rule_data.to_json).to_return(:body => rule_result.to_json)

    result = Flapjack::Diner.create_notification_rule!(rule_data)
    req.should have_been_requested
    result.should == rule_result
  end

  it "updates a notification rule" do
    rule_id = '00001'

    rule_data_with_id = rule_data.merge('id' => rule_id)

    req = stub_request(:put, "http://#{server}/notification_rules/#{rule_id}").with(
      :body => rule_data_with_id.to_json).to_return(:body => rule_data_with_id.to_json)

    result = Flapjack::Diner.update_notification_rule!(rule_id, rule_data_with_id)
    req.should have_been_requested
    result.should == rule_data_with_id
  end

  it "deletes a notification rule" do
    rule_id = '00001'
    req = stub_request(:delete, "http://#{server}/notification_rules/#{rule_id}").to_return(
      :status => 204)

    result = Flapjack::Diner.delete_notification_rule!(rule_id)
    req.should have_been_requested
    result.should be_true
  end

  it "gets a list of entity tags" do
    req = stub_request(:get, "http://#{server}/entities/#{entity}/tags").to_return(
      :body => ['web', 'app'].to_json)

    result = Flapjack::Diner.entity_tags(entity)
    req.should have_been_requested
    result.should == ['web', 'app']
  end

  it "adds tags to an entity" do
    req = stub_request(:post, "http://#{server}/entities/#{entity}/tags").
            with(:body => {:tag => ['web', 'app']}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:body => ['web', 'app'].to_json)

    result = Flapjack::Diner.add_entity_tags!(entity, 'web', 'app')
    req.should have_been_requested
    result.should == ['web', 'app']
  end

  it "deletes tags from an entity" do
    req = stub_request(:delete, "http://#{server}/entities/#{entity}/tags").
            with(:body => {:tag => ['web']}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:status => 204)

    result = Flapjack::Diner.delete_entity_tags!(entity, 'web')
    req.should have_been_requested
    result.should be_true
  end

  it "gets a list of contact tags" do
    contact_id = 21
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/tags").to_return(
      :body => ['user', 'admin'].to_json)

    result = Flapjack::Diner.contact_tags(contact_id)
    req.should have_been_requested
    result.should == ['user', 'admin']
  end

  it "gets tags for a contact's linked entities" do
    contact_id = 21
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/entity_tags").to_return(
      :body => {'entity_1' => ['web', 'app']}.to_json)

    result = Flapjack::Diner.contact_entitytags(contact_id)
    req.should have_been_requested
    result.should == {'entity_1' => ['web', 'app']}
  end

  it "adds tags to a contact's linked entities" do
    contact_id = 21
    req = stub_request(:post, "http://#{server}/contacts/#{contact_id}/entity_tags").
            with(:body => {:entity => {'entity_1' => ['web', 'app']}}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:body => {'entity_1' => ['web', 'app']}.to_json)

    result = Flapjack::Diner.add_contact_entitytags!(contact_id, {'entity_1' => ['web', 'app']})
    req.should have_been_requested
    result.should == {'entity_1' => ['web', 'app']}
  end

  it "deletes tags from a contact's linked entities" do
    contact_id = 21
    req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/entity_tags").
            with(:body => {:entity => {'entity_1' => ['web', 'app']}}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:status => 204)

    result = Flapjack::Diner.delete_contact_entitytags!(contact_id, {'entity_1' => ['web', 'app']})
    req.should have_been_requested
    result.should be_true
  end

  it "adds tags to a contact" do
    contact_id = 21
    req = stub_request(:post, "http://#{server}/contacts/#{contact_id}/tags").
            with(:body => {:tag => ['admin', 'user']}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:body => ['admin', 'user'].to_json)

    result = Flapjack::Diner.add_contact_tags!(contact_id, 'admin', 'user')
    req.should have_been_requested
    result.should == ['admin', 'user']
  end

  it "deletes tags from a contact" do
    contact_id = 21
    req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/tags").
            with(:body => {:tag => ['admin']}.to_json,
                 :headers => {'Content-Type'=>'application/json'}).
            to_return(:status => 204)

    result = Flapjack::Diner.delete_contact_tags!(contact_id, 'admin')
    req.should have_been_requested
    result.should be_true
  end


  it "returns a list of a contact's notification media values" do
    contact_id = '21'
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/media").to_return(
      :body => response)

    result = Flapjack::Diner.contact_media(contact_id)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "returns the values for a contact's notification medium" do
    contact_id = '21'
    media = 'sms'
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/media/#{media}").to_return(
      :body => response)

    result = Flapjack::Diner.contact_medium(contact_id, media)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "updates a contact's notification medium" do
    contact_id = '21'
    media_type = 'sms'
    media_data = {"address" => "dmitri@example.com",
                  "interval" => 900}

    req = stub_request(:put, "http://#{server}/contacts/#{contact_id}/media/#{media_type}").with(
      :body => media_data.to_json).to_return(:body => media_data.to_json)

    result = Flapjack::Diner.update_contact_medium!(contact_id, media_type, media_data)
    req.should have_been_requested
    result.should == media_data
  end

  it "deletes a contact's notification medium" do
    contact_id = '21'
    media = 'sms'
    req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/media/#{media}").to_return(
      :status => 204)

    result = Flapjack::Diner.delete_contact_medium!(contact_id, media)
    req.should have_been_requested
    result.should be_true
  end

  it "returns a contact's timezone" do
    contact_id = '21'
    req = stub_request(:get, "http://#{server}/contacts/#{contact_id}/timezone").to_return(
      :body => response)

    result = Flapjack::Diner.contact_timezone(contact_id)
    req.should have_been_requested
    result.should_not be_nil
    result.should == response_body
  end

  it "updates a contact's timezone" do
    contact_id = '21'
    timezone_data = {'timezone' => "Australia/Perth"}

    req = stub_request(:put, "http://#{server}/contacts/#{contact_id}/timezone").with(
      :body => timezone_data.to_json).to_return(:body => timezone_data.to_json)

    result = Flapjack::Diner.update_contact_timezone!(contact_id, timezone_data['timezone'])
    req.should have_been_requested
    result.should == timezone_data
  end

  it "deletes a contact's timezone" do
    contact_id = '21'
    req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/timezone").to_return(
      :status => 204)

    result = Flapjack::Diner.delete_contact_timezone!(contact_id)
    req.should have_been_requested
    result.should be_true
  end

  context "logging" do

    let(:logger) { mock('logger') }

    before do
      Flapjack::Diner.logger = logger
    end

    it "logs a GET request without a path" do
      req = stub_request(:get, "http://#{server}/entities").to_return(
        :body => response)

      logger.should_receive(:info).with("GET http://#{server}/entities")
      logger.should_receive(:info).with("  Response Code: 200")
      logger.should_receive(:info).with("  Response Body: #{response}")

      result = Flapjack::Diner.entities
      req.should have_been_requested
      result.should_not be_nil
      result.should == response_body
    end

    it "logs a GET request with a path" do
      req = stub_request(:get, "http://#{server}/checks/#{entity}").to_return(
        :body => response)

      logger.should_receive(:info).with("GET http://#{server}/checks/#{entity}")
      logger.should_receive(:info).with("  Response Code: 200")
      logger.should_receive(:info).with("  Response Body: #{response}")

      result = Flapjack::Diner.checks(entity)
      req.should have_been_requested
      result.should_not be_nil
      result.should == response_body
    end

    it "logs a POST request" do
      req = stub_request(:post, "http://#{server}/acknowledgements/#{entity}/#{check}").with(
        :body => {:summary => 'dealing with it'}).to_return(
        :status => 204)
      logger.should_receive(:info).with("POST http://#{server}/acknowledgements/#{entity}/#{check}\n" +
        "  Params: \"summary=dealing+with+it\"")
      logger.should_receive(:info).with("  Response code: 204")

      result = Flapjack::Diner.acknowledge!(entity, check, :summary => 'dealing with it')
      req.should have_been_requested
      result.should be_true
    end

    it "logs a JSON put request" do
      contact_id = '21'
      timezone_data = {'timezone' => "Australia/Perth"}

      req = stub_request(:put, "http://#{server}/contacts/#{contact_id}/timezone").with(
        :body => timezone_data.to_json).to_return(:body => timezone_data.to_json, :status => [200, ' OK'])

      logger.should_receive(:info).
        with("PUT /http://#{server}/contacts/#{contact_id}/timezone\n  #{timezone_data.to_json}")
      logger.should_receive(:info).with("  Response Code: 200 OK")
      logger.should_receive(:info).with("  Response Body: #{timezone_data.to_json}")

      result = Flapjack::Diner.update_contact_timezone!(contact_id, timezone_data['timezone'])
      req.should have_been_requested
      result.should == timezone_data
    end

    it "logs a DELETE request" do
      contact_id = '21'
      req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/timezone").to_return(
        :status => 204)

      logger.should_receive(:info).with("DELETE /http://#{server}/contacts/#{contact_id}/timezone")
      logger.should_receive(:info).with("  Response Code: 204")

      result = Flapjack::Diner.delete_contact_timezone!(contact_id)
      req.should have_been_requested
      result.should be_true
    end

  end

  context "problems" do

    it "raises an exception on network failure" do
      req = stub_request(:get, "http://#{server}/entities").to_timeout

      expect {
        Flapjack::Diner.entities
      }.to raise_error
      req.should have_been_requested
    end

    it "raises an exception on invalid JSON data" do
      req = stub_request(:get, "http://#{server}/entities").to_return(
        :body => "{")

      expect {
        Flapjack::Diner.entities
      }.to raise_error
      req.should have_been_requested
    end

    it "raises an exception if a required argument is not provided" do
      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.check_status(entity, nil)
      }.to raise_error
      req.should_not have_been_requested
    end

    it "raises an exception if a time argument is provided with the wrong data type" do
      start_str  = '2011-08-01T00:00:00+10:00'
      finish_str = '2011-08-31T00:00:00+10:00'

      start  = Time.iso8601(start_str)

      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.downtime(entity, :start_time => start, :end_time => finish_str)
      }.to raise_error
      req.should_not have_been_requested
    end

  end

end
