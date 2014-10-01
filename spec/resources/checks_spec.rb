require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Checks, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a check" do
      check_data = [{
        :name       => 'www.example.com:SSH',
        :id         => 'www.example.com:SSH'
      }]

      flapjack.given("no check exists").
        upon_receiving("a POST request with one check").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:checks => check_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['www.example.com:SSH'] )

      result = Flapjack::Diner.create_checks(check_data)
      expect(result).to eq(['www.example.com:SSH'])
    end

    it "submits a POST request for several checks" do
      check_data = [{
        :name       => 'www.example.com:SSH',
        :id         => 'www.example.com:SSH'
      }, {
        :name       => 'www2.example.com:PING',
        :id         => 'www2.example.com:PING'
      }]

      flapjack.given("no check exists").
        upon_receiving("a POST request with two checks").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:checks => check_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['www.example.com:SSH', 'www2.example.com:PING'] )

      result = Flapjack::Diner.create_checks(check_data)
      expect(result).to eq(['www.example.com:SSH', 'www2.example.com:PING'])
    end

  end

  context 'read' do

    let(:check_data) { {:id => 'www.example.com:SSH',
                        :name       => 'www.example.com:SSH',
                       }
                     }

    context 'GET all checks' do

      it "has no data" do
        flapjack.given("no check exists").
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

      it "can't find check" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => '/checks/www.example.com:SSH').
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find Check records, ids: 'www.example.com:SSH'"]} )

        result = Flapjack::Diner.checks('www.example.com:SSH')
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find Check records, ids: 'www.example.com:SSH'"])
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

    it "doesn't find the check to update" do
      flapjack.given("no check exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => '/checks/www.example.com:SSH',
             :body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Check records, ids: 'www.example.com:SSH'"]} )

      result = Flapjack::Diner.update_checks('www.example.com:SSH', :enabled => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Check records, ids: 'www.example.com:SSH'"])
    end

  end

end
