require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Checks do

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

  context 'read' do
    it "submits a GET request for all checks" do
      req = stub_request(:get, "http://#{server}/checks").
        to_return(:body => response_with_data('checks'))

      result = Flapjack::Diner.checks
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for one check" do
      req = stub_request(:get, "http://#{server}/checks/example.com%3ASSH").
        to_return(:body => response_with_data('checks'))

      result = Flapjack::Diner.checks('example.com:SSH')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several checks" do
      req = stub_request(:get, "http://#{server}/checks/example.com%3ASSH,example2.com%3APING").
        to_return(:body => response_with_data('checks'))

      result = Flapjack::Diner.checks('example.com:SSH', 'example2.com:PING')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for a check" do
      req = stub_request(:patch, "http://#{server}/checks/www.example.com%3APING").
        with(:body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_checks('www.example.com:PING', :enabled => false)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

end
