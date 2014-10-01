require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::NotificationRules, :pact => true do

  let(:rule_id_regexp) {
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a notification rule" do
      data = [{
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with one notification rule").
        with(:method => :post, :path => '/contacts/abc/notification_rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:notification_rules => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => [ Pact::Term.new(
            :generate => '05983623-fcef-42da-af44-ed6990b500fa',
            :matcher  => rule_id_regexp
          ) ]
        )

      result = Flapjack::Diner.create_contact_notification_rules('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['05983623-fcef-42da-af44-ed6990b500fa'])
    end

    it "submits a POST request for several notification rules" do
      data = [{
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }, {
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => true,
        # :critical_blackhole => false
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with two notification rules").
        with(:method => :post, :path => '/contacts/abc/notification_rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:notification_rules => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => [ Pact::Term.new(
            :generate => '05983623-fcef-42da-af44-ed6990b500fa',
            :matcher  => rule_id_regexp
          ), Pact::Term.new(
            :generate => '20f182fc-6e32-4794-9007-97366d162c51',
            :matcher  => rule_id_regexp
          ) ]
        )

      result = Flapjack::Diner.create_contact_notification_rules('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['05983623-fcef-42da-af44-ed6990b500fa',
                            '20f182fc-6e32-4794-9007-97366d162c51'])
    end

    it "can't find the contact to add a notification rule to" do
      data = [{
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one notification rule").
        with(:method => :post, :path => '/contacts/abc/notification_rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:notification_rules => data}).
        will_respond_with(
          :status => 403,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["Contact with id 'abc' could not be loaded"]}
        )

      result = Flapjack::Diner.create_contact_notification_rules('abc', data)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 403,
        :errors => ["Contact with id 'abc' could not be loaded"])
    end

  end

  context 'read' do
   it "submits a GET request for all notification rules" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a GET request for all notification rules").
        with(:method => :get, :path => '/notification_rules').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:notification_rules => [data]} )

      result = Flapjack::Diner.notification_rules
      expect(result).not_to be_nil
      expect(result).to eq([data])
    end

    it "submits a GET request for one notification rule" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a GET request for a single notification rule").
        with(:method => :get, :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:notification_rules => [data]} )

      result = Flapjack::Diner.notification_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).not_to be_nil
      expect(result).to eq([data])
    end

    it "submits a GET request for several notification rules" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      data_2 = {
        :id                 => '20f182fc-6e32-4794-9007-97366d162c51',
        :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => true,
        # :critical_blackhole => true
      }

      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' and notification rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
        upon_receiving("a GET request for two notification rules").
        with(:method => :get, :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:notification_rules => [data, data_2]} )

      result = Flapjack::Diner.notification_rules('05983623-fcef-42da-af44-ed6990b500fa',
        '20f182fc-6e32-4794-9007-97366d162c51')
      expect(result).not_to be_nil
      expect(result).to eq([data, data_2])
    end

    it "can't find the notification rule to read" do
      flapjack.given("no notification rule exists").
        upon_receiving("a GET request for a single notification rule").
        with(:method => :get, :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa').
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
        )

      result = Flapjack::Diner.notification_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])
    end

  end

  context 'update' do

    it "submits a PATCH request for one notification rule" do
      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a PATCH request to change properties for a single notification rule").
        with(:method => :patch,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.update_notification_rules('05983623-fcef-42da-af44-ed6990b500fa',
        :warning_blackhole => false)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several notification rules" do
      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' and notification rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
        upon_receiving("a PATCH request to change properties for two notification rules").
        with(:method => :patch,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51',
             :body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.update_notification_rules('05983623-fcef-42da-af44-ed6990b500fa',
        '20f182fc-6e32-4794-9007-97366d162c51', :warning_blackhole => false)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the notification rule to update" do
      flapjack.given("no notification rule exists").
        upon_receiving("a PATCH request to change properties for a single notification rule").
        with(:method => :patch,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
        )

      result = Flapjack::Diner.update_notification_rules('05983623-fcef-42da-af44-ed6990b500fa',
        :warning_blackhole => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for a notification rule" do
      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a DELETE request for a single notification rule").
        with(:method => :delete,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_notification_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several notification rules" do
      flapjack.given("a contact 'abc' with generic notification rule '05983623-fcef-42da-af44-ed6990b500fa' and notification rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
        upon_receiving("a DELETE request for two notification rules").
        with(:method => :delete,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_notification_rules('05983623-fcef-42da-af44-ed6990b500fa',
        '20f182fc-6e32-4794-9007-97366d162c51')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the notification rule to delete" do
      flapjack.given("no notification rule exists").
        upon_receiving("a DELETE request for a single notification rule").
        with(:method => :delete,
             :path => '/notification_rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
        )

      result = Flapjack::Diner.delete_notification_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find NotificationRule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])

    end
  end

end
