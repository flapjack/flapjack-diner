require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'read' do
    it 'gets all statistics' do
      resp_data = [global_statistics_json]
      resp_data.first[:attributes][:created_at] = Pact::Term.new(
        :generate => global_statistics_data[:created_at],
        :matcher  => /\A#{ISO8601_PAT}\z/
      )

      flapjack.given("a global statistics object exists").
        upon_receiving("a GET request for all statistics").
        with(:method => :get, :path => '/statistics').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.statistics
      expect(result).to eq(resultify([global_statistics_json]))
    end

    it 'gets global statistics' do
      resp_data = [global_statistics_json]

      resp_data.first[:attributes][:created_at] = Pact::Term.new(
        :generate => global_statistics_data[:created_at],
        :matcher  => /\A#{ISO8601_PAT}\z/
      )

      flapjack.given("a global statistics object exists").
        upon_receiving("a GET request for some statistics").
        with(:method => :get, :path => '/statistics',
             :query  => 'filter%5B%5D=instance_name%3Aglobal').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.statistics(:filter => {:instance_name => global_statistics_data[:instance_name]})
      expect(result).to eq(resultify([global_statistics_json]))
    end
  end

end
