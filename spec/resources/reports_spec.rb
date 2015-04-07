require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Reports, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  let(:meta) {
    {
      :pagination => {
        :page        => 1,
        :per_page    => 20,
        :total_pages => 1,
        :total_count => 1
      }
    }
  }

  # let(:linked_check) {
  #   {
  #     :check  => check_data[:id]
  #   }
  # }

  # let(:linked_check_2) {
  #   {
  #     :check  => check_2_data[:id]
  #   }
  # }

  def report_data(report_type, check)
    case report_type
    when 'status'
      {
        :name                              => check[:name],
        :type                              => 'status_report',
        :condition                         => nil,
        :enabled                           => true,
        :summary                           => nil,
        :details                           => nil,
        :in_unscheduled_maintenance        => false,
        :in_scheduled_maintenance          => false,
        :initial_failure_delay             => nil,
        :repeat_failure_delay              => nil,
        :last_update                       => nil,
        :last_change                       => nil,
        :last_problem_notification         => nil,
        :last_recovery_notification        => nil,
        :last_acknowledgement_notification => nil
      }
    when 'downtime'
      {:total_seconds => {},
       :percentages   => {},
       :downtime      => [],
       :type          => 'downtime_report',
     }
    else
      {
        :type    => "#{report_type}_report",
        "#{report_type}s".to_sym => []
      }
    end
  end

  context 'read' do

    ['status', 'scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      it "submits a GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, check_data)]

        flapjack.given("a check exists").
          upon_receiving("a GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => data, :meta => meta,
                      :links => {:self => "http://example.org/#{report_type}_reports/checks"}}
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym)
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on one check" do
        data = report_data(report_type, check_data)

        flapjack.given("a check exists").
          upon_receiving("a GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => data, :links => {:self => "http://example.org/#{report_type}_reports/checks/#{check_data[:id]}"}}
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym, check_data[:id])
        expect(result).to eq(data)
      end

      it "submits a GET request for a #{report_type} report on several checks" # do
      #   data = [report_data(report_type, check_data),
      #           report_data(report_type, check_2_data)]

      #   flapjack.given("a tag with two checks exists").
      #     upon_receiving("a GET request for a #{report_type} report on a tag with two checks").
      #     with(:method => :get,
      #          :path => "/#{report_type}_reports/tags/#{tag_data[:name]}").
      #     will_respond_with(
      #       :status => 200,
      #       :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
      #       :body => {:data => data, :links => {}, :meta => meta})

      #   result = Flapjack::Diner.send("#{report_type}_reports_tags".to_sym, tag_data[:name])
      #   expect(result).to eq(data)
      # end

    end

    ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      let(:start_time) { Time.now }
      let(:end_time)   { start_time + (60 * 60 * 12) }

      let(:esc_st) { URI.encode_www_form_component(start_time.iso8601) }
      let(:esc_et) { URI.encode_www_form_component(end_time.iso8601) }

      it "submits a time-limited GET request for a #{report_type} report on all checks" do
        data = [report_data(report_type, check_data)]

        flapjack.given("a check exists").
          upon_receiving("a time limited GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => data, :links => {}, :meta => meta})

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(data)
      end

      it "submits a time-limited GET request for a #{report_type} report on one check" # do
      #   data = report_data(report_type, check_data)

      #   flapjack.given("a check exists").
      #     upon_receiving("a time limited GET request for a #{report_type} report on a single check").
      #     with(:method => :get,
      #          :path => "/#{report_type}_reports/checks/#{check_data[:id]}",
      #          :query => "start_time=#{esc_st}&end_time=#{esc_et}").
      #     will_respond_with(
      #       :status => 200,
      #       :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
      #       :body => {:data => data} )

      #   result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
      #     check_data[:id], :start_time => start_time, :end_time => end_time)
      #   expect(result).to eq(data)
      # end

      it "submits a time-limited GET request for a #{report_type} report on several checks" # do
      #   data = [report_data(report_type, linked_check),
      #           report_data(report_type, linked_check_2)]

      #   flapjack.given("two checks exist").
      #     upon_receiving("a time-limited GET request for a #{report_type} report on two checks").
      #     with(:method => :get,
      #          :path => "/#{report_type}_reports/#{check_data[:id]},#{check_2_data[:id]}",
      #          :query => "start_time=#{esc_st}&end_time=#{esc_et}").
      #     will_respond_with(
      #       :status => 200,
      #       :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
      #       :body => {:data => data, :links => {}, :meta => meta})

      #   result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
      #     check_data[:id], check_2_data[:id],
      #     :start_time => start_time, :end_time => end_time)
      #   expect(result).to eq(data)
      # end

    end

  end

end
