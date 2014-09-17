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

  context 'entities' do

    context 'create' do

      context 'scheduled maintenance periods' do

        it "submits a POST request on an entity" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/entities/72").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_entities(72, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several entities" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/entities/72,150").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on an entity" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/entities/72").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_entities(72, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several entities" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/entities/72,150").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

      context 'unscheduled maintenance periods' do

        it "submits a POST request on an entity" do
          data = [{:duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/entities/72").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_entities(72, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several entities" do
          data = [{:duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/entities/72,150").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several entities" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/entities/72,150").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

    context 'update' do

      it "submits a PATCH request for unscheduled maintenances on an entity" do
        req = stub_request(:patch, "http://#{server}/unscheduled_maintenances/entities/72").
          with(:body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_unscheduled_maintenances_entities('72', :end_time => time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for unscheduled maintenances on several entities" do
        req = stub_request(:patch, "http://#{server}/unscheduled_maintenances/entities/72,150").
          with(:body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_unscheduled_maintenances_entities('72', '150', :end_time => time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on an entity" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/entities/72").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('72', :start_time => time.iso8601)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for scheduled maintenances on several entities" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/entities/72,150").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('72', '150', :start_time => time.iso8601)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

  end

  context 'checks' do
    context 'create' do

      context 'scheduled maintenance periods' do

        it "submits a POST request on a check" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_checks('example.com:SSH', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several checks" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on a check" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_checks('example.com:SSH', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several checks" do
          data = [{:start_time => time.iso8601, :duration => 3600, :summary => 'working'},
                  {:start_time => (time + 7200).iso8601, :duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:scheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_scheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

      context 'unscheduled maintenance periods' do

        it "submits a POST request on a check" do
          data = [{:duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/checks/example.com%3ASSH").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('example.com:SSH', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request on several checks" do
          data = [{:duration => 3600, :summary => 'working'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple periods on several checks" do
          data = [{:duration => 3600, :summary => 'working'},
                  {:duration => 3600, :summary => 'more work'}]
          req = stub_request(:post, "http://#{server}/unscheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:unscheduled_maintenances => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_unscheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

    context 'update' do

      it "submits a PATCH request for unscheduled maintenances on a check" do
        req = stub_request(:patch, "http://#{server}/unscheduled_maintenances/checks/example.com%3ASSH").
          with(:body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_unscheduled_maintenances_checks('example.com:SSH', :end_time => time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for unscheduled maintenances on several checks" do
        req = stub_request(:patch, "http://#{server}/unscheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
          with(:body => [{:op => 'replace', :path => '/unscheduled_maintenances/0/end_time', :value => time.iso8601}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_unscheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', :end_time => time)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on a check" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => time.iso8601)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for scheduled maintenances on a check with spaces in the name, percent-encoded" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com%3ADisk%20C%3A%20Utilisation").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:Disk C: Utilisation', :start_time => time.iso8601)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for scheduled maintenances on several checks" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH,example2.com%3APING").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', :start_time => time.iso8601)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end
  end


end
