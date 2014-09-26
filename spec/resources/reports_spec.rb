require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Reports, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = false
  end

  let(:linked_check) { {
    :entity => ['1234'],
    :check  => ['www.example.com:SSH']
  } }

  let(:linked_check_2) { {
    :entity => ['5678'],
    :check  => ['www2.example.com:PING']
  } }

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

      it "submits a GET request for a #{report_type} report on all entities" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for a #{report_type} report on all entities").
          with(:method => :get, :path => "/#{report_type}_report/entities").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym)
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on one entity" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for a #{report_type} report on one entity").
          with(:method => :get, :path => "/#{report_type}_report/entities/1234").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '1234')
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on several entities" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a GET request for a #{report_type} report on two entities").
          with(:method => :get, :path => "/#{report_type}_report/entities/1234,5678").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '1234', '5678')
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_report/checks").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym)
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on one check" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_report/checks/www.example.com:SSH").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym, 'www.example.com:SSH')
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on several checks" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_report/checks/www.example.com:SSH,www2.example.com:PING").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym, 'www.example.com:SSH', 'www2.example.com:PING')
        expect(result).to eq(data)
      end

    end

    ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      let(:start_time) { Time.now }
      let(:end_time)   { start_time + (60 * 60 * 12) }

      let(:esc_st) { URI.encode_www_form_component(start_time.iso8601) }
      let(:esc_et) { URI.encode_www_form_component(end_time.iso8601) }

      it "submits a time-limited GET request for a #{report_type} report on all entities" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on all entities").
          with(:method => :get,
               :path => "/#{report_type}_report/entities",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on one entity" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on one entity").
          with(:method => :get,
               :path => "/#{report_type}_report/entities/1234",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '1234',
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on several entities" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a time limited GET request for a #{report_type} report on two entities").
          with(:method => :get,
               :path => "/#{report_type}_report/entities/1234,5678",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '1234', '5678',
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_report/checks",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on one check" do
        data = [report_data(report_type, linked_check)]

        flapjack.given("a check 'www.example.com:SSH' exists").
          upon_receiving("a time limited GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_report/checks/www.example.com:SSH",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym, 'www.example.com:SSH',
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on several checks" do
        data = [report_data(report_type, linked_check),
                report_data(report_type, linked_check_2)]

        flapjack.given("checks 'www.example.com:SSH' and 'www2.example.com:PING' exist").
          upon_receiving("a time-limited GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_report/checks/www.example.com:SSH,www2.example.com:PING",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {"#{report_type}_reports".to_sym => data} )

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym, 'www.example.com:SSH', 'www2.example.com:PING',
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

    end

  end

end
