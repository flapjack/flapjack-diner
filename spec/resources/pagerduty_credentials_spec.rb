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

    it "submits a POST request for pagerduty credentials" do
      data = [{:service_key => 'abc',
               :subdomain   => 'def',
               :username    => 'ghi',
               :password    => 'jkl',
              }]

      req = stub_request(:post, "http://#{server}/contacts/1/pagerduty_credentials").
        with(:body => {:pagerduty_credentials => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('pagerduty_credentials', data))

      result = Flapjack::Diner.create_contact_pagerduty_credentials(1, data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'read' do
   it "submits a GET request for all pagerduty credentials" do
      req = stub_request(:get, "http://#{server}/pagerduty_credentials").
        to_return(:body => response_with_data('pagerduty_credentials'))

      result = Flapjack::Diner.pagerduty_credentials
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for one set of pagerduty credentials" do
      req = stub_request(:get, "http://#{server}/pagerduty_credentials/72").
        to_return(:body => response_with_data('pagerduty_credentials'))

      result = Flapjack::Diner.pagerduty_credentials('72')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several sets of pagerduty credentials" do
      req = stub_request(:get, "http://#{server}/pagerduty_credentials/72,150").
        to_return(:body => response_with_data('pagerduty_credentials'))

      result = Flapjack::Diner.pagerduty_credentials('72', '150')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for one set of pagerduty credentials" do
      req = stub_request(:patch, "http://#{server}/pagerduty_credentials/23").
        with(:body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'lmno'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_pagerduty_credentials('23', :password => 'lmno')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several sets of pagerduty credentials" do
      req = stub_request(:patch, "http://#{server}/pagerduty_credentials/23,87").
        with(:body => [{:op => 'replace', :path => '/pagerduty_credentials/0/username', :value => 'hijk'},
                       {:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'lmno'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_pagerduty_credentials('23', '87', :username => 'hijk', :password => 'lmno')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'delete' do
    it "submits a DELETE request for one set of pagerduty credentials" do
      req = stub_request(:delete, "http://#{server}/pagerduty_credentials/72").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_pagerduty_credentials('72')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several sets of pagerduty credentials" do
      req = stub_request(:delete, "http://#{server}/pagerduty_credentials/72,150").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_pagerduty_credentials('72', '150')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end
  end

end
