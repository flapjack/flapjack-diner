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
    Flapjack::Diner.return_keys_as_strings = true
  end

  after(:each) do
    WebMock.reset!
  end

  context 'create' do

    it "submits a POST request for a notification rule" do
      data = [{
        "entity_tags"        => ["database","physical"],
        "entities"           => ["foo-app-01.example.com"],
        "time_restrictions"  => nil,
        "warning_media"      => ["email"],
        "critical_media"     => ["sms", "email"],
        "warning_blackhole"  => false,
        "critical_blackhole" => false
      }]

      req = stub_request(:post, "http://#{server}/contacts/1/notification_rules").
        with(:body => {:notification_rules => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('notification_rules', data))


      result = Flapjack::Diner.create_contact_notification_rules(1, data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a POST request for several notification rules" do
      data = [{
        "entity_tags"        => ["database","physical"],
        "entities"           => ["foo-app-01.example.com"],
        "time_restrictions"  => nil,
        "warning_media"      => ["email"],
        "critical_media"     => ["sms", "email"],
        "warning_blackhole"  => false,
        "critical_blackhole" => false
      }, {
        "entity_tags"        => nil,
        "entities"           => ["foo-app-02.example.com"],
        "time_restrictions"  => nil,
        "warning_media"      => ["email"],
        "critical_media"     => ["sms", "email"],
        "warning_blackhole"  => true,
        "critical_blackhole" => false
      }]

      req = stub_request(:post, "http://#{server}/contacts/1/notification_rules").
        with(:body => {:notification_rules => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('notification_rules', data))

      result = Flapjack::Diner.create_contact_notification_rules(1, data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'read' do
   it "submits a GET request for all notification rules" do
      req = stub_request(:get, "http://#{server}/notification_rules").
        to_return(:body => response_with_data('notification_rules'))

      result = Flapjack::Diner.notification_rules
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for one notification rule" do
      req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
        to_return(:body => response_with_data('notification_rules'))

      result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several media" do
      req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
        to_return(:body => response_with_data('notification_rules'))

      result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for one notification rule" do
      req = stub_request(:patch, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
        with(:body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', :warning_blackhole => false)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several notification rules" do
      req = stub_request(:patch, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
        with(:body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543',
        'bfd8be61-3d80-4b95-94df-6e77183ce4e3', :warning_blackhole => false)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'delete' do
    it "submits a DELETE request for a notification rule" do
      req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several notification rules" do
      req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end
  end

end
