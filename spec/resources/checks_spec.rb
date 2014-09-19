require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Checks, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = false
  end

  context 'read' do

    let(:check_data) { {:id => 'www.example.com:SSH',
                        :name => 'SSH',
                        :entity_name => 'www.example.com',
                        :links => {
                          :entities => ['da0553fb-dd9c-4105-8112-110e68293994']
                        }
                       }
                     }

    context 'GET all checks' do

      it "has no data" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/json'},
            :body => {:checks => []} )

        result = Flapjack::Diner.checks
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a check exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/json'},
            :body => {:checks => [check_data]} )

        result = Flapjack::Diner.checks
        expect(result).to eq([check_data])
      end

    end

    context 'GET a single check' do

      it "has no data" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => '/checks/www.example.com:SSH').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/json'},
            :body => {:checks => []} )

        result = Flapjack::Diner.checks('www.example.com:SSH')
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a check exists").
          upon_receiving("a GET request check 'www.example.com:SSH'").
          with(:method => :get, :path => '/checks/www.example.com:SSH').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/json'},
            :body => {:checks => [check_data]} )

        result = Flapjack::Diner.checks('www.example.com:SSH')
        expect(result).to eq([check_data])
      end

      it "can't find check" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for check 'www.example.com:PING'").
          with(:method => :get, :path => '/checks/www.example.com:PING').
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/json'},
            :body => {:errors => "could not find entity check 'www.example.com:PING'"} )

        result = Flapjack::Diner.checks('www.example.com:PING')
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => "could not find entity check 'www.example.com:PING'")
      end

    end

  end

  context 'update' do

    it "submits a PATCH request for a check" do
      flapjack.given("a check exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => '/checks/www.example.com:PING',
             :body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 204,
          :headers => {'Content-Type' => 'application/json'},
          :body => '')

      result = Flapjack::Diner.update_checks('www.example.com:PING', :enabled => false)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "doesn't find the check to update" do
      flapjack.given("no check exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => '/checks/www.example.com:PING',
             :body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/json'},
          :body => {:errors => "could not find entity check 'www.example.com:PING'"} )

      result = Flapjack::Diner.update_checks('www.example.com:PING', :enabled => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => "could not find entity check 'www.example.com:PING'")
    end

  end

end
