require 'spec_helper'
require 'flapjack-diner'
require 'flapjack-diner/index_range'

describe Flapjack::Diner::Resources, :pact => true do

  let(:time) { Time.now }

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'get' do

    it 'gets a single state' do
      resp_data   = state_json(state_data).merge(:relationships => state_rel(state_data))
      result_data = resultify(state_json(state_data).merge(:relationships => state_rel(state_data)))

      [:created_at, :updated_at].each do |t|
        resp_data[:attributes][t] = Pact::Term.new(
          :generate => state_data[t],
          :matcher  => /\A#{ISO8601_PAT}\z/
        )
      end

      flapjack.given("a state exists").
        upon_receiving("a GET request for a single state").
        with(:method => :get,
             :path => "/states/#{state_data[:id]}").
        will_respond_with(
          :status => 200,
          :body => {:data => resp_data})

      result = Flapjack::Diner.states(state_data[:id])
      expect(result).to eq(result_data)
    end

    it 'gets all states' do
      resp_data   = [state_json(state_data).merge(:relationships => state_rel(state_data))]
      result_data = resultify([state_json(state_data).merge(:relationships => state_rel(state_data))])

      [:created_at, :updated_at].each do |t|
        resp_data.first[:attributes][t] = Pact::Term.new(
          :generate => state_data[t],
          :matcher  => /\A#{ISO8601_PAT}\z/
        )
      end

      flapjack.given("a state exists").
        upon_receiving("a GET request for all states").
        with(:method => :get,
             :path => "/states").
        will_respond_with(
          :status => 200,
          :body => {:data => resp_data})

      result = Flapjack::Diner.states
      expect(result).to eq(result_data)
    end

    # pact won't pass if run later than a closed date range (or in a time earlier
    # than what's provided, but that's less of a concern assuming clocks are sane)
    it 'gets all states in a date range unbounded on upper side' do
      resp_data   = [state_json(state_data).merge(:relationships => state_rel(state_data))]
      result_data = resultify([state_json(state_data).merge(:relationships => state_rel(state_data))])

      [:created_at, :updated_at].each do |t|
        resp_data.first[:attributes][t] = Pact::Term.new(
          :generate => state_data[t],
          :matcher  => /\A#{ISO8601_PAT}\z/
        )
      end

      st = fixture_time - 60

      flapjack.given("a state exists").
        upon_receiving("a GET request for all states within a date range").
        with(:method => :get,
             :path => '/states',
             :query => "filter%5B%5D=created_at%3A#{CGI::escape(st.iso8601)}..").
        will_respond_with(
          :status => 200,
          :body => {:data => resp_data})

      filt = {:created_at => Flapjack::Diner::IndexRange.new(st, nil)}
      result = Flapjack::Diner.states(:filter => filt)
      expect(result).to eq(result_data)
    end

  end

end
