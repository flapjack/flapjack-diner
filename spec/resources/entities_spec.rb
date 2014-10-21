require 'spec_helper'
require 'flapjack_diner'

describe Flapjack::Diner, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

   it "submits a POST request for an entity" do
      entity_data = [{
        :name => 'example.org',
        :id   => '57_example'
      }]

      flapjack.given("no entity exists").
        upon_receiving("a POST request with one entity").
        with(:method => :post, :path => '/entities',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:entities => entity_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['57_example'] )

      result = Flapjack::Diner.create_entities(entity_data)
      expect(result).not_to be_nil
      expect(result).to eq(['57_example'])
    end

    it "submits a POST request for several entities" do
      entity_data = [{
        :name => 'example.org',
        :id   => '57_example'
      }, {
        :name => 'example2.org',
        :id   => '58'
      }]

      flapjack.given("no entity exists").
        upon_receiving("a POST request with two entities").
        with(:method => :post, :path => '/entities',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:entities => entity_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['57_example', '58'] )

      result = Flapjack::Diner.create_entities(entity_data)
      expect(result).not_to be_nil
      expect(result).to eq(['57_example', '58'])
    end

  end

  context 'read' do

    context 'GET all entities' do

      it 'has some data' do
        entity_data = {
          :name => 'www.example.com',
          :id   => '1234'
        }

       flapjack.given("an entity 'www.example.com' with id '1234' exists").
          upon_receiving("a GET request for all entities").
          with(:method => :get, :path => '/entities').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:entities => [entity_data]} )

        result = Flapjack::Diner.entities
        expect(result).not_to be_nil
        expect(result).to eq([entity_data])
      end

      it 'has no data' do
        flapjack.given("no entity exists").
          upon_receiving("a GET request for all entities").
          with(:method => :get, :path => '/entities').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:entities => []} )

        result = Flapjack::Diner.entities
        expect(result).not_to be_nil
        expect(result).to eq([])
      end

    end

    context 'GET a single entity' do

      it 'finds the entity' do
        entity_data = {
          :name => 'www.example.com',
          :id   => '1234'
        }

       flapjack.given("an entity 'www.example.com' with id '1234' exists").
          upon_receiving("a GET request for a single entity").
          with(:method => :get, :path => '/entities/1234').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:entities => [entity_data]} )

        result = Flapjack::Diner.entities('1234')
        expect(result).not_to be_nil
        expect(result).to eq([entity_data])
      end

      it "can't find the entity" do
        entity_data = {
          :name => 'www.example.com',
          :id   => '1234'
        }

       flapjack.given("no entity exists").
          upon_receiving("a GET request for a single entity").
          with(:method => :get, :path => '/entities/1234').
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find entities: '1234'"]} )

        result = Flapjack::Diner.entities('1234')
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entities: '1234'"])
      end

    end

  end

  context 'update' do

    it "submits a PATCH request for an entity" do
      flapjack.given("an entity 'www.example.com' with id '1234' exists").
        upon_receiving("a PATCH request for a single entity").
        with(:method => :patch,
             :path => '/entities/1234',
             :body => [{:op => 'replace', :path => '/entities/0/name', :value => 'example3.com'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.update_entities('1234', :name => 'example3.com')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the entity to update" do
      flapjack.given("no entity exists").
        upon_receiving("a PATCH request for a single entity").
        with(:method => :patch,
             :path => '/entities/1234',
             :body => [{:op => 'replace', :path => '/entities/0/name', :value => 'example3.com'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find entity '1234'"]} )

      result = Flapjack::Diner.update_entities('1234', :name => 'example3.com')
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find entity '1234'"])
    end

  end

end
