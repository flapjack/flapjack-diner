require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::PagerdutyCredentials, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for pagerduty credentials" do
      data = [{:id          => 'rstuv',
               :service_key => 'abc',
               :subdomain   => 'def',
               :username    => 'ghi',
               :password    => 'jkl',
              }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with one set of pagerduty credentials").
        with(:method => :post, :path => '/contacts/abc/pagerduty_credentials',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:pagerduty_credentials => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['rstuv'] )

      result = Flapjack::Diner.create_contact_pagerduty_credentials('abc', data)
      expect(result).to eq(['rstuv'])
    end

    it "can't find the contact to create pagerduty credentials for" do
      data = [{:id          => 'rstuv',
               :service_key => 'abc',
               :subdomain   => 'def',
               :username    => 'ghi',
               :password    => 'jkl',
              }]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one set of pagerduty credentials").
        with(:method => :post, :path => '/contacts/abc/pagerduty_credentials',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:pagerduty_credentials => data}).
        will_respond_with(
          :status => 403,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["Contact with id 'abc' could not be loaded"]} )

      result = Flapjack::Diner.create_contact_pagerduty_credentials('abc', data)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 403,
        :errors => ["Contact with id 'abc' could not be loaded"])
    end

  end

  context 'read' do
   it "submits a GET request for all pagerduty credentials" do
      pdc_data = [{
        :id          => 'rstuv',
        :service_key => 'abc',
        :subdomain   => 'def',
        :username    => 'ghi',
        :password    => 'jkl',
      }]

      flapjack.given("a set of pagerduty credentials 'rstuv' exists").
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
        :id          => 'rstuv',
        :service_key => 'abc',
        :subdomain   => 'def',
        :username    => 'ghi',
        :password    => 'jkl',
      }]

      flapjack.given("a set of pagerduty credentials 'rstuv' exists").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/rstuv').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdc_data} )

      result = Flapjack::Diner.pagerduty_credentials('rstuv')
      expect(result).to eq(pdc_data)
    end

    it "submits a GET request for several sets of pagerduty credentials" do
      pdc_data = [{
        :id          => 'rstuv',
        :service_key => 'abc',
        :subdomain   => 'def',
        :username    => 'ghi',
        :password    => 'jkl',
      }, {
        :id          => 'wxyza',
        :service_key => 'mno',
        :subdomain   => 'pqr',
        :username    => 'stu',
        :password    => 'vwx',
      }]

      flapjack.given("two sets of pagerduty credentials 'rstuv' and 'wxyza' exist").
        upon_receiving("a GET request for two sets of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/rstuv,wxyza').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdc_data} )

      result = Flapjack::Diner.pagerduty_credentials('rstuv', 'wxyza')
      expect(result).to eq(pdc_data)
    end

    it "can't find the pagerduty credentials to read" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials/rstuv').
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"]} )

      result = Flapjack::Diner.pagerduty_credentials('rstuv')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"])
    end

  end

  context 'update' do

    it "submits a PATCH request for one set of pagerduty credentials" do
      flapjack.given("a set of pagerduty credentials 'rstuv' exists").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/rstuv',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_pagerduty_credentials('rstuv', :password => 'pswrd')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several sets of pagerduty credentials" do
      flapjack.given("two sets of pagerduty credentials 'rstuv' and 'wxyza' exist").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/rstuv,wxyza',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_pagerduty_credentials('rstuv', 'wxyza', :password => 'pswrd')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the pagerduty credentials to update" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a PATCH request for pagerduty credentials").
        with(:method => :patch,
             :path => '/pagerduty_credentials/rstuv',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"]} )

      result = Flapjack::Diner.update_pagerduty_credentials('rstuv', :password => 'pswrd')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for one set of pagerduty credentials" do

      flapjack.given("a set of pagerduty credentials 'rstuv' exists").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/rstuv',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials('rstuv')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several sets of pagerduty credentials" do
      flapjack.given("two sets of pagerduty credentials 'rstuv' and 'wxyza' exist").
        upon_receiving("a DELETE request for two sets of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/rstuv,wxyza',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials('rstuv', 'wxyza')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the pagerduty credentials to delete" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => '/pagerduty_credentials/rstuv',
             :body => nil).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"]} )

      result = Flapjack::Diner.delete_pagerduty_credentials('rstuv')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"])
    end

  end

end
