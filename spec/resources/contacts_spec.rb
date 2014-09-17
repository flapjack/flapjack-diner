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

    it "submits a POST request for a contact" do
      data = [{:first_name => 'Jim',
               :last_name  => 'Smith',
               :email      => 'jims@example.com',
               :timezone   => 'UTC',
               :tags       => ['admin', 'night_shift']}]

      req = stub_request(:post, "http://#{server}/contacts").
        with(:body => {:contacts => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('contacts', data))

      result = Flapjack::Diner.create_contacts(data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a POST request for several contacts" do
      data = [{:first_name => 'Jim',
               :last_name  => 'Smith',
               :email      => 'jims@example.com',
               :timezone   => 'UTC',
               :tags       => ['admin', 'night_shift']},
              {:first_name => 'Joan',
               :last_name  => 'Smith',
               :email      => 'joans@example.com'}]

      req = stub_request(:post, "http://#{server}/contacts").
        with(:body => {:contacts => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('contacts', data))

      result = Flapjack::Diner.create_contacts(data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'read' do
    it "submits a GET request for all contacts" do
      data = [{:id => "21"}]

      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :status => 200, :body => response_with_data('contacts', data))

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_an_instance_of(Array)
      expect(result.length).to be(1)
      expect(result[0]).to be_an_instance_of(Hash)
      expect(result[0]).to have_key('id')
    end

    it "can return keys as symbols" do
      Flapjack::Diner.return_keys_as_strings = false
      data = [{
        :id         => "21",
        :first_name => "Ada",
        :last_name  => "Lovelace",
        :email      => "ada@example.com",
        :timezone   => "Europe/London",
        :tags       => [ "legend", "first computer programmer" ],
        :links      => {
          :entities           => ["7", "12", "83"],
          :media              => ["21_email", "21_sms"],
          :notification_rules => ["30fd36ae-3922-4957-ae3e-c8f6dd27e543"]
        }
      }]

      req = stub_request(:get, "http://#{server}/contacts").to_return(
        :status => 200, :body => response_with_data('contacts', data))

      result = Flapjack::Diner.contacts
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_an_instance_of(Array)
      expect(result.length).to be(1)
      expect(result[0]).to be_an_instance_of(Hash)
      expect(result[0]).to have_key(:id)
      expect(result[0]).to have_key(:links)
      expect(result[0][:links]).to have_key(:entities)
    end

    it "submits a GET request for one contact" do
      req = stub_request(:get, "http://#{server}/contacts/72").to_return(
        :body => response_with_data('contacts'))

      result = Flapjack::Diner.contacts('72')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several contacts" do
      req = stub_request(:get, "http://#{server}/contacts/72,150").to_return(
        :body => response_with_data('contacts'))

      result = Flapjack::Diner.contacts('72', '150')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for one contact" do
      req = stub_request(:patch, "http://#{server}/contacts/23").
        with(:body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_contacts(23, :timezone => 'UTC')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several contacts" do
      req = stub_request(:patch, "http://#{server}/contacts/23,87").
        with(:body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_contacts(23, 87, :timezone => 'UTC')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request to change a link for one contact" do
      req = stub_request(:patch, "http://#{server}/contacts/23").
        with(:body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '57'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_contacts(23, :add_entity => '57')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request to change links for several contacts" do
      req = stub_request(:patch, "http://#{server}/contacts/23,87").
        with(:body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '57'}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_contacts(23, 87, :add_entity => '57')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'delete' do
    it "submits a DELETE request for one contact" do
      req = stub_request(:delete, "http://#{server}/contacts/72").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_contacts('72')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several contacts" do
      req = stub_request(:delete, "http://#{server}/contacts/72,150").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_contacts('72', '150')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end
  end

end
