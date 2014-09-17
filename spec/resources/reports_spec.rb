require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }

  let(:time) { Time.now }

  def response_with_data(name, data = [])
    "{\"#{name}\":#{data.to_json}}"
  end

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
    Flapjack::Diner.return_keys_as_strings = true
  end

  after(:each) do
    WebMock.reset!
  end
  context 'read' do

    ['status', 'scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      it "submits a GET request for a #{report_type} report on all entities" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for a #{report_type} report on one entity" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for a #{report_type} report on several entities" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72,150").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for a #{report_type} report on all checks" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for a #{report_type} report on one check" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com%3ASSH").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          'example.com:SSH')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for a #{report_type} report on several checks" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com%3ASSH,example2.com%3APING").
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          'example.com:SSH', 'example2.com:PING')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

    end

    ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

      let(:start_time) { Time.now }
      let(:end_time)   { start_time + (60 * 60 * 12) }

      it "submits a time-limited GET request for a #{report_type} report on all entities" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a time-limited GET request for a #{report_type} report on one entity" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
          '72', :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a time-limited GET request for a #{report_type} report on several entities" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72,150").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
          '72', '150', :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a time-limited GET request for a #{report_type} report on all checks" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a time-limited GET request for a #{report_type} report on one check" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com%3ASSH").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          'example.com:SSH', :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a time-limited GET request for a #{report_type} report on several checks" do
        req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com%3ASSH,example2.com%3APING").
          with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
          to_return(:body => response_with_data("#{report_type}_reports"))

        result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
          'example.com:SSH', 'example2.com:PING',
          :start_time => start_time, :end_time => end_time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

    end

  end

end
