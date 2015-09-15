require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'read' do
    it 'gets all metrics' do
      resp_data = metrics_json(metrics_data)

      flapjack.given("no data exists").
        upon_receiving("a GET request for all metrics").
        with(:method => :get, :path => '/metrics').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data} )

      result = Flapjack::Diner.metrics
      expect(result).to eq(resultify(resp_data))
    end

    it 'gets a subset of metrics' do
      resp_data = metrics_json(metrics_data)
      resp_data[:attributes].delete_if {|k,v| ![:processed_events, :total_keys].include?(k)}

      flapjack.given("no data exists").
        upon_receiving("a GET request for some metrics").
        with(:method => :get, :path => '/metrics',
             :query  => 'fields%5B%5D=total_keys&fields%5B%5D=processed_events').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data} )

      result = Flapjack::Diner.metrics(:fields => ['total_keys', 'processed_events'])
      expect(result).to eq(resultify(resp_data))
    end
  end

end
