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
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:test_notifications => notification_data.merge(:links => {:checks => [check_data[:id]]})}).
          will_respond_with(
            :status => 201,
            :body => {:test_notifications => notification_data.merge(:links => {:checks => [check_data[:id]]})})

        result = Flapjack::Diner.create_test_notifications(notification_data.merge(:links => {:checks => [check_data[:id]]}))
        expect(result).not_to be_nil
        expect(result).to eq(notification_data.merge(:links => {:checks => [check_data[:id]]}))
      end

      it "submits a POST request for several checks" do
        flapjack.given("two checks exist").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:test_notifications => notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})}).
          will_respond_with(
            :status => 201,
            :body => {:test_notifications => notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})})

        result = Flapjack::Diner.create_test_notifications(notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}))
        expect(result).not_to be_nil
        expect(result).to eq(notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}))
      end

      it "submits a POST request for multiple notifications on a check" do

        flapjack.given("a check exists").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:test_notifications => [notification_data.merge(:links => {:checks => [check_data[:id]]}),
                 notification_2_data.merge(:links => {:checks => [check_data[:id]]})]}).
          will_respond_with(
            :status => 201,
            :body => {:test_notifications => [notification_data.merge(:links => {:checks => [check_data[:id]]}),
              notification_2_data.merge(:links => {:checks => [check_data[:id]]})]})

        result = Flapjack::Diner.create_test_notifications(notification_data.merge(:links => {:checks => [check_data[:id]]}),
          notification_2_data.merge(:links => {:checks => [check_data[:id]]}))
        expect(result).not_to be_nil
        expect(result).to eq([notification_data.merge(:links => {:checks => [check_data[:id]]}),
          notification_2_data.merge(:links => {:checks => [check_data[:id]]})])
      end

      it "submits a POST request for multiple notifications on several checks" do
        flapjack.given("two checks exist").
          upon_receiving("a POST request with two test notifications").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:test_notifications => [
                 notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}),
                 notification_2_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})
               ]}).
          will_respond_with(
            :status => 201,
            :body => {:test_notifications => [
                notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}),
                notification_2_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})
              ]})

        result = Flapjack::Diner.create_test_notifications(
          notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}),
          notification_2_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})
        )
        expect(result).not_to be_nil
        expect(result).to eq([
          notification_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]}),
          notification_2_data.merge(:links => {:checks => [check_data[:id], check_2_data[:id]]})
        ])
      end

      it "can't find the check to create notifications for" do
        flapjack.given("no check exists").
          upon_receiving("a POST request with one test notification").
          with(:method => :post, :path => "/test_notifications",
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:test_notifications => notification_data.merge(:links => {:checks => [check_data[:id]]})}).
        will_respond_with(
          :status => 404,
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Check records, ids: '#{check_data[:id]}'"
            }]}
          )

        result = Flapjack::Diner.create_test_notifications(notification_data.merge(:links => {:checks => [check_data[:id]]}))
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq([{:status => '404',
          :detail => "could not find Check records, ids: '#{check_data[:id]}'"}])
      end

    end

  end

end
