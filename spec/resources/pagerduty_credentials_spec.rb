require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::PagerdutyCredentials, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for pagerduty credentials" do
      data = [{:service_key => 'abc',
               :subdomain   => 'def',
               :token       => 'ghi',
              }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with one set of pagerduty credentials").
        with(:method => :post, :path => '/contacts/abc/pagerduty_credentials',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:pagerduty_credentials => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['abc'] )

      result = Flapjack::Diner.create_contact_pagerduty_credentials('abc', data)
      expect(result).to eq(['abc'])
    end

    it "can't find the contact to create pagerduty credentials for" do
      data = [{:service_key => 'abc',
               :subdomain   => 'def',
               :token       => 'ghi',
              }]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one set of pagerduty credentials").
        with(:method => :post, :path => '/contacts/abc/pagerduty_credentials',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:pagerduty_credentials => data}).
        will_respond_with(
          :status => 422,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["Contact id: 'abc' could not be loaded"]} )

      result = Flapjack::Diner.create_contact_pagerduty_credentials('abc', data)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 422,
        :errors => ["Contact id: 'abc' could not be loaded"])
    end

  end

  context 'read' do
   it "submits a GET request for all pagerduty credentials" do
      pdc_data = [{
        :service_key => 'abc',
        :subdomain   => 'def',
        :token       => 'ghi',
      }]

      flapjack.given("a contact with id 'abc' has pagerduty credentials").
        upon_receiving("a GET request for all pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdc_data} )

      result = Flapjack::Diner.pagerduty_credentials
      expect(result).to eq(pdc_data)
    end

    it "submits a GET request for one set of pagerduty credentials" do
      pdc_data = [{
        :service_key => 'abc',
        :subdomain   => 'def',
        :token       => 'ghi',
      }]

      flapjack.given("a contact with id 'abc' has pagerduty credentials").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/abc').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdc_data} )

      result = Flapjack::Diner.pagerduty_credentials('abc')
      expect(result).to eq(pdc_data)
    end

    it "submits a GET request for several sets of pagerduty credentials" do
      pdc_data = [{
        :service_key => 'abc',
        :subdomain   => 'def',
        :token       => 'ghi',
      }, {
        :service_key => 'mno',
        :subdomain   => 'pqr',
        :token       => 'stu',
      }]

      flapjack.given("contacts with ids 'abc' and '872' have pagerduty credentials").
        upon_receiving("a GET request for two sets of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/abc,872').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdc_data} )

      result = Flapjack::Diner.pagerduty_credentials('abc', '872')
      expect(result).to eq(pdc_data)
    end

    it "can't find the contact with pagerduty credentials to read" do
      flapjack.given("no contact exists").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/abc').
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.pagerduty_credentials('abc')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

  context 'update' do

    it "submits a PATCH request for one set of pagerduty credentials" do
      flapjack.given("a contact with id 'abc' has pagerduty credentials").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/abc',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/token', :value => 'token123'}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_pagerduty_credentials('abc', :token => 'token123')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several sets of pagerduty credentials" do
      flapjack.given("contacts with ids 'abc' and '872' have pagerduty credentials").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/abc,872',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/token', :value => 'token123'}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_pagerduty_credentials('abc', '872', :token => 'token123')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the contact with pagerduty credentials to update" do
      flapjack.given("no contact exists").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/abc',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/token', :value => 'token123'}]).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.update_pagerduty_credentials('abc', :token => 'token123')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for one set of pagerduty credentials" do

      flapjack.given("a contact with id 'abc' has pagerduty credentials").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/abc',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials('abc')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several sets of pagerduty credentials" do
      flapjack.given("contacts with ids 'abc' and '872' have pagerduty credentials").
        upon_receiving("a DELETE request for two sets of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/abc,872',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials('abc', '872')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the contact with pagerduty credentials to delete" do
      flapjack.given("no contact exists").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/abc',
             :body => nil).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.delete_pagerduty_credentials('abc')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

end
