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

    it "submits a POST request for a medium" do
      data = [{
        :type             => 'sms',
        :address          => '0123456789',
        :interval         => 300,
        :rollup_threshold => 5
      }]

      req = stub_request(:post, "http://#{server}/contacts/1/media").
        with(:body => {:media => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('media', data))

      result = Flapjack::Diner.create_contact_media(1, data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
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

      req = stub_request(:post, "http://#{server}/contacts/1/media").
        with(:body => {:media => data}.to_json,
             :headers => {'Content-Type'=>'application/vnd.api+json'}).
        to_return(:status => 201, :body => response_with_data('media', data))

      result = Flapjack::Diner.create_contact_media(1, data)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'read' do
   it "submits a GET request for all media" do
      req = stub_request(:get, "http://#{server}/media").
        to_return(:body => response_with_data('media'))

      result = Flapjack::Diner.media
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for one medium" do
      req = stub_request(:get, "http://#{server}/media/72_sms").
        to_return(:body => response_with_data('media'))

      result = Flapjack::Diner.media('72_sms')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "submits a GET request for several media" do
      req = stub_request(:get, "http://#{server}/media/72_sms,150_email").
        to_return(:body => response_with_data('media'))

      result = Flapjack::Diner.media('72_sms', '150_email')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end
  end

  context 'update' do

    it "submits a PATCH request for one medium" do
      req = stub_request(:patch, "http://#{server}/media/23_email").
        with(:body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                       {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_media('23_email', :interval => 50, :rollup_threshold => 3)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a PATCH request for several media" do
      req = stub_request(:patch, "http://#{server}/media/23_email,87_sms").
        with(:body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                       {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}].to_json,
             :headers => {'Content-Type'=>'application/json-patch+json'}).
        to_return(:status => 204)

      result = Flapjack::Diner.update_media('23_email', '87_sms', :interval => 50, :rollup_threshold => 3)
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

  end

  context 'delete' do
    it "submits a DELETE request for one medium" do
      req = stub_request(:delete, "http://#{server}/media/72_sms").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_media('72_sms')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end

    it "submits a DELETE request for several media" do
      req = stub_request(:delete, "http://#{server}/media/72_sms,150_email").
        to_return(:status => 204)

      result = Flapjack::Diner.delete_media('72_sms', '150_email')
      expect(req).to have_been_requested
      expect(result).not_to be_nil
      expect(result).to be_truthy
    end
  end

end
