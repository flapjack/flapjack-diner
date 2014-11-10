require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Media, :pact => true do

  include_context 'fixture data'

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a medium" do
      flapjack.given("no medium records exist").
        upon_receiving("a POST request with one medium").
        with(:method => :post, :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:media => sms_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => sms_data})

      result = Flapjack::Diner.create_media(sms_data)
      expect(result).not_to be_nil
      expect(result).to eq(sms_data)
    end

    it "submits a POST request for several media" do
      media_data = [sms_data, email_data]

      flapjack.given("no medium records exist").
        upon_receiving("a POST request with two media").
        with(:method => :post, :path => '/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:media => media_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.create_media(*media_data)
      expect(result).not_to be_nil
      expect(result).to eq(media_data)
    end

  end

  context 'read' do

    let(:links) { {:links => {:contacts => ['c248da6f-ab16-4ce3-9b32-afd4e5f5270e']}} }

    it "submits a GET request for all media" do
      # passes rspec, but fails the flapjack server pact run, so can't set
      # as pending
      skip "ordering not consistent, no way to indicate this in pact"
      # should sandstorm enforce a sorted order on ids returned?

      media_data = [email_data.merge(links), sms_data.merge(links)]

      flapjack.given("media with ids '#{sms_data[:id]}' and '#{email_data[:id]}' exist").
        upon_receiving("a GET request for all media").
        with(:method => :get, :path => '/media').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media
      expect(result).to contain_exactly(*media_data)
    end

    it "submits a GET request for one medium" do
      media_data = [sms_data.merge(links)]

      flapjack.given("a medium with id '#{sms_data[:id]}' exists").
        upon_receiving("a GET request for sms media").
        with(:method => :get, :path => "/media/#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media(sms_data[:id])
      expect(result).to eq(media_data)
    end

    it "submits a GET request for several media" do
      media_data = [email_data.merge(links), sms_data.merge(links)]

      flapjack.given("media with ids '#{sms_data[:id]}' and '#{email_data[:id]}' exist").
        upon_receiving("a GET request for email and sms media").
        with(:method => :get, :path => "/media/#{email_data[:id]},#{sms_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media(email_data[:id], sms_data[:id])
      expect(result).to eq(media_data)
    end

  end

  context 'update' do

    it 'submits a PUT request for a medium' do
      flapjack.given("a medium with id '#{email_data[:id]}' exists").
        upon_receiving("a PUT request for a single medium").
        with(:method => :put,
             :path => "/media/#{email_data[:id]}",
             :body => {:media => {:id => email_data[:id], :interval => 50}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media(:id => email_data[:id], :interval => 50)
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PUT request for several media' do
      flapjack.given("media with ids '#{email_data[:id]}' and '#{sms_data[:id]}' exist").
        upon_receiving("a PUT request for two media").
        with(:method => :put,
             :path => "/media/#{email_data[:id]},#{sms_data[:id]}",
             :body => {:media => [{:id => email_data[:id], :interval => 50},
             {:id => sms_data[:id], :rollup_threshold => 5}]},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media(
        {:id => email_data[:id], :interval => 50},
        {:id => sms_data[:id], :rollup_threshold => 5})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the medium to update" do
      flapjack.given("no medium exists").
        upon_receiving("a PUT request for a single medium").
        with(:method => :put,
             :path => "/media/#{email_data[:id]}",
             :body => {:media => {:id => email_data[:id], :interval => 50}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find Medium records, ids: '#{email_data[:id]}'"]} )

      result = Flapjack::Diner.update_media(:id => email_data[:id], :interval => 50)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Medium records, ids: '#{email_data[:id]}'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for one medium" do

    flapjack.given("a medium with id '#{sms_data[:id]}' exists").
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
      flapjack.given("media with ids '#{sms_data[:id]}' and '#{email_data[:id]}' exist").
        upon_receiving("a DELETE request for two media").
        with(:method => :delete,
             :path => "/media/#{sms_data[:id]},#{email_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_media(sms_data[:id], email_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the contact with media to delete" do
      flapjack.given("no media exist").
        upon_receiving("a DELETE request for one medium").
        with(:method => :delete,
             :path => "/media/#{sms_data[:id]}",
             :body => nil).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find Medium records, ids: '#{sms_data[:id]}'"]} )

      result = Flapjack::Diner.delete_media(sms_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find Medium records, ids: '#{sms_data[:id]}'"])
    end

  end

end
