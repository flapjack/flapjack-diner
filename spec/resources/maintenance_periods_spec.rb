require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::MaintenancePeriods, :pact => true do

  include_context 'fixture data'

  let(:time) { Time.now }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  # TODO need tests for linkage to checks, deletion/ending from checks

  context 'create' do

    context 'scheduled maintenance periods' do

      it "creates a scheduled maintenance period" do
        data = []

        flapjack.given("no scheduled maintenance period exists").
          upon_receiving("a POST request with one scheduled maintenance period").
          with(:method => :post, :path => '/scheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:scheduled_maintenances => scheduled_maintenance_data}).
          will_respond_with(
            :status => 201,
            :body => {'scheduled_maintenances' => scheduled_maintenance_data})

        result = Flapjack::Diner.create_scheduled_maintenances(scheduled_maintenance_data)
        expect(result).not_to be_nil
        expect(result).to eq(scheduled_maintenance_data)
      end

      it "creates several scheduled maintenance periods" do
        scheduled_maintenances_data = [scheduled_maintenance_data,
                                       scheduled_maintenance_2_data]
        flapjack.given("no scheduled maintenance period exists").
          upon_receiving("a POST request with two scheduled maintenance periods").
          with(:method => :post, :path => '/scheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:scheduled_maintenances => scheduled_maintenances_data}).
          will_respond_with(
            :status => 201,
            :body => {'scheduled_maintenances' => scheduled_maintenances_data})

        result = Flapjack::Diner.create_scheduled_maintenances(scheduled_maintenances_data)
        expect(result).not_to be_nil
        expect(result).to eq(scheduled_maintenances_data)
      end

    end

    context 'unscheduled maintenance periods' do

      it "creates an unscheduled maintenance period" do
        data = []

        flapjack.given("no unscheduled maintenance period exists").
          upon_receiving("a POST request with one unscheduled maintenance period").
          with(:method => :post, :path => '/unscheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:unscheduled_maintenances => unscheduled_maintenance_data}).
          will_respond_with(
            :status => 201,
            :body => {'unscheduled_maintenances' => unscheduled_maintenance_data})

        result = Flapjack::Diner.create_unscheduled_maintenances(unscheduled_maintenance_data)
        expect(result).not_to be_nil
        expect(result).to eq(unscheduled_maintenance_data)
      end

      it "creates several unscheduled maintenance periods" do
        unscheduled_maintenances_data = [unscheduled_maintenance_data,
                                         unscheduled_maintenance_2_data]
        flapjack.given("no unscheduled maintenance period exists").
          upon_receiving("a POST request with two unscheduled maintenance periods").
          with(:method => :post, :path => '/unscheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:unscheduled_maintenances => unscheduled_maintenances_data}).
          will_respond_with(
            :status => 201,
            :body => {'unscheduled_maintenances' => unscheduled_maintenances_data})

        result = Flapjack::Diner.create_unscheduled_maintenances(unscheduled_maintenances_data)
        expect(result).not_to be_nil
        expect(result).to eq(unscheduled_maintenances_data)
      end

    end

  end

  # context 'update' do

  #   it "submits a PATCH request for unscheduled maintenances on a check" do
  #     flapjack.given("a check 'www.example.com:SSH' exists").
  #       upon_receiving("a PATCH request for an unscheduled maintenance period").
  #       with(:method => :patch,
  #            :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
  #            :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
  #            :headers => {'Content-Type'=>'application/json-patch+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '')

  #     result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', :end_time => time)
  #     expect(result).not_to be_nil
  #     expect(result).to be_truthy
  #   end

  #   it "submits a PATCH request for unscheduled maintenances on several checks" do
  #     flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
  #       upon_receiving("a PATCH request for an unscheduled maintenance period").
  #       with(:method => :patch,
  #            :path => '/unscheduled_maintenances/checks/www.example.com:SSH,www2.example.com:PING',
  #            :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
  #            :headers => {'Content-Type'=>'application/json-patch+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '')

  #     result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', 'www2.example.com:PING', :end_time => time)
  #     expect(result).not_to be_nil
  #     expect(result).to be_truthy
  #   end

  #   it "can't find the check to update maintenance for" do
  #     flapjack.given("no check exists").
  #       upon_receiving("a PATCH request for an unscheduled maintenance period").
  #       with(:method => :patch,
  #            :path => '/unscheduled_maintenances/checks/www.example.com:SSH',
  #            :body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}],
  #            :headers => {'Content-Type'=>'application/json-patch+json'}).
  #       will_respond_with(
  #         :status => 404,
  #         :body => {:errors => ["could not find Check records, ids: 'www.example.com:SSH'"]})

  #     result = Flapjack::Diner.update_unscheduled_maintenances_checks('www.example.com:SSH', :end_time => time)
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
  #       :errors => ["could not find Check records, ids: 'www.example.com:SSH'"])
  #   end

  # end

  context 'delete' do

    it "submits a DELETE request for a scheduled maintenance period" do
      flapjack.given("a scheduled maintenance period with id '#{scheduled_maintenance_data[:id]}' exists").
        upon_receiving("a DELETE request for a scheduled maintenance period").
        with(:method => :delete,
             :path => "/scheduled_maintenances/#{scheduled_maintenance_data[:id]}").
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several scheduled maintenance periods" do
      flapjack.given("scheduled maintenance periods with ids '#{scheduled_maintenance_data[:id]}' and '#{scheduled_maintenance_2_data[:id]}' exist").
        upon_receiving("a DELETE request for a scheduled maintenance period").
        with(:method => :delete,
             :path => "/scheduled_maintenances/#{scheduled_maintenance_data[:id]},#{scheduled_maintenance_2_data[:id]}").
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id], scheduled_maintenance_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the scheduled maintenance period to delete" do
      flapjack.given("no scheduled maintenance period exists").
        upon_receiving("a DELETE request for a single scheduled maintenance period").
        with(:method => :delete,
             :path => "/scheduled_maintenances/#{scheduled_maintenance_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => ["could not find ScheduledMaintenance records, ids: '#{scheduled_maintenance_data[:id]}'"]}
        )

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq(:status_code => 404,
        :errors => ["could not find ScheduledMaintenance records, ids: '#{scheduled_maintenance_data[:id]}'"])

    end

  end

end
