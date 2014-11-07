require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::PagerdutyCredentials, :pact => true do

  include_context 'fixture data'

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for pagerduty credentials" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a POST request with one set of pagerduty credentials").
        with(:method => :post, :path => '/pagerduty_credentials',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:pagerduty_credentials => pagerduty_credentials_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pagerduty_credentials_data} )

      result = Flapjack::Diner.create_pagerduty_credentials(pagerduty_credentials_data)
      expect(result).to eq(pagerduty_credentials_data)
    end

    # TODO fails to create with invalid data

  end

  context 'read' do
   it "submits a GET request for all pagerduty credentials" do
      flapjack.given("a set of pagerduty credentials with id #{pagerduty_credentials_data[:id]} exists").
        upon_receiving("a GET request for all pagerduty credentials").
        with(:method => :get, :path => '/pagerduty_credentials').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pagerduty_credentials_data} )

      result = Flapjack::Diner.pagerduty_credentials
      expect(result).to eq(pagerduty_credentials_data)
    end

    it "submits a GET request for one set of pagerduty credentials" do
      flapjack.given("a set of pagerduty credentials with id #{pagerduty_credentials_data[:id]} exists").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pagerduty_credentials_data} )

      result = Flapjack::Diner.pagerduty_credentials(pagerduty_credentials_data[:id])
      expect(result).to eq(pagerduty_credentials_data)
    end

    it "submits a GET request for several sets of pagerduty credentials" do
      pdcs_data = [pagerduty_credentials_data, pagerduty_credentials_2_data]
      flapjack.given("two sets of pagerduty credentials with ids #{pagerduty_credentials_data[:id]} and #{pagerduty_credentials_2_data[:id]} exist").
        upon_receiving("a GET request for two sets of pagerduty credentials").
        with(:method => :get, :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]},#{pagerduty_credentials_2_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:pagerduty_credentials => pdcs_data} )

      result = Flapjack::Diner.pagerduty_credentials(pagerduty_credentials_data[:id], pagerduty_credentials_2_data[:id])
      expect(result).to eq(pdcs_data)
    end

    it "can't find the pagerduty credentials to read" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a GET request for one set of pagerduty credentials").
        with(:method => :get, :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]}").
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find PagerdutyCredentials records, ids: '#{pagerduty_credentials_data[:id]}'"]} )

      result = Flapjack::Diner.pagerduty_credentials(pagerduty_credentials_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find PagerdutyCredentials records, ids: '#{pagerduty_credentials_data[:id]}'"])
    end

  end

  # context 'update' do

  #   it "submits a PATCH request for one set of pagerduty credentials" do
  #     flapjack.given("a set of pagerduty credentials 'rstuv' exists").
  #       upon_receiving("a PATCH request for pagerduty credentials").
  #       with(:method => :patch,
  #            :path => '/pagerduty_credentials/rstuv',
  #            :headers => {'Content-Type'=>'application/json-patch+json'},
  #            :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_pagerduty_credentials('rstuv', :password => 'pswrd')
  #     expect(result).not_to be_nil
  #     expect(result).to be_truthy
  #   end

  #   it "submits a PATCH request for several sets of pagerduty credentials" do
  #     flapjack.given("two sets of pagerduty credentials 'rstuv' and 'wxyza' exist").
  #       upon_receiving("a PATCH request for pagerduty credentials").
  #       with(:method => :patch,
  #            :path => '/pagerduty_credentials/rstuv,wxyza',
  #            :headers => {'Content-Type'=>'application/json-patch+json'},
  #            :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_pagerduty_credentials('rstuv', 'wxyza', :password => 'pswrd')
  #     expect(result).not_to be_nil
  #     expect(result).to be_truthy
  #   end

  #   it "can't find the pagerduty credentials to update" do
  #     flapjack.given("no pagerduty credentials exist").
  #       upon_receiving("a PATCH request for pagerduty credentials").
  #       with(:method => :patch,
  #            :path => '/pagerduty_credentials/rstuv',
  #            :headers => {'Content-Type'=>'application/json-patch+json'},
  #            :body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'pswrd'}]).
  #       will_respond_with(:status => 404,
  #                         :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
  #         :body => {:errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"]} )

  #     result = Flapjack::Diner.update_pagerduty_credentials('rstuv', :password => 'pswrd')
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
  #         :errors => ["could not find PagerdutyCredentials records, ids: 'rstuv'"])
  #   end

  # end

  context 'delete' do
    it "submits a DELETE request for one set of pagerduty credentials" do

      flapjack.given("a set of pagerduty credentials with id #{pagerduty_credentials_data[:id]} exists").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials(pagerduty_credentials_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several sets of pagerduty credentials" do
      flapjack.given("two sets of pagerduty credentials with ids #{pagerduty_credentials_data[:id]} and #{pagerduty_credentials_2_data[:id]} exist").
        upon_receiving("a DELETE request for two sets of pagerduty credentials").
        with(:method => :delete,
             :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]},#{pagerduty_credentials_2_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_pagerduty_credentials(pagerduty_credentials_data[:id],
        pagerduty_credentials_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the pagerduty credentials to delete" do
      flapjack.given("no pagerduty credentials exist").
        upon_receiving("a DELETE request for one set of pagerduty credentials").
        with(:method => :delete,
             :path => "/pagerduty_credentials/#{pagerduty_credentials_data[:id]}",
             :body => nil).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find PagerdutyCredentials records, ids: '#{pagerduty_credentials_data[:id]}'"]} )

      result = Flapjack::Diner.delete_pagerduty_credentials(pagerduty_credentials_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find PagerdutyCredentials records, ids: '#{pagerduty_credentials_data[:id]}'"])
    end

  end

end
