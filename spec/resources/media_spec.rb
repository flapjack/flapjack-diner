require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Media, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a medium" do
      flapjack.given("no data exists").
        upon_receiving("a POST request with one medium").
        with(:method => :post,
             :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => sms_data.merge(:type => 'medium')}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => sms_data.merge(:type => 'medium')})

      result = Flapjack::Diner.create_media(sms_data)
      expect(result).not_to be_nil
      expect(result).to eq(sms_data.merge(:type => 'medium'))
    end

    it "submits a POST request for several media" do
      media_data = [sms_data.merge(:type => 'medium'),
                    email_data.merge(:type => 'medium')]

      flapjack.given("no data exists").
        upon_receiving("a POST request with two media").
        with(:method => :post,
             :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => media_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => media_data})

      result = Flapjack::Diner.create_media(*media_data)
      expect(result).not_to be_nil
      expect(result).to eq(media_data)
    end

  end

  context 'read' do

    it "submits a GET request for all media" do
      media_data = [email_data.merge(:type => 'medium'), sms_data.merge(:type => 'medium')]

      flapjack.given("two media exist").
        upon_receiving("a GET request for all media").
        with(:method => :get,
             :path => '/media').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => media_data})

      result = Flapjack::Diner.media
      expect(result).to contain_exactly(*media_data)
    end

    it "submits a GET request for one medium" do
      flapjack.given("a medium exists").
        upon_receiving("a GET request for one medium").
        with(:method => :get, :path => "/media/#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => sms_data.merge(:type => 'medium')} )

      result = Flapjack::Diner.media(sms_data[:id])
      expect(result).to eq(sms_data.merge(:type => 'medium'))
    end

    it "submits a GET request for several media" do
      media_data = [email_data.merge(:type => 'medium'),
                    sms_data.merge(:type => 'medium')]

      flapjack.given("two media exist").
        upon_receiving("a GET request for two media").
        with(:method => :get, :path => '/media',
             :query => "filter%5B%5D=id%3A#{email_data[:id]}%7C#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => media_data} )

      result = Flapjack::Diner.media(email_data[:id], sms_data[:id])
      expect(result).to eq(media_data)
    end

  end

  context 'update' do

    it 'submits a PATCH request for a medium' do
      flapjack.given("a medium exists").
        upon_receiving("a PATCH request for a single medium").
        with(:method => :patch,
             :path => "/media/#{sms_data[:id]}",
             :body => {:data => {:id => sms_data[:id], :type => 'medium', :interval => 50}},
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
             :body => {:data => [{:id => email_data[:id], :type => 'medium', :interval => 50},
                                 {:id => sms_data[:id], :type => 'medium', :rollup_threshold => 5}]}).
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
             :body => {:data => {:id => email_data[:id], :type => 'medium', :interval => 50}},
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
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
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
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Medium record, id: '#{sms_data[:id]}'"}])
    end

  end

end
