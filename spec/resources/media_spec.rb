require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a medium" do
      req_data  = medium_json(sms_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )
      resp_data = medium_json(sms_data).merge(:relationships => medium_rel(sms_data))

      flapjack.given("a contact exists").
        upon_receiving("a POST request with one medium").
        with(:method => :post,
             :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => { :data => resp_data }
        )

      result = Flapjack::Diner.create_media(sms_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several media" do
      req_data = [medium_json(email_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      ), medium_json(sms_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )]
      resp_data = [
        medium_json(email_data).merge(:relationships => medium_rel(email_data)),
        medium_json(sms_data).merge(:relationships => medium_rel(sms_data))
      ]

      flapjack.given("a contact exists").
        upon_receiving("a POST request with two media").
        with(:method => :post,
             :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.create_media(email_data.merge(:contact => contact_data[:id]),
        sms_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

  end

  context 'read' do

    it "submits a GET request for all media" do
      result_data = [
        medium_json(email_data),
        medium_json(sms_data)
      ]
      resp_data = [
        result_data[0].merge(:relationships => medium_rel(email_data)),
        result_data[1].merge(:relationships => medium_rel(sms_data))
      ]

      flapjack.given("two media exist").
        upon_receiving("a GET request for all media").
        with(:method => :get,
             :path => '/media').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.media
      expect(result).to contain_exactly(resultify(resp_data[0]), resultify(resp_data[1]))
    end

    it "submits a GET request for one medium" do
      resp_data = medium_json(sms_data).merge(:relationships => medium_rel(sms_data))

      flapjack.given("a medium exists").
        upon_receiving("a GET request for one medium").
        with(:method => :get, :path => "/media/#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data} )

      result = Flapjack::Diner.media(sms_data[:id])
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for several media" do
      resp_data = [
        medium_json(email_data).merge(:relationships => medium_rel(email_data)),
        medium_json(sms_data).merge(:relationships => medium_rel(sms_data))
      ]

      flapjack.given("two media exist").
        upon_receiving("a GET request for two media").
        with(:method => :get, :path => '/media',
             :query => "filter%5B%5D=id%3A#{email_data[:id]}%7C#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data} )

      result = Flapjack::Diner.media(email_data[:id], sms_data[:id])
      expect(result).to eq(resultify(resp_data))
    end

  end

  context 'update' do

    it 'submits a PATCH request for a medium' do
      flapjack.given("a medium exists").
        upon_receiving("a PATCH request for a single medium").
        with(:method => :patch,
             :path => "/media/#{sms_data[:id]}",
             :body => {:data => {:id => sms_data[:id], :type => 'medium', :attributes => {:interval => 50}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media(:id => sms_data[:id], :interval => 50)
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PATCH request for several media' do
      flapjack.given("two media exist").
        upon_receiving("a PATCH request for two media").
        with(:method => :patch,
             :path => "/media",
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => [{:id => email_data[:id], :type => 'medium', :attributes => {:interval => 50}},
                                 {:id => sms_data[:id], :type => 'medium', :attributes => {:rollup_threshold => 5}}]}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media(
        {:id => email_data[:id], :interval => 50},
        {:id => sms_data[:id], :rollup_threshold => 5})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the medium to update" do
      flapjack.given("no data exists").
        upon_receiving("a PATCH request for a single medium").
        with(:method => :patch,
             :path => "/media/#{email_data[:id]}",
             :body => {:data => {:id => email_data[:id], :type => 'medium', :attributes => {:interval => 50}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Medium record, id: '#{email_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.update_media(:id => email_data[:id], :interval => 50)
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Medium record, id: '#{email_data[:id]}'"}])
    end

  end

  context 'delete' do

    it "submits a DELETE request for one medium" do

    flapjack.given("a medium exists").
        upon_receiving("a DELETE request for one medium").
        with(:method => :delete,
             :path => "/media/#{sms_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_media(sms_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several media" do
      media_data = [{:type => 'medium', :id => sms_data[:id]},
                    {:type => 'medium', :id => email_data[:id]}]

      flapjack.given("two media exist").
        upon_receiving("a DELETE request for two media").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/media",
             :body => {:data => media_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_media(sms_data[:id], email_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the contact with media to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for one medium").
        with(:method => :delete,
             :path => "/media/#{sms_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Medium record, id: '#{sms_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_media(sms_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Medium record, id: '#{sms_data[:id]}'"}])
    end

  end

end
