require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Metrics, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'read' do
    it 'gets all metrics' do
      metrics_data = {
        :total_keys         => 0,
        :processed_events   => {
          :all_events     => 0,
          :ok_events      => 0,
          :failure_events => 0,
          :action_events  => 0,
          :invalid_events => 0
        },
        :event_queue_length => 0,
        :check_freshness    => {:"0" => 0, :"60" => 0, :"300" => 0, :"900" => 0, :"3600" => 0},
        :check_counts       => {:all => 0, :failing => 0}
      }

      flapjack.given("no data exists").
        upon_receiving("a GET request for all metrics").
        with(:method => :get, :path => '/metrics').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => metrics_data} )

      result = Flapjack::Diner.metrics
      expect(result).to eq(metrics_data)
    end

    it 'gets a subset of metrics' do
      metrics_data = {
        :total_keys         => 0,
        :processed_events   => {
          :all_events     => 0,
          :ok_events      => 0,
          :failure_events => 0,
          :action_events  => 0,
          :invalid_events => 0
        }
      }

      flapjack.given("no data exists").
        upon_receiving("a GET request for some metrics").
        with(:method => :get, :path => '/metrics',
             :query  => 'fields%5B%5D=total_keys&fields%5B%5D=processed_events').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => metrics_data} )

      result = Flapjack::Diner.metrics(:fields => ['total_keys', 'processed_events'])
      expect(result).to eq(metrics_data)
    end
  end

end
