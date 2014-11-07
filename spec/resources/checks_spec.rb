require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Checks, :pact => true do

  include_context 'fixture data'

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a check" do
      flapjack.given("no check exists").
        upon_receiving("a POST request with one check").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:checks => check_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'checks' => check_data} )

      result = Flapjack::Diner.create_checks(check_data)
      expect(result).to eq(check_data)
    end

    it "submits a POST request for several checks" do
      checks_data = [check_data, check_2_data]

      flapjack.given("no check exists").
        upon_receiving("a POST request with two checks").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:checks => checks_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'checks' => checks_data})

      result = Flapjack::Diner.create_checks(checks_data)
      expect(result).to eq(checks_data)
    end

    # TODO fails to create with invalid data
  end

  context 'read' do

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
        flapjack.given("a check with id '#{check_data[:id]}' exists").
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
        flapjack.given("a check with id '#{check_data[:id]}' exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => "/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:checks => [check_data]} )

        result = Flapjack::Diner.checks(check_data[:id])
        expect(result).to eq([check_data])
      end

      it "can't find check" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for check 'www.example.com:SSH'").
          with(:method => :get, :path => "/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find Check records, ids: '#{check_data[:id]}'"]} )

        result = Flapjack::Diner.checks(check_data[:id])
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find Check records, ids: '#{check_data[:id]}'"])
      end

    end

  end

  context 'update' do

    it 'submits a PUT request for a check' do
      flapjack.given("a check with id '#{check_data[:id]}' exists").
        upon_receiving("a PUT request for a single check").
        with(:method => :put,
             :path => "/checks/#{check_data[:id]}",
             :body => {:checks => {:id => check_data[:id], :enabled => false}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_checks(check_data[:id], :enabled => false)
      expect(result).to be_a(TrueClass)
    end

    it "can't find the check to update" do
      flapjack.given("no check exists").
        upon_receiving("a PUT request for a single check").
        with(:method => :put,
             :path => "/checks/#{check_data[:id]}",
             :body => {:checks => {:id => check_data[:id], :enabled => false}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Check records, ids: '#{check_data[:id]}'"]} )

      result = Flapjack::Diner.update_checks(check_data[:id], :enabled => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Check records, ids: '#{check_data[:id]}'"])
    end

  end

end
