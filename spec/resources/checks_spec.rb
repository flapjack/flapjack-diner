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
                          :entities => ['1234']
                        }
                       }
                     }

    context 'GET all checks' do

      it "has no data" do
        flapjack.given("no entity exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:checks => []} )

        result = Flapjack::Diner.checks
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:checks => [check_data]} )

        result = Flapjack::Diner.checks
        expect(result).to eq([check_data])
      end

    end

    context 'GET a single check' do

      it "has some data" do
        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => '/checks/www.example.com:SSH').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:checks => [check_data]} )

        result = Flapjack::Diner.checks('www.example.com:SSH')
        expect(result).to eq([check_data])
      end

      it "can't find entity for a check" do
        flapjack.given("no entity exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => '/checks/www.example.com:SSH').
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find entity checks: 'www.example.com:SSH'"]} )

        result = Flapjack::Diner.checks('www.example.com:SSH')
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entity checks: 'www.example.com:SSH'"])
      end

    end

  end

  context 'update' do

    it "submits a PATCH request for a check" do
      flapjack.given("a check 'www.example.com:SSH' exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => '/checks/www.example.com:SSH',
             :body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.update_checks('www.example.com:SSH', :enabled => false)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "doesn't find the entity of the check to update" do
      flapjack.given("no entity exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => '/checks/www.example.com:SSH',
             :body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find entity 'www.example.com'"]} )

      result = Flapjack::Diner.update_checks('www.example.com:SSH', :enabled => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find entity 'www.example.com'"])
    end

  end

end
