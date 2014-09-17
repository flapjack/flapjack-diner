require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }

  let(:time) { Time.now }

  def response_with_data(name, data = [])
    "{\"#{name}\":#{data.to_json}}"
  end

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = true
  end

  after(:each) do
    WebMock.reset!
  end

  context 'create' do

   it "submits a POST request for an entity" do
      data = [{
        :name => 'example.org',
        :id   => '57_example'
      }]

      req = stub_request(:post, "http://#{server}/entities").
        with(:body => {:entities => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('entities', data))

      result = Flapjack::Diner.create_entities(data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a POST request for several entities" do
      data = [{
        :name => 'example.org',
        :id   => '57_example'
      }, {
        :name => 'example2.org',
        :id   => '58'
      }]

      req = stub_request(:post, "http://#{server}/entities").
        with(:body => {:entities => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('entities', data))

      result = Flapjack::Diner.create_entities(data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'read' do
    it "submits a GET request for all entities" do
      req = stub_request(:get, "http://#{server}/entities").
        to_return(:body => response_with_data('entities'))

      result = Flapjack::Diner.entities
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for one entity" do
      req = stub_request(:get, "http://#{server}/entities/72").
        to_return(:body => response_with_data('entities'))

      result = Flapjack::Diner.entities('72')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several entities" do
      req = stub_request(:get, "http://#{server}/entities/72,150").
        to_return(:body => response_with_data('entities'))

      result = Flapjack::Diner.entities('72', '150')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for an entity" do
      req = stub_request(:patch, "http://#{server}/entities/57").
        with(:body => [{:op => 'replace', :path => '/entities/0/name', :value => 'example3.com'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_entities('57', :name => 'example3.com')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

end
