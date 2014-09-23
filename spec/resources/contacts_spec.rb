require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Contacts, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = false
  end

  context 'create' do

    it "submits a POST request for a contact" do
      contact_data = [{:id         => 'abc',
                       :first_name => 'Jim',
                       :last_name  => 'Smith',
                       :email      => 'jims@example.com',
                       :timezone   => 'UTC',
                       :tags       => ['admin', 'night_shift']}]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one contact").
        with(:method => :post, :path => '/contacts',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:contacts => contact_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['abc'] )

      result = Flapjack::Diner.create_contacts(contact_data)
      expect(result).not_to be_nil
      expect(result).to eq(['abc'])
    end

    it "submits a POST request for several contacts" do
      contact_data = [{:id         => 'abc',
                       :first_name => 'Jim',
                       :last_name  => 'Smith',
                       :email      => 'jims@example.com',
                       :timezone   => 'UTC',
                       :tags       => ['admin', 'night_shift']},
                      {:id         => 'def',
                       :first_name => 'Joan',
                       :last_name  => 'Smith',
                       :email      => 'joans@example.com'}]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with two contacts").
        with(:method => :post, :path => '/contacts',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:contacts => contact_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['abc', 'def'] )

      result = Flapjack::Diner.create_contacts(contact_data)
      expect(result).not_to be_nil
      expect(result).to eq(['abc', 'def'])
    end

    it "submits a POST request but a contact with that id exists"

  end

  context 'read' do

    context 'GET all contacts' do

      it "has some data" do
        contact_data = {:id         => 'abc',
                        :first_name => 'Jim',
                        :last_name  => 'Smith',
                        :email      => 'jims@example.com',
                        :timezone   => 'UTC',
                        :tags       => ['admin', 'night_shift']}

        flapjack.given("a contact with id 'abc' exists").
          upon_receiving("a GET request for all contacts").
          with(:method => :get, :path => '/contacts').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:contacts => [contact_data]} )

        result = Flapjack::Diner.contacts
        expect(result).not_to be_nil
        expect(result).to eq([contact_data])
      end

      it "has no data" do
        flapjack.given("no contact exists").
          upon_receiving("a GET request for all contacts").
          with(:method => :get, :path => '/contacts').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:contacts => []} )

        result = Flapjack::Diner.contacts
        expect(result).not_to be_nil
        expect(result).to be_an_instance_of(Array)
        expect(result).to be_empty
      end

    end

    context 'GET a single contact' do

      it "finds the contact" do
        contact_data = {:id         => 'abc',
                        :first_name => 'Jim',
                        :last_name  => 'Smith',
                        :email      => 'jims@example.com',
                        :timezone   => 'UTC',
                        :tags       => ['admin', 'night_shift']}

        flapjack.given("a contact with id 'abc' exists").
          upon_receiving("a GET request for a single contact").
          with(:method => :get, :path => '/contacts/abc').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
              :body => {:contacts => [contact_data]} )

        result = Flapjack::Diner.contacts('abc')
        expect(result).not_to be_nil
        expect(result).to be_an_instance_of(Array)
        expect(result.length).to be(1)
        expect(result[0]).to be_an_instance_of(Hash)
        expect(result[0]).to have_key(:id)
      end

      it "can't find the contact" do
        flapjack.given("no contact exists").
          upon_receiving("a GET request for a single contact").
          with(:method => :get, :path => '/contacts/abc').
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => ["could not find contacts 'abc'"]} )

        result = Flapjack::Diner.contacts('abc')
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find contacts 'abc'"])
      end

    end

  end

  context 'update' do

    it "submits a PATCH request for one contact" do
      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a PATCH request to change properties for a single contact").
        with(:method => :patch,
             :path => '/contacts/abc',
             :body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.update_contacts('abc', :timezone => 'UTC')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several contacts" do
      flapjack.given("contacts with ids 'abc' and '872' exist").
        upon_receiving("a PATCH request to change properties for two contacts").
        with(:method => :patch,
             :path => '/contacts/abc,872',
             :body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.update_contacts('abc', '872', :timezone => 'UTC')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request to change a link for one contact" do
      flapjack.given("a contact with id '872' exists").
        upon_receiving("a PATCH requestto change a link for a single contact").
        with(:method => :patch,
             :path => '/contacts/872',
             :body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '1234'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.update_contacts('872', :add_entity => '1234')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request to change links for several contacts" do
      flapjack.given("contacts with ids 'abc' and '872' exist").
        upon_receiving("a PATCH request to change links for two contacts").
        with(:method => :patch,
             :path => '/contacts/abc,872',
             :body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '1234'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.update_contacts('abc', '872', :add_entity => '1234')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find a contact to update" do
      flapjack.given("no contact exists").
        upon_receiving("a PATCH request to change properties for a single contact").
        with(:method => :patch,
             :path => '/contacts/323',
             :body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}],
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find contacts '323'"]} )

      result = Flapjack::Diner.update_contacts('323', :timezone => 'UTC')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contacts '323'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for one contact" do
      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a DELETE request for a single contact").
        with(:method => :delete,
             :path => '/contacts/abc',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_contacts('abc')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several contacts" do
      flapjack.given("contacts with ids 'abc' and '872' exist").
        upon_receiving("a DELETE request for two contacts").
        with(:method => :delete,
             :path => '/contacts/abc,872',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_contacts('abc', '872')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the contact to delete" do
      flapjack.given("no contact exists").
        upon_receiving("a DELETE request for a single contact").
        with(:method => :delete,
             :path => '/contacts/abc',
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find contacts 'abc'"]} )

      result = Flapjack::Diner.delete_contacts('abc')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contacts 'abc'"])
    end
  end

end
