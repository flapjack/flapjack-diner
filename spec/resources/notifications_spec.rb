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

  context 'entities' do

    context 'create' do

      context 'test notifications' do

        it "submits a POST request for an entity" do
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, [:summary => 'testing'])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for several entities" do
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72,150").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, 150, [:summary => 'testing'])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on an entity" do
          data = [{:summary => 'testing'}, {:summary => 'another test'}]
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on several entities" do
          data = [{:summary => 'testing'}, {:summary => 'another test'}]
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72,150").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

  end

  context 'checks' do
    context 'create' do

      context 'test notifications' do

        it "submits a POST request for a check" do
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', [{:summary => 'testing'}])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for several checks" do
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH,example2.com%3APING").
            with(:test_notifications => [{:summary => 'testing'}]).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', 'example2.com:PING', [{:summary => 'testing'}])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on a check" do
          data = [{:summary => 'testing'}, {:summary => 'more testing'}]
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on several checks" do
          data = [{:summary => 'testing'}, {:summary => 'more testing'}]
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

  end

end
