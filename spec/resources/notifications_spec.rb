require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Notifications, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    context 'test notifications' do

      it "submits a POST request for a check" do
        flapjack.given("a check exists").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications/checks/#{check_data[:id]}",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => notification_data.merge(:type => 'test_notification')}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => notification_data.merge(:type => 'test_notification')})

        result = Flapjack::Diner.create_test_notifications_checks(check_data[:id], notification_data)
        expect(result).not_to be_nil
        expect(result).to eq(notification_data.merge(:type => 'test_notification'))
      end

      it "submits a POST request for checks linked to a tag" do
        flapjack.given("a tag with two checks exists").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications/tags/#{tag_data[:name]}",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => notification_data.merge(:type => 'test_notification')}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => notification_data.merge(:type => 'test_notification')})

        result = Flapjack::Diner.create_test_notifications_tags(tag_data[:name], notification_data)
        expect(result).not_to be_nil
        expect(result).to eq(notification_data.merge(:type => 'test_notification'))
      end

      it "submits a POST request for multiple notifications on a check" do
        flapjack.given("a check exists").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications/checks/#{check_data[:id]}",
               :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
               :body => {:data => [notification_data.merge(:type => 'test_notification'),
                                   notification_2_data.merge(:type => 'test_notification')]}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => [notification_data.merge(:type => 'test_notification'),
                                notification_2_data.merge(:type => 'test_notification')]})

        result = Flapjack::Diner.create_test_notifications_checks(check_data[:id], notification_data, notification_2_data)
        expect(result).not_to be_nil
        expect(result).to eq([notification_data.merge(:type => 'test_notification'),
                              notification_2_data.merge(:type => 'test_notification')])
      end

      it "submits a POST request for multiple notifications for checks linked to a tag" do
        flapjack.given("a tag with two checks exists").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications/tags/#{tag_data[:name]}",
               :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
               :body => {:data => [notification_data.merge(:type => 'test_notification'),
                                   notification_2_data.merge(:type => 'test_notification')]}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => [notification_data.merge(:type => 'test_notification'),
                                notification_2_data.merge(:type => 'test_notification')]})

        result = Flapjack::Diner.create_test_notifications_tags(tag_data[:name], notification_data, notification_2_data)
        expect(result).not_to be_nil
        expect(result).to eq([notification_data.merge(:type => 'test_notification'),
                              notification_2_data.merge(:type => 'test_notification')])
      end

      it "can't find the check to create notifications for" do
        flapjack.given("no data exists").
          upon_receiving("a POST request with one test notification for a check").
          with(:method => :post, :path => "/test_notifications/checks/#{check_data[:id]}",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => notification_data.merge(:type => 'test_notification')}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Check record, id: '#{check_data[:id]}'"
            }]}
          )

        result = Flapjack::Diner.create_test_notifications_checks(check_data[:id], notification_data)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq([{:status => '404',
          :detail => "could not find Check record, id: '#{check_data[:id]}'"}])
      end

      it "can't find the tag to create notifications for" do
        flapjack.given("no data exists").
          upon_receiving("a POST request with one test notification for a tag").
          with(:method => :post, :path => "/test_notifications/tags/#{tag_data[:name]}",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => notification_data.merge(:type => 'test_notification')}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Tag record, id: '#{tag_data[:name]}'"
            }]}
          )

        result = Flapjack::Diner.create_test_notifications_tags(tag_data[:name], notification_data)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq([{:status => '404',
          :detail => "could not find Tag record, id: '#{tag_data[:name]}'"}])
      end

    end

  end

end
