require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    context 'test notifications' do

      it "submits a POST request for a check" do
        req_data  = test_notification_json(test_notification_data).merge(
          :relationships => {
            :check => {
              :data => {:type => 'check', :id => check_data[:id]}
            }
          }
        )
        resp_data = test_notification_json(test_notification_data)

        flapjack.given("a check exists").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => req_data}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.create_test_notifications(test_notification_data.merge(:check => check_data[:id]))
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "submits a POST request for checks linked to a tag" do
        req_data  = test_notification_json(test_notification_data).merge(
          :relationships => {
            :tag => {
              :data => {:type => 'tag', :id => tag_data[:id]}
            }
          }
        )
        resp_data = test_notification_json(test_notification_data)

        flapjack.given("a tag exists").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => req_data}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.create_test_notifications(test_notification_data.merge(:tag => tag_data[:id]))
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "submits a POST request for multiple notifications on a check" do
        req_data  = [
          test_notification_json(test_notification_data).merge(
            :relationships => {
              :check => {
                :data => {:type => 'check', :id => check_data[:id]}
              }
            }
          ),
          test_notification_json(test_notification_2_data).merge(
            :relationships => {
              :check => {
                :data => {:type => 'check', :id => check_data[:id]}
              }
            }
          )
        ]
        resp_data = [
          test_notification_json(test_notification_data),
          test_notification_json(test_notification_2_data)
        ]

        flapjack.given("a check exists").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
               :body => {:data => req_data}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.create_test_notifications(
          test_notification_data.merge(:check => check_data[:id]),
          test_notification_2_data.merge(:check => check_data[:id])
        )
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "submits a POST request for multiple notifications for checks linked to a tag" do
        req_data  = [
          test_notification_json(test_notification_data).merge(
            :relationships => {
              :tag => {
                :data => {:type => 'tag', :id => tag_data[:id]}
              }
            }
          ),
          test_notification_json(test_notification_2_data).merge(
            :relationships => {
              :tag => {
                :data => {:type => 'tag', :id => tag_data[:id]}
              }
            }
          )
        ]

        resp_data = [
          test_notification_json(test_notification_data),
          test_notification_json(test_notification_2_data)
        ]

        flapjack.given("a tag exists").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
               :body => {:data => req_data}).
          will_respond_with(
            :status => 201,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.create_test_notifications(
          test_notification_data.merge(:tag => tag_data[:id]),
          test_notification_2_data.merge(:tag => tag_data[:id])
        )
        expect(result).not_to be_nil
        expect(result).to eq(resultify(resp_data))
      end

      it "can't find the check to create notifications for" do
        req_data  = test_notification_json(test_notification_data).merge(
          :relationships => {
            :check => {
              :data => {:type => 'check', :id => check_data[:id]}
            }
          }
        )

        flapjack.given("no data exists").
          upon_receiving("a POST request with one test notification for a check").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => req_data}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Check record, id: '#{check_data[:id]}'"
            }]}
          )

        result = Flapjack::Diner.create_test_notifications(test_notification_data.merge(:check => check_data[:id]))
        expect(result).to be_nil
        expect(Flapjack::Diner.error).to eq([{:status => '404',
          :detail => "could not find Check record, id: '#{check_data[:id]}'"}])
      end

      it "can't find the tag to create notifications for" do
        req_data  = test_notification_json(test_notification_data).merge(
          :relationships => {
            :tag => {
              :data => {:type => 'tag', :id => tag_data[:id]}
            }
          }
        )

        flapjack.given("no data exists").
          upon_receiving("a POST request with one test notification for a tag").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => req_data}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Tag record, id: '#{tag_data[:id]}'"
            }]}
          )

        result = Flapjack::Diner.create_test_notifications(test_notification_data.merge(:tag => tag_data[:id]))
        expect(result).to be_nil
        expect(Flapjack::Diner.error).to eq([{:status => '404',
          :detail => "could not find Tag record, id: '#{tag_data[:id]}'"}])
      end

    end

  end

end
