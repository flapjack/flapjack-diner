require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Notifications, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'checks' do
    context 'create' do

      context 'test notifications' do

        it "submits a POST request for a check" do
          data = [{:summary => 'testing'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with one test notification").
            with(:method => :post, :path => '/test_notifications/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:test_notifications => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_test_notifications_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for several checks" do
          data = [{:summary => 'testing'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with one test notification").
            with(:method => :post, :path => '/test_notifications/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:test_notifications => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_test_notifications_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on a check" do
          data = [{:summary => 'testing'},
                  {:summary => 'more tests'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with two test notifications").
            with(:method => :post, :path => '/test_notifications/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:test_notifications => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_test_notifications_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on several checks" do
          data = [{:summary => 'testing'},
                  {:summary => 'more tests'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with two test notifications").
            with(:method => :post, :path => '/test_notifications/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:test_notifications => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_test_notifications_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "can't find the check to create notifications for" do
          data = [{:summary => 'testing'}]

          flapjack.given("no check exists").
            upon_receiving("a POST request with one test notification").
            with(:method => :post, :path => '/test_notifications/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:test_notifications => data}).
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find Check records, ids: 'www.example.com:SSH'"]})

          result = Flapjack::Diner.create_test_notifications_checks('www.example.com:SSH', data)
          expect(result).to be_nil
          expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
            :errors => ["could not find Check records, ids: 'www.example.com:SSH'"])
        end

      end

    end

  end

end
