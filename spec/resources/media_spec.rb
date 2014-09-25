require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Media, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = false
  end

  context 'create' do

    it "submits a POST request for a medium" do
      data = [{
        :type             => 'sms',
        :address          => '0123456789',
        :interval         => 300,
        :rollup_threshold => 5
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with one medium").
        with(:method => :post, :path => '/contacts/abc/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:media => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['abc_sms'] )

      result = Flapjack::Diner.create_contact_media('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['abc_sms'])
    end

    it "submits a POST request for several media" do
      data = [{
        :type             => 'sms',
        :address          => '0123456789',
        :interval         => 300,
        :rollup_threshold => 5
      }, {
        :type             => 'email',
        :address          => 'ablated@example.org',
        :interval         => 180,
        :rollup_threshold => 3
      }]

      flapjack.given("a contact with id 'abc' exists").
        upon_receiving("a POST request with two media").
        with(:method => :post, :path => '/contacts/abc/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:media => data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => ['abc_sms', 'abc_email'] )

      result = Flapjack::Diner.create_contact_media('abc', data)
      expect(result).not_to be_nil
      expect(result).to eq(['abc_sms', 'abc_email'])
    end

    it "can't find the contact to create a medium for" do
      data = [{
        :type             => 'sms',
        :address          => '0123456789',
        :interval         => 300,
        :rollup_threshold => 5
      }]

      flapjack.given("no contact exists").
        upon_receiving("a POST request with one medium").
        with(:method => :post, :path => '/contacts/abc/media',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:media => data}).
        will_respond_with(
          :status => 422,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["Contact id: 'abc' could not be loaded"]} )

      result = Flapjack::Diner.create_contact_media('abc', data)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 422,
        :errors => ["Contact id: 'abc' could not be loaded"])
    end

  end

  context 'read' do

    let(:sms_data) {
      {
        :type             => 'sms',
        :address          => '0123456789',
        :interval         => 300,
        :rollup_threshold => 5
      }
    }

    let(:email_data) {
      {
        :type             => 'email',
        :address          => 'ablated@example.org',
        :interval         => 180,
        :rollup_threshold => 3
      }
    }

    let(:links) { {:links => {:contacts => ['abc']}} }

    it "submits a GET request for all media" do
      media_data = [email_data.merge(links), sms_data.merge(links)]

      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a GET request for all media").
        with(:method => :get, :path => '/media').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media
      expect(result).to eq(media_data)
    end

    it "submits a GET request for one medium" do
      media_data = [sms_data.merge(links)]

      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a GET request for sms media").
        with(:method => :get, :path => '/media/abc_sms').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media('abc_sms')
      expect(result).to eq(media_data)
    end

    it "submits a GET request for several media" do
      media_data = [email_data.merge(links), sms_data.merge(links)]

      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a GET request for email and sms media").
        with(:method => :get, :path => '/media/abc_email,abc_sms').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:media => media_data} )

      result = Flapjack::Diner.media('abc_email', 'abc_sms')
      expect(result).to eq(media_data)
    end

    it "can't find the contact with media to read" do
      flapjack.given("no contact exists").
        upon_receiving("a GET request for sms media").
        with(:method => :get, :path => '/media/abc_sms').
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.media('abc_sms')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

  context 'update' do

    it "submits a PATCH request for one medium" do
      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a PATCH request for email media").
        with(:method => :patch,
             :path => '/media/abc_email',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                       {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media('abc_email', :interval => 50, :rollup_threshold => 3)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several media" do
      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a PATCH request for email and sms media").
        with(:method => :patch,
             :path => '/media/abc_email,abc_sms',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                       {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}]).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_media('abc_email', 'abc_sms', :interval => 50, :rollup_threshold => 3)
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the contact with media to update" do
      flapjack.given("no contact exists").
        upon_receiving("a PATCH request for email media").
        with(:method => :patch,
             :path => '/media/abc_email',
             :headers => {'Content-Type'=>'application/json-patch+json'},
             :body => [{:op => 'replace', :path => '/media/0/interval', :value => 50}]).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.update_media('abc_email', :interval => 50)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

  context 'delete' do
    it "submits a DELETE request for one medium" do

      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a DELETE request for one medium").
        with(:method => :delete,
             :path => '/media/abc_email',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_media('abc_email')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several media" do
      flapjack.given("a contact with id 'abc' has email and sms media").
        upon_receiving("a DELETE request for two media").
        with(:method => :delete,
             :path => '/media/abc_email,abc_sms',
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_media('abc_email', 'abc_sms')
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "can't find the contact with media to delete" do
      flapjack.given("no contact exists").
        upon_receiving("a DELETE request for one medium").
        with(:method => :delete,
             :path => '/media/abc_email',
             :body => nil).
        will_respond_with(:status => 404,
                          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
                          :body => {:errors => ["could not find contact 'abc'"]} )

      result = Flapjack::Diner.delete_media('abc_email')
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find contact 'abc'"])
    end

  end

end
