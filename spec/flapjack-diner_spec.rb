require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }
  let(:entity) { 'ex-abcd-data-17.example.com' }
  let(:check)  { 'ping'}

  let(:response_body) { mock('response') }
  let(:api_result)    { mock('api_result') }

  before(:each) do
    Flapjack::Diner.base_uri(server)
  end

  after(:each) do
    WebMock.reset!
  end

  it "returns a json list of entities" do
    req = stub_request(:get, "http://#{server}/entities").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.entities
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "returns a json list of checks for an entity" do
    req = stub_request(:get, "http://#{server}/checks/#{entity}").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.checks(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "returns a json list of check statuses for an entity" do
    req = stub_request(:get, "http://#{server}/status/#{entity}").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.status(entity)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "returns a single check status for an entity" do
    req = stub_request(:get, "http://#{server}/status/#{entity}/#{check}").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.check_status(entity, check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "returns a list of scheduled maintenance periods for a check on an entity" do
    req = stub_request(:get, "http://#{server}/scheduled_maintenances/#{entity}/#{check}").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.scheduled_maintenances(entity, check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "returns a list of unscheduled maintenance periods for a check on an entity" do
    req = stub_request(:get, "http://#{server}/unscheduled_maintenances/#{entity}/#{check}").to_return(
      :body => response_body)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.unscheduled_maintenances(entity, check)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "acknowledges a check's state for an entity" do
    req = stub_request(:post, "http://#{server}/acknowledgments/#{entity}/#{check}").with(
      :body => {:summary => 'dealing with it'}).to_return(
      :body => response_body, :status => 201)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.acknowledge!(entity, check, :summary => 'dealing with it')
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
  end

  it "creates a scheduled maintenance period for an entity" do
    start_time = Time.now.to_i
    duration = 60 * 30 # in seconds, so 30 minutes
    summary = "fixing everything"

    req = stub_request(:post, "http://#{server}/scheduled_maintenances/#{entity}/#{check}").with(
      :body => "start_time=#{start_time}&duration=#{duration}&summary=fixing%20everything").to_return(
      :body => response_body, :status => 201)
    JSON.should_receive(:parse).with(response_body).and_return(api_result)

    result = Flapjack::Diner.create_scheduled_maintenance!(entity, check,
      :start_time => start_time, :duration => duration, :summary => summary)
    req.should have_been_requested
    result.should_not be_nil
    result.should == api_result
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

end
