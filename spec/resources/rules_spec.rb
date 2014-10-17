require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Rules, :pact => true do

  let(:rule_id_regexp) {
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a rule" do
      data = [{
        :is_specific => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with one rule").
        with(:method => :post, :path => '/contacts/abc/rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:rules => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => [ Pact::Term.new(
            :generate => '05983623-fcef-42da-af44-ed6990b500fa',
            :matcher  => rule_id_regexp
          ) ]
        )

      result = Flapjack::Diner.create_contact_rules('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['05983623-fcef-42da-af44-ed6990b500fa'])
    end

    it "submits a POST request for several rules" do
      data = [{
        :is_specific => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }, {
        :is_specific => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => true,
        # :critical_blackhole => false
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with two rules").
        with(:method => :post, :path => '/contacts/abc/rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:rules => data}).
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

      result = Flapjack::Diner.create_contact_rules('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['05983623-fcef-42da-af44-ed6990b500fa',
                            '20f182fc-6e32-4794-9007-97366d162c51'])
    end

    it "can't find the contact to add a rule to" do
      data = [{
        :is_specific => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one rule").
        with(:method => :post, :path => '/contacts/abc/rules',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:rules => data}).
        will_respond_with(
          :status => 403,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["Contact with id 'abc' could not be loaded"]}
        )

      result = Flapjack::Diner.create_contact_rules('abc', data)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 403,
        :errors => ["Contact with id 'abc' could not be loaded"])
    end

  end

  context 'read' do
   it "submits a GET request for all rules" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :is_specific        => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a GET request for all rules").
        with(:method => :get, :path => '/rules').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:rules => [data]} )

      result = Flapjack::Diner.rules
      expect(result).not_to be_nil
      expect(result).to eq([data])
    end

    it "submits a GET request for one rule" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :is_specific        => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a GET request for a single rule").
        with(:method => :get, :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:rules => [data]} )

      result = Flapjack::Diner.rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).not_to be_nil
      expect(result).to eq([data])
    end

    it "submits a GET request for several rules" do
      data = {
        :id                 => '05983623-fcef-42da-af44-ed6990b500fa',
        :is_specific        => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => false,
        # :critical_blackhole => false
      }

      data_2 = {
        :id                 => '20f182fc-6e32-4794-9007-97366d162c51',
        :is_specific        => false,
        # :time_restrictions  => [],
        # :warning_media      => ["email"],
        # :critical_media     => ["sms", "email"],
        # :warning_blackhole  => true,
        # :critical_blackhole => true
      }

      flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' and rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
        upon_receiving("a GET request for two rules").
        with(:method => :get, :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:rules => [data, data_2]} )

      result = Flapjack::Diner.rules('05983623-fcef-42da-af44-ed6990b500fa',
        '20f182fc-6e32-4794-9007-97366d162c51')
      expect(result).not_to be_nil
      expect(result).to eq([data, data_2])
    end

    it "can't find the rule to read" do
      flapjack.given("no rule exists").
        upon_receiving("a GET request for a single rule").
        with(:method => :get, :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa').
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
        )

      result = Flapjack::Diner.rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])
    end

  end

  context 'update' do

    # it "submits a PATCH request for one rule" do
    #   flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
    #     upon_receiving("a PATCH request to change properties for a single rule").
    #     with(:method => :patch,
    #          :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa',
    #          :body => [{:op => 'replace', :path => '/rules/0/warning_blackhole', :value => false}],
    #          :headers => {'Content-Type'=>'application/json-patch+json'}).
    #     will_respond_with(
    #       :status => 204,
    #       :body => '')

    #   result = Flapjack::Diner.update_rules('05983623-fcef-42da-af44-ed6990b500fa',
    #     :warning_blackhole => false)
    #   expect(result).not_to be_nil
    #   expect(result).to be_truthy
    # end

    # it "submits a PATCH request for several rules" do
    #   flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' and rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
    #     upon_receiving("a PATCH request to change properties for two rules").
    #     with(:method => :patch,
    #          :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51',
    #          :body => [{:op => 'replace', :path => '/rules/0/warning_blackhole', :value => false}],
    #          :headers => {'Content-Type'=>'application/json-patch+json'}).
    #     will_respond_with(
    #       :status => 204,
    #       :body => '')

    #   result = Flapjack::Diner.update_rules('05983623-fcef-42da-af44-ed6990b500fa',
    #     '20f182fc-6e32-4794-9007-97366d162c51', :warning_blackhole => false)
    #   expect(result).not_to be_nil
    #   expect(result).to be_truthy
    # end

    # it "can't find the rule to update" do
    #   flapjack.given("no rule exists").
    #     upon_receiving("a PATCH request to change properties for a single rule").
    #     with(:method => :patch,
    #          :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa',
    #          :body => [{:op => 'replace', :path => '/rules/0/warning_blackhole', :value => false}],
    #          :headers => {'Content-Type'=>'application/json-patch+json'}).
    #     will_respond_with(
    #       :status => 404,
    #       :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
    #       :body => {:errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
    #     )

    #   result = Flapjack::Diner.update_rules('05983623-fcef-42da-af44-ed6990b500fa',
    #     :warning_blackhole => false)
    #   expect(result).to be_nil
    #   expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
    #     :errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])
    # end

  end

  context 'delete' do
    it "submits a DELETE request for a rule" do
      flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' exists").
        upon_receiving("a DELETE request for a single rule").
        with(:method => :delete,
             :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several rules" do
      flapjack.given("a contact 'abc' with generic rule '05983623-fcef-42da-af44-ed6990b500fa' and rule '20f182fc-6e32-4794-9007-97366d162c51' exists").
        upon_receiving("a DELETE request for two rules").
        with(:method => :delete,
             :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa,20f182fc-6e32-4794-9007-97366d162c51',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rules('05983623-fcef-42da-af44-ed6990b500fa',
        '20f182fc-6e32-4794-9007-97366d162c51')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the rule to delete" do
      flapjack.given("no rule exists").
        upon_receiving("a DELETE request for a single rule").
        with(:method => :delete,
             :path => '/rules/05983623-fcef-42da-af44-ed6990b500fa',
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"]}
        )

      result = Flapjack::Diner.delete_rules('05983623-fcef-42da-af44-ed6990b500fa')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Rule records, ids: '05983623-fcef-42da-af44-ed6990b500fa'"])

    end
  end

end
