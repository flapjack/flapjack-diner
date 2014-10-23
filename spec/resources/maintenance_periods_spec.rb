require 'spec_helper'
require 'flapjack_diner'

describe Flapjack::Diner::Resources::MaintenancePeriods, :pact => true do

  let(:time) { Time.now }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'entities' do

    context 'create' do

      context 'scheduled maintenance periods' do

        it "submits a POST request on an entity" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("an entity 'www.example.com' with id '1234' exists").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_entities('1234', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several entities" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/entities/1234,5678',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_entities('1234', '5678', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on an entity" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]

          flapjack.given("an entity 'www.example.com' with id '1234' exists").
            upon_receiving("a POST request with two scheduled maintenance periods").
            with(:method => :post, :path => '/scheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_entities('1234', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several entities" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]

          flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
            upon_receiving("a POST request with two scheduled maintenance periods").
            with(:method => :post, :path => '/scheduled_maintenances/entities/1234,5678',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_entities('1234', '5678', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "can't find the entity to create scheduled maintenance for" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("no entity exists").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 404,
              :body => {:errors => ["could not find entity '1234'"]})

          result = Flapjack::Diner.create_scheduled_maintenances_entities('1234', data)
          expect(result).to be_nil
          expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
            :errors => ["could not find entity '1234'"])
        end

      end

      context 'unscheduled maintenance periods' do

        it "submits a POST request on an entity" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("an entity 'www.example.com' with id '1234' exists").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_entities('1234', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several entities" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/entities/1234,5678',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_entities('1234', '5678', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on an entity" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]

          flapjack.given("an entity 'www.example.com' with id '1234' exists").
            upon_receiving("a POST request with two unscheduled maintenance periods").
            with(:method => :post, :path => '/unscheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_entities('1234', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several entities" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]

          flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
            upon_receiving("a POST request with two unscheduled maintenance periods").
            with(:method => :post, :path => '/unscheduled_maintenances/entities/1234,5678',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_entities('1234', '5678', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "can't find the entity to create unscheduled maintenance for" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("no entity exists").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/entities/1234',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 404,
              :body => {:errors => ["could not find entity '1234'"]})

          result = Flapjack::Diner.create_unscheduled_maintenances_entities('1234', data)
          expect(result).to be_nil
          expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
            :errors => ["could not find entity '1234'"])

        end

      end

    end

    context 'update' do

      it "submits a PATCH request for unscheduled maintenances on an entity" do
        flapjack.given("an entity 'www.example.com' with id '1234' exists").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/entities/1234',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.update_unscheduled_maintenances_entities('1234', :end_time => time)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for unscheduled maintenances on several entities" do
        flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/entities/1234,5678',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.update_unscheduled_maintenances_entities('1234', '5678', :end_time => time)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "can't find the entity to update maintenance for" do
        flapjack.given("no entity exists").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/entities/1234',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity '1234'"]})

        result = Flapjack::Diner.update_unscheduled_maintenances_entities('1234', :end_time => time)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entity '1234'"])
      end

    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on an entity" do
        flapjack.given("an entity 'www.example.com' with id '1234' exists").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/entities/1234',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('1234', :start_time => time.iso8601)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for scheduled maintenances on several entities" do
        flapjack.given("entities 'www.example.com', id '1234' and 'www2.example.com', id '5678' exist").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/entities/1234,5678',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('1234', '5678', :start_time => time.iso8601)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "can't find the entity to delete maintenance for" do
        flapjack.given("no entity exists").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/entities/1234',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity '1234'"]})

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('1234', :start_time => time.iso8601)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entity '1234'"])
      end

    end

  end

  context 'checks' do

    context 'create' do

      context 'scheduled maintenance periods' do

        it "submits a POST request on a check" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several checks" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on a check" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with two scheduled maintenance periods").
            with(:method => :post, :path => '/scheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several checks" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with two scheduled maintenance periods").
            with(:method => :post, :path => '/scheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_scheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "can't find the check to create scheduled maintenance for" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]

          flapjack.given("no check exists").
            upon_receiving("a POST request with one scheduled maintenance period").
            with(:method => :post, :path => '/scheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:scheduled_maintenances => data}).
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity 'www.example.com'"]})

          result = Flapjack::Diner.create_scheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).to be_nil
          expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
            :errors => ["could not find entity 'www.example.com'"])
        end

      end

      context 'unscheduled maintenance periods' do

        it "submits a POST request on a check" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several checks" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on a check" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]

          flapjack.given("a check 'www.example.com:SSH' exists").
            upon_receiving("a POST request with two unscheduled maintenance periods").
            with(:method => :post, :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several checks" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]

          flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
            upon_receiving("a POST request with two unscheduled maintenance periods").
            with(:method => :post, :path => '/unscheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
            will_respond_with(
              :status => 204,
              :body => '')

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', data)
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "can't find the check to create unscheduled maintenance for" do
          data = [{:duration => 3600, :summary => 'working'}]

          flapjack.given("no check exists").
            upon_receiving("a POST request with one unscheduled maintenance period").
            with(:method => :post, :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
                 :headers => {'Content-Type' => 'application/vnd.api+json'},
                 :body => {:unscheduled_maintenances => data}).
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity 'www.example.com'"]})

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('www.example.com:SSH', data)
          expect(result).to be_nil
          expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
            :errors => ["could not find entity 'www.example.com'"])
        end

      end

    end

    context 'update' do

      it "submits a PATCH request for unscheduled maintenances on a check" do
        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', :end_time => time)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for unscheduled maintenances on several checks" do
        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', :end_time => time)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "can't find the check to update maintenance for" do
        flapjack.given("no check exists").
          upon_receiving("a PATCH request for an unscheduled maintenance period").
          with(:method => :patch,
               :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
               :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity 'www.example.com'"]})

        result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', :end_time => time)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entity 'www.example.com'"])
      end

    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on a check" do
        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/checks/www.example.com:SSH',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('www.example.com:SSH', :start_time => time.iso8601)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for scheduled maintenances on several checks" do
        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 204,
            :body => '')

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', :start_time => time.iso8601)
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "can't find the check to delete maintenance for" do
        flapjack.given("no check exists").
          upon_receiving("a DELETE request for a scheduled maintenance period").
          with(:method => :delete,
               :path => '/scheduled_maintenances/checks/www.example.com:SSH',
               :query => "start_time=#{URI.encode_www_form_component(time.iso8601)}").
          will_respond_with(
            :status => 404,
            :body => {:errors => ["could not find entity 'www.example.com'"]})

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('www.example.com:SSH', :start_time => time.iso8601)
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
          :errors => ["could not find entity 'www.example.com'"])
      end

    end
  end

end
