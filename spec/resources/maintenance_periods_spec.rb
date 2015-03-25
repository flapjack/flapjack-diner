require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::MaintenancePeriods, :pact => true do

  let(:time) { Time.now }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  # TODO need tests for linkage to checks, deletion/ending from checks

  context 'create' do

    context 'scheduled maintenance periods' do

      it "creates a scheduled maintenance period" do
        flapjack.given("no scheduled maintenance period exists").
          upon_receiving("a POST request with one scheduled maintenance period").
          with(:method => :post, :path => '/scheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => {:scheduled_maintenances => scheduled_maintenance_data.merge(:type => 'scheduled_maintenance')}}).
          will_respond_with(
            :status => 201,
            :body => {'data' => {'scheduled_maintenances' => scheduled_maintenance_data.merge('type' => 'scheduled_maintenance')}})

        result = Flapjack::Diner.create_scheduled_maintenances(scheduled_maintenance_data)
        expect(result).not_to be_nil
        expect(result).to eq(scheduled_maintenance_data.merge(:type => 'scheduled_maintenance'))
      end

      it "creates several scheduled maintenance periods" do
        scheduled_maintenances_data = [scheduled_maintenance_data.merge(:type => 'scheduled_maintenance'),
                                       scheduled_maintenance_2_data.merge(:type => 'scheduled_maintenance')]
        flapjack.given("no scheduled maintenance period exists").
          upon_receiving("a POST request with two scheduled maintenance periods").
          with(:method => :post, :path => '/scheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => {:scheduled_maintenances => scheduled_maintenances_data}}).
          will_respond_with(
            :status => 201,
            :body => {'data' => {'scheduled_maintenances' => scheduled_maintenances_data}})

        result = Flapjack::Diner.create_scheduled_maintenances(*scheduled_maintenances_data)
        expect(result).not_to be_nil
        expect(result).to eq(scheduled_maintenances_data)
      end

    end

    context 'unscheduled maintenance periods' do

      it "creates an unscheduled maintenance period" do
        flapjack.given("no unscheduled maintenance period exists").
          upon_receiving("a POST request with one unscheduled maintenance period").
          with(:method => :post, :path => '/unscheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => {:unscheduled_maintenances => unscheduled_maintenance_data.merge(:type => 'unscheduled_maintenance')}}).
          will_respond_with(
            :status => 201,
            :body => {'data' => {'unscheduled_maintenances' => unscheduled_maintenance_data.merge('type' => 'unscheduled_maintenance')}})

        result = Flapjack::Diner.create_unscheduled_maintenances(unscheduled_maintenance_data)
        expect(result).not_to be_nil
        expect(result).to eq(unscheduled_maintenance_data.merge(:type => 'unscheduled_maintenance'))
      end

      it "creates several unscheduled maintenance periods" do
        unscheduled_maintenances_data = [unscheduled_maintenance_data.merge(:type => 'unscheduled_maintenance'),
                                         unscheduled_maintenance_2_data.merge(:type => 'unscheduled_maintenance')]
        flapjack.given("no unscheduled maintenance period exists").
          upon_receiving("a POST request with two unscheduled maintenance periods").
          with(:method => :post, :path => '/unscheduled_maintenances',
               :headers => {'Content-Type' => 'application/vnd.api+json'},
               :body => {:data => {:unscheduled_maintenances => unscheduled_maintenances_data}}).
          will_respond_with(
            :status => 201,
            :body => {'data' => {'unscheduled_maintenances' => unscheduled_maintenances_data}})

        result = Flapjack::Diner.create_unscheduled_maintenances(unscheduled_maintenance_data,
                                                                 unscheduled_maintenance_2_data)
        expect(result).not_to be_nil
        expect(result).to eq(unscheduled_maintenances_data)
      end

    end

  end

  context 'update' do

    before do
      skip "broken"
    end

    it 'submits a PUT request for an unscheduled maintenance period' do
      flapjack.given("an unscheduled maintenance period exists").
        upon_receiving("a PUT request for a single unscheduled maintenance period").
        with(:method => :put,
             :path => "/unscheduled_maintenances/#{unscheduled_maintenance_data[:id]}",
             :body => {:unscheduled_maintenances => {:id => unscheduled_maintenance_data[:id], :end_time => time.iso8601}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_unscheduled_maintenances(:id => unscheduled_maintenance_data[:id], :end_time => time)
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PUT request for several unscheduled maintenance periods' do
      flapjack.given("two unscheduled maintenance periods exist").
        upon_receiving("a PUT request for two unscheduled maintenance periods").
        with(:method => :put,
             :path => "/unscheduled_maintenances/#{unscheduled_maintenance_data[:id]},#{unscheduled_maintenance_2_data[:id]}",
             :body => {:unscheduled_maintenances => [{:id => unscheduled_maintenance_data[:id], :end_time => time.iso8601},
             {:id => unscheduled_maintenance_2_data[:id], :end_time => (time + 3600).iso8601}]},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_unscheduled_maintenances(
        {:id => unscheduled_maintenance_data[:id], :end_time => time},
        {:id => unscheduled_maintenance_2_data[:id], :end_time => time + 3600})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the unscheduled maintenance period to update" do
      flapjack.given("no unscheduled maintenance period exists").
        upon_receiving("a PUT request for a single unscheduled maintenance period").
        with(:method => :put,
             :path => "/unscheduled_maintenances/#{unscheduled_maintenance_data[:id]}",
             :body => {:unscheduled_maintenances => {:id => unscheduled_maintenance_data[:id], :end_time => time.iso8601}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find UnscheduledMaintenance records, ids: '#{unscheduled_maintenance_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.update_unscheduled_maintenances(:id => unscheduled_maintenance_data[:id], :end_time => time)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find UnscheduledMaintenance records, ids: '#{unscheduled_maintenance_data[:id]}'"}])
    end

  end

  context 'delete' do

    it "submits a DELETE request for a scheduled maintenance period" do
      flapjack.given("a scheduled maintenance period exists").
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
      scheduled_maintenances_data = [
        {:type => 'scheduled_maintenance', :id => scheduled_maintenance_data[:id]},
        {:type => 'scheduled_maintenance', :id => scheduled_maintenance_2_data[:id]}
      ]

      flapjack.given("two scheduled maintenance periods exist").
        upon_receiving("a DELETE request for two scheduled maintenance periods").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :path => "/scheduled_maintenances",
             :body => {:data => scheduled_maintenances_data}).
        will_respond_with(
          :status => 204,
          :body => '')

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id], scheduled_maintenance_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the scheduled maintenance period to delete" do
      flapjack.given("no scheduled maintenance period exists").
        upon_receiving("a DELETE request for a scheduled maintenance period").
        with(:method => :delete,
             :path => "/scheduled_maintenances/#{scheduled_maintenance_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find ScheduledMaintenance record, id: '#{scheduled_maintenance_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_scheduled_maintenances(scheduled_maintenance_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find ScheduledMaintenance record, id: '#{scheduled_maintenance_data[:id]}'"}])
    end

  end

end
