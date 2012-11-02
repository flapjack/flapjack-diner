require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }
  let(:entity) { 'ex-abcd-data-17.example.com' }
  let(:check)  { 'ping'}

  let(:response)      { '{"key":"value"}' }
  let(:response_body) { {'key' => 'value'} }

  before(:each) do
    Flapjack::Diner.base_uri(server)
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

  it "creates a scheduled maintenance period for an entity" do
    start_time = Time.now
    duration = 60 * 30 # in seconds, so 30 minutes
    summary = "fixing everything"

    req = stub_request(:post, "http://#{server}/scheduled_maintenances/#{entity}/#{check}").with(
      :body => "start_time=#{start_time.iso8601}&duration=#{duration}&summary=fixing%20everything").to_return(
      :status => 204)

    result = Flapjack::Diner.create_scheduled_maintenance!(entity, check,
      :start_time => start_time, :duration => duration, :summary => summary)
    req.should have_been_requested
    result.should be_true
  end

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
