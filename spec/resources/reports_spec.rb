require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Reports, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'read' do

    let(:start_time) { Time.now }
    let(:end_time)   { start_time + (60 * 60 * 12) }

    let(:esc_st) { URI.encode_www_form_component(start_time.iso8601) }
    let(:esc_et) { URI.encode_www_form_component(end_time.iso8601) }

    def report_data(opts = {})
      rt = opts[:report_type]

      meta = {}
      meta.update(:pagination => {
        :page        => 1,
        :per_page    => 20,
        :total_pages => 1,
        :total_count => opts[:paginate]
      }) if opts[:paginate]

      meta.update(:statistics => {}) if 'downtime'.eql?(rt)

      rd = {}

      if opts[:paginate]
        rd[:data] = opts[:paginate].times.collect do |n|
          {:type => "#{rt}_report", :attributes => {rt.to_sym => []}}
        end
        if 'downtime'.eql?(rt)
          opts[:paginate].times.each do |n|
            meta[:statistics][[check_data, check_2_data][n][:id]] = {
              :total_seconds => {}, :percentages => {}
            }
          end
        end
      else
        rd[:data] = {:type => "#{rt}_report", :attributes => {rt.to_sym => []}}
        if 'downtime'.eql?(rt)
          meta[:statistics][check_data[:id]] = {
            :total_seconds => {}, :percentages => {}
          }
        end
      end
      rd[:meta] = meta unless meta.empty?
      rd
    end

    ['downtime', 'outage'].each do |report_type|

      it "submits a GET request for a #{report_type} report on all checks" do
        report = report_data(:paginate => 1, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks"}
                 )

        flapjack.given("a check exists").
          upon_receiving("a GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym)
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a GET request for a #{report_type} report on one check" do
        report = report_data(:report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks/#{check_data[:id]}"}
                 )

        flapjack.given("a check exists").
          upon_receiving("a GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym, check_data[:id])
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a GET request for a #{report_type} report on several checks" do
        report = report_data(:paginate => 2, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks?filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}"}
                 )

        flapjack.given("two checks exist").
          upon_receiving("a GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks",
               :query => "filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym, check_data[:id], check_2_data[:id])
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a GET request for a #{report_type} report on a tag" do
        report = report_data(:paginate => 1, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/tags/#{tag_data[:name]}"}
                 )

        flapjack.given("a check with a tag exists").
          upon_receiving("a GET request for a #{report_type} report on a single tag").
          with(:method => :get,
               :path => "/#{report_type}_reports/tags/#{tag_data[:name]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_tags".to_sym, tag_data[:name])
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a time-limited GET request for a #{report_type} report on all checks" do
        report = report_data(:paginate => 1, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks?end_time=#{esc_et}&start_time=#{esc_st}"}
                 )
        flapjack.given("a check exists").
          upon_receiving("a time limited GET request for a #{report_type} report on all checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a time-limited GET request for a #{report_type} report on one check" do
        report = report_data(:report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks/#{check_data[:id]}?end_time=#{esc_et}&start_time=#{esc_st}"}
                 )

        flapjack.given("a check exists").
          upon_receiving("a time limited GET request for a #{report_type} report on a single check").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks/#{check_data[:id]}",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
          check_data[:id], :start_time => start_time, :end_time => end_time)
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a time-limited GET request for a #{report_type} report on several checks" do
        report = report_data(:paginate => 2, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/checks?end_time=#{esc_et}&filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}&start_time=#{esc_st}"}
                 )
        flapjack.given("two checks exist").
          upon_receiving("a time-limited GET request for a #{report_type} report on two checks").
          with(:method => :get,
               :path => "/#{report_type}_reports/checks",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}&filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_checks".to_sym,
          check_data[:id], check_2_data[:id],
          :start_time => start_time, :end_time => end_time)
        expect(result).to eq(resultify(report[:data]))
      end

      it "submits a time-limited GET request for a #{report_type} report on a tag" do
        report = report_data(:paginate => 1, :report_type => report_type).merge(
                   :links => {:self => "http://example.org/#{report_type}_reports/tags/#{tag_data[:name]}?end_time=#{esc_et}&start_time=#{esc_st}"}
                 )

        flapjack.given("a check with a tag exists").
          upon_receiving("a time limited GET request for a #{report_type} report on a single tag").
          with(:method => :get,
               :path => "/#{report_type}_reports/tags/#{tag_data[:name]}",
               :query => "start_time=#{esc_st}&end_time=#{esc_et}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => report
          )

        result = Flapjack::Diner.send("#{report_type}_reports_tags".to_sym,
          tag_data[:name], :start_time => start_time, :end_time => end_time)
        expect(result).to eq(resultify(report[:data]))
      end

    end
  end
end
