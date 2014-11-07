require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Reports, :pact => true do

  include_context 'fixture data'

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  let(:linked_check) {
    {
      :check  => check_data[:id]
    }
  }

  let(:linked_check_2) {
    {
      :check  => check_2_data[:id]
    }
  }

  def report_data(report_type, links = {})
    case report_type
    when 'status'
      {} # generic matcher for hash including anything
    when 'downtime'
      {} # generic matcher for hash including anything
    else
      {"#{report_type}s".to_sym => [], :links => links}
    end
  end

  context 'read' do

    ['status', 'scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      it "submits a GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check with id '#{check_data[:id]}' exists").
          upon_receiving("a GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_reports").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym)
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on one check" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check with id '#{check_data[:id]}' exists").
          upon_receiving("a GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym, check_data[:id])
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on several checks" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks with ids '#{check_data[:id]}' and '#{check_2_data[:id]}' exist").
          upon_receiving("a GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/#{check_data[:id]},#{check_2_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym, check_data[:id], check_2_data[:id])
        expect(result).to eq(data)
      end

    end

    ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      let(:start_time) { Time.now }
      let(:end_time)   { start_time + (60 * 60 * 12) }

      let(:esc_st) { URI.encode_www_form_component(start_time.iso8601) }
      let(:esc_et) { URI.encode_www_form_component(end_time.iso8601) }

      it "submits a time-limited GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check with id '#{check_data[:id]}' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_reports",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on one check" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check with id '#{check_data[:id]}' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/#{check_data[:id]}",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym,
          check_data[:id], :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on several checks" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks with ids '#{check_data[:id]}' and '#{check_2_data[:id]}' exist").
          upon_receiving("a time-limited GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/#{check_data[:id]},#{check_2_data[:id]}",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_reports".to_sym,
          check_data[:id], check_2_data[:id],
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

    end

  end

end
