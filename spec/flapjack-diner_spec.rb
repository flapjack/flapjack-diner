require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }

  let(:time) { Time.now }

  def response_with_data(name, data = [])
    "{\"#{name}\":#{data.to_json}}"
  end

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
  end

  after(:each) do
    WebMock.reset!
  end

  context 'argument parsing' do

  end

  context 'keys as strings' do

    before do
      Flapjack::Diner.return_keys_as_strings = true
    end

    after do
      Flapjack::Diner.return_keys_as_strings = false
    end

    it 'can return keys as strings' do
      data = [{
        :id         => '21',
        :first_name => 'Ada',
        :last_name  => 'Lovelace',
        :email      => 'ada@example.com',
        :timezone   => 'Europe/London',
        :tags       => [ 'legend', 'first computer programmer' ],
        :links      => {
          :media              => ['21_email', '21_sms'],
          :notification_rules => ['30fd36ae-3922-4957-ae3e-c8f6dd27e543']
        }
      }]

      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :status => 200, :body => response_with_data('contacts', data))

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_an_instance_of(Array)
      expect(result.length).to be(1)
      expect(result[0]).to be_an_instance_of(Hash)
      expect(result[0]).to have_key('id')
      expect(result[0]).to have_key('links')
      expect(result[0]['links']).to have_key('media')
    end

  end

  context 'logging' do

    let(:logger) { double('logger') }

    before do
      Flapjack::Diner.logger = logger
    end

    it "logs a GET request without a path" do
      response = response_with_data('contacts')
      req = stub_request(:get, "http://#{server}/contacts").
        to_return(:body => response)

      expect(logger).to receive(:info).with("GET http://#{server}/contacts")
      expect(logger).to receive(:info).with("  Response Code: 200")
      expect(logger).to receive(:info).with("  Response Body: #{response}")

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "logs a POST request" do
      req = stub_request(:post, "http://#{server}/test_notifications/checks/27").
              to_return(:status => 204)
      expect(logger).to receive(:info).with("POST http://#{server}/test_notifications/checks/27\n" +
        "  Body: {:test_notifications=>[{:summary=>\"dealing with it\"}]}")
      expect(logger).to receive(:info).with("  Response Code: 204")

      result = Flapjack::Diner.create_test_notifications_checks(27, [{:summary => 'dealing with it'}])
      expect(req).to have_been_requested
      expect(result).to be_truthy
    end

    it "logs a DELETE request" do
      req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH").
        with(:query => {:start_time => time.iso8601}).
        to_return(:status => 204)

      expect(logger).to receive(:info).with("DELETE http://#{server}/scheduled_maintenances/checks/example.com:SSH?start_time=#{URI.encode_www_form_component(time.iso8601)}")
      expect(logger).to receive(:info).with("  Response Code: 204")

      result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => time)
      expect(req).to have_been_requested
      expect(result).to be_truthy
    end

  end

  context "problems" do

    it "raises an exception on network failure" do
      req = stub_request(:get, "http://#{server}/contacts").to_timeout

      expect {
        Flapjack::Diner.contacts
      }.to raise_error
      expect(req).to have_been_requested
    end

    it "raises an exception on invalid JSON data" do
      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :body => "{")

      expect {
        Flapjack::Diner.contacts
      }.to raise_error
      expect(req).to have_been_requested
    end

    it "raises an exception if a required argument is not provided" do
      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => nil)
      }.to raise_error
      expect(req).not_to have_been_requested
    end

    it "raises an exception if a time argument is provided with the wrong data type" do
      start_str  = '2011-08-01T00:00:00+10:00'
      finish_str = 'yesterday'

      start  = Time.iso8601(start_str)

      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.downtime_report_checks('example.com:SSH',
          :start_time => start_time, :end_time => end_time)
      }.to raise_error
      expect(req).not_to have_been_requested
    end

  end

end
