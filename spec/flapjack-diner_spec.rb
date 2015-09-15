require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }

  let(:time) { Time.now }

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
  end

  after(:each) do
    WebMock.reset!
  end

  # context 'argument parsing' do

  # end

  context 'keys as strings' do

    before do
      Flapjack::Diner.return_keys_as_strings = true
    end

    after do
      Flapjack::Diner.return_keys_as_strings = false
    end

    it 'can return keys as strings' do
      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :status => 200, :body => {:data => [contact_data]}.to_json)

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_an_instance_of(Array)
      expect(result.length).to be(1)
      expect(result.first).to be_an_instance_of(Hash)
      expect(result.first).to have_key('id')
    end

  end

  context 'logging' do

    let(:logger) { double('logger') }

    before do
      Flapjack::Diner.logger = logger
    end

    it "logs a GET request without a path" do
      response = {:data => [contact_data]}.to_json
      req = stub_request(:get, "http://#{server}/contacts").
        to_return(:body => response)

      expect(logger).to receive(:info).with(%r{\[Flapjack::Diner\] \[[^\]]+\] 200 "GET /contacts" - $})

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "logs a POST request" do
      req_data  = test_notification_json(test_notification_data).merge(
        :relationships => {
          :check => {
            :data => {:type => 'check', :id => check_data[:id]}
          }
        }
      )
      resp_data = test_notification_json(test_notification_data)

      response = {:data => resp_data}.to_json
      req = stub_request(:post, "http://#{server}/test_notifications").
              to_return(:status => 201, :body => response)

      expect(logger).to receive(:info).with(%r{\[Flapjack::Diner\] \[[^\]]+\] 201 "POST /test_notifications" - $})

      result = Flapjack::Diner.create_test_notifications(test_notification_data.merge(:check => check_data[:id]))
      expect(req).to have_been_requested
      expect(result).to eq(resultify(resp_data))
    end

    it "logs a DELETE request" do
      req = stub_request(:delete, "http://#{server}/scheduled_maintenances/#{scheduled_maintenance_data[:id]}").
        to_return(:status => 204)

      expect(logger).to receive(:info).
        with(%r{\[Flapjack::Diner\] \[[^\]]+\] 204 "DELETE /scheduled_maintenances/#{scheduled_maintenance_data[:id]}" - $})

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id])
      expect(req).to have_been_requested
      expect(result).to be_a(TrueClass)
    end

  end

  context "problems" do
    it "raises an exception on network failure" do
      req = stub_request(:get, "http://#{server}/contacts").to_timeout

      expect {
        Flapjack::Diner.contacts
      }.to raise_error(Timeout::Error)
      expect(req).to have_been_requested
    end

    it "raises an exception on invalid JSON data" do
      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :body => "{")

      expect {
        Flapjack::Diner.contacts
      }.to raise_error(JSON::ParserError)
      expect(req).to have_been_requested
    end

    it "raises an exception if a required argument is not provided" do
      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.create_scheduled_maintenances
      }.to raise_error(ArgumentError)
      expect(req).not_to have_been_requested
    end

    it "raises an exception if a time argument is provided with the wrong data type" do
      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.create_scheduled_maintenances(:start_time => Time.now,
          :end_time => 'tomorrow')
      }.to raise_error(ArgumentError)
      expect(req).not_to have_been_requested
    end
  end
end
