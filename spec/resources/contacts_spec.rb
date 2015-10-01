require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a contact" do
      req_data  = contact_json(contact_data)
      resp_data = req_data.merge(:relationships => contact_rel(contact_data))

      flapjack.given("no data exists").
        upon_receiving("a POST request with one contact").
        with(:method => :post, :path => '/contacts',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.create_contacts(contact_data)
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several contacts" do
      req_data = [contact_json(contact_data), contact_json(contact_2_data)]
      resp_data = [
        req_data[0].merge(:relationships => contact_rel(contact_data)),
        req_data[1].merge(:relationships => contact_rel(contact_2_data))
      ]

      flapjack.given("no data exists").
        upon_receiving("a POST request with two contacts").
        with(:method => :post, :path => '/contacts',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.create_contacts(contact_data, contact_2_data)
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request but a contact with that id exists" do
      req_data  = contact_json(contact_data)

      flapjack.given("a contact exists").
        upon_receiving("a POST request with one contact").
        with(:method => :post, :path => '/contacts',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 409,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:errors => [{
              :status => '409',
              :detail => "Contacts already exist with the following ids: #{contact_data[:id]}"
            }]}
          )

      result = Flapjack::Diner.create_contacts(contact_data)
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '409',
        :detail => "Contacts already exist with the following ids: #{contact_data[:id]}"}])
    end

  end

  context 'read' do

    context 'GET all contacts' do

      it "has some data" do
        resp_data = [contact_json(contact_data).merge(:relationships => contact_rel(contact_data))]

        flapjack.given("a contact exists").
          upon_receiving("a GET request for all contacts").
          with(:method => :get, :path => '/contacts').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.contacts
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "has no data" do
        flapjack.given("no data exists").
          upon_receiving("a GET request for all contacts").
          with(:method => :get, :path => '/contacts').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []})

        result = Flapjack::Diner.contacts
        expect(result).not_to be_nil
        expect(result).to be_an_instance_of(Array)
        expect(result).to be_empty
      end

    end

    context 'GET a single contact' do

      it "finds the contact" do
        resp_data = contact_json(contact_data).merge(:relationships => contact_rel(contact_data))

        flapjack.given("a contact exists").
          upon_receiving("a GET request for a single contact").
          with(:method => :get, :path => "/contacts/#{contact_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.contacts(contact_data[:id])
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "can't find the contact" do
        flapjack.given("no data exists").
          upon_receiving("a GET request for a single contact").
          with(:method => :get, :path => "/contacts/#{contact_data[:id]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:errors => [{
                :status => '404',
                :detail => "could not find Contact record, id: '#{contact_data[:id]}'"
              }]}
            )

        result = Flapjack::Diner.contacts(contact_data[:id])
        expect(result).to be_nil
        expect(Flapjack::Diner.error).to eq([{:status => '404',
          :detail => "could not find Contact record, id: '#{contact_data[:id]}'"}])
      end

    end

    context 'GET a single contact with included data' do

      it 'returns a contact with media' do
        resp_data = contact_json(contact_data).merge(:relationships => contact_rel(contact_data))
        resp_data[:relationships][:media][:data] = [
          {:type => 'medium', :id => email_data[:id]}
        ]
        resp_included = [medium_json(email_data)]

        flapjack.given("a contact with one medium exists").
          upon_receiving("a GET request for a single contact with media").
          with(:method => :get, :path => "/contacts/#{contact_data[:id]}",
            :query => 'include=media').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data, :included => resp_included})

        result = Flapjack::Diner.contacts(contact_data[:id], :include => 'media')
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
        expect(Flapjack::Diner.context).to eq(:included => {'medium' => {email_data[:id] => resultify(resp_included.first)}})
      end

      it 'returns a contact with media and rules' do
        resp_data = contact_json(contact_data).merge(:relationships => contact_rel(contact_data))
        resp_data[:relationships][:media][:data] = [
          {:type => 'medium', :id => email_data[:id]}
        ]
        resp_data[:relationships][:rules][:data] = [
          {:type => 'rule', :id => rule_data[:id]}
        ]
        resp_included = [
          medium_json(email_data),
          rule_json(rule_data)
        ]

        flapjack.given("a contact with one medium and one rule exists").
          upon_receiving("a GET request for a single contact with media and rules").
          with(:method => :get, :path => "/contacts/#{contact_data[:id]}",
            :query => 'include=media%2Crules').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data, :included => resp_included})

        result = Flapjack::Diner.contacts(contact_data[:id], :include => ['media', 'rules'])
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
        expect(Flapjack::Diner.context).to eq(:included => {
          'medium' => {email_data[:id] => resultify(resp_included[0])},
          'rule'  => {rule_data[:id] => resultify(resp_included[1])}
        })

      end
    end
  end

  context 'update' do

    it 'submits a PATCH request for a contact' do
      flapjack.given("a contact exists").
        upon_receiving("a PATCH request for a single contact").
        with(:method => :patch,
             :path => "/contacts/#{contact_data[:id]}",
             :body => {:data => {:id => contact_data[:id], :type => 'contact', :attributes => {:name => 'Hello There'}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_contacts(:id => contact_data[:id], :name => 'Hello There')
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PATCH request for several contacts' do
      flapjack.given("two contacts exist").
        upon_receiving("a PATCH request for two contacts").
        with(:method => :patch,
             :path => "/contacts",
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => [{:id => contact_data[:id], :type => 'contact', :attributes => {:name => 'Hello There'}},
                                 {:id => contact_2_data[:id], :type => 'contact', :attributes => {:name => 'Goodbye Now'}}]}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_contacts(
        {:id => contact_data[:id], :name => 'Hello There'},
        {:id => contact_2_data[:id], :name => 'Goodbye Now'})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the contact to update" do
      flapjack.given("no data exists").
        upon_receiving("a PATCH request for a single contact").
        with(:method => :patch,
             :path => "/contacts/#{contact_data[:id]}",
             :body => {:data => {:id => contact_data[:id], :type => 'contact', :attributes => {:name => 'Hello There'}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Contact record, id: '#{contact_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.update_contacts(:id => contact_data[:id], :name => 'Hello There')
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Contact record, id: '#{contact_data[:id]}'"}])
    end
  end

  context 'delete' do

    it "submits a DELETE request for one contact" do
      flapjack.given("a contact exists").
        upon_receiving("a DELETE request for a single contact").
        with(:method => :delete,
             :path => "/contacts/#{contact_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_contacts(contact_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several contacts" do
      contacts_data = [{:type => 'contact', :id => contact_data[:id]},
                       {:type => 'contact', :id => contact_2_data[:id]}]

      flapjack.given("two contacts exist").
        upon_receiving("a DELETE request for two contacts").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/contacts",
             :body => {:data => contacts_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_contacts(contact_data[:id], contact_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the contact to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single contact").
        with(:method => :delete,
             :path => "/contacts/#{contact_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Contact record, id: '#{contact_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_contacts(contact_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Contact record, id: '#{contact_data[:id]}'"}])
    end
  end

end
