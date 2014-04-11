require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner do

  let(:server) { 'flapjack.com' }

  let(:time) { Time.now }

  # let(:entity) { 'ex-abcd-data-17.example.com' }
  # let(:check)  { 'ping'}

  # let(:rule_data) {
  #   {"contact_id"         => "21",
  #    "entity_tags"        => ["database","physical"],
  #    "entities"           => ["foo-app-01.example.com"],
  #    "time_restrictions"  => nil,
  #    "warning_media"      => ["email"],
  #    "critical_media"     => ["sms", "email"],
  #    "warning_blackhole"  => false,
  #    "critical_blackhole" => false
  #   }
  # }

  let(:response)      { '{"key":"value"}' }
  let(:response_body) { {'key' => 'value'} }

  before(:each) do
    Flapjack::Diner.base_uri(server)
    Flapjack::Diner.logger = nil
  end

  after(:each) do
    WebMock.reset!
  end

  context 'contacts' do
    context 'create' do
    end

    context 'read' do
      it "submits a GET request for all contacts" do
        req = stub_request(:get, "http://#{server}/contacts").to_return(
          :body => response)

        result = Flapjack::Diner.contacts
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for one contact" do
        req = stub_request(:get, "http://#{server}/contacts/72").to_return(
          :body => response)

        result = Flapjack::Diner.contacts('72')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for several contacts" do
        req = stub_request(:get, "http://#{server}/contacts/72,150").to_return(
          :body => response)

        result = Flapjack::Diner.contacts('72', '150')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end
    end

    context 'update' do
    end

    context 'delete' do
      it "submits a DELETE request for one contact" do
        req = stub_request(:delete, "http://#{server}/contacts/72").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_contacts('72')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for several contacts" do
        req = stub_request(:delete, "http://#{server}/contacts/72,150").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_contacts('72', '150')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end
    end
  end

  context 'media' do
    context 'create' do
    end

    context 'read' do
     it "submits a GET request for all media" do
        req = stub_request(:get, "http://#{server}/media").to_return(
          :body => response)

        result = Flapjack::Diner.media
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for one medium" do
        req = stub_request(:get, "http://#{server}/media/72_sms").to_return(
          :body => response)

        result = Flapjack::Diner.media('72_sms')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for several media" do
        req = stub_request(:get, "http://#{server}/media/72_sms,150_email").to_return(
          :body => response)

        result = Flapjack::Diner.media('72_sms', '150_email')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end
    end

    context 'update' do
    end

    context 'delete' do
      it "submits a DELETE request for one medium" do
        req = stub_request(:delete, "http://#{server}/media/72_sms").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_media('72_sms')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for several media" do
        req = stub_request(:delete, "http://#{server}/media/72_sms,150_email").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_media('72_sms', '150_email')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end
    end
  end

  context 'notification rules' do
    context 'create' do
    end

    context 'read' do
     it "submits a GET request for all notification rules" do
        req = stub_request(:get, "http://#{server}/notification_rules").to_return(
          :body => response)

        result = Flapjack::Diner.notification_rules
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for one notification rule" do
        req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").to_return(
          :body => response)

        result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for several media" do
        req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").to_return(
          :body => response)

        result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end
    end

    context 'update' do
    end

    context 'delete' do
      it "submits a DELETE request for a notification rule" do

        req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for several notification rules" do
        req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end
    end
  end

  context 'entities' do

    context 'create' do

      it "submits a POST request for creation of a test notification on an entity" do
        req = stub_request(:post, "http://#{server}/test_notifications/entities/72").
          with(:summary => 'testing').
          to_return(:status => 204)

        result = Flapjack::Diner.create_test_notifications_entities(72, :summary => 'testing')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a POST request for creation of test notifications on several entities" do
        req = stub_request(:post, "http://#{server}/test_notifications/entities/72,150").
          with(:summary => 'testing').
          to_return(:status => 204)

        result = Flapjack::Diner.create_test_notifications_entities(72, 150, :summary => 'testing')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

    end

    context 'read' do
      it "submits a GET request for all entities" do
        req = stub_request(:get, "http://#{server}/entities").
          to_return(:body => response)

        result = Flapjack::Diner.entities
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for one entity" do
        req = stub_request(:get, "http://#{server}/entities/72").
          to_return(:body => response)

        result = Flapjack::Diner.entities('72')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end

      it "submits a GET request for several entities" do
        req = stub_request(:get, "http://#{server}/entities/72,150").to_return(
          :body => response)

        result = Flapjack::Diner.entities('72', '150')
        req.should have_been_requested
        result.should_not be_nil
        result.should == response_body
      end
    end

    context 'update' do

    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on an entity" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/entities/72").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('72', :start_time => time.iso8601)
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for scheduled maintenances on several entities" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/entities/72,150").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_entities('72', '150', :start_time => time.iso8601)
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for unscheduled maintenances on an entity" do
        req = stub_request(:delete, "http://#{server}/unscheduled_maintenances/entities/72").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_unscheduled_maintenances_entities('72')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for unscheduled maintenances on several entities" do
        req = stub_request(:delete, "http://#{server}/unscheduled_maintenances/entities/72,150").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_unscheduled_maintenances_entities('72', '150')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end
    end

  end

  context 'checks' do
    context 'create' do

      it "submits a POST request for creation of a test notification on a check" do
        req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com:SSH").
          with(:summary => 'testing').
          to_return(:status => 204)

        result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', :summary => 'testing')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a POST request for creation of test notifications on several checks" do
        req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com:SSH,example2.com:PING").
          with(:summary => 'testing').
          to_return(:status => 204)

        result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', 'example2.com:PING', :summary => 'testing')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

    end

    context 'read' do
    end

    context 'update' do
    end

    context 'delete' do

      it "submits a DELETE request for scheduled maintenances on a check" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com:SSH").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => time.iso8601)
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for scheduled maintenances on several checks" do
        req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com:SSH,example2.com:PING").
          with(:query => {:start_time => time.iso8601}).
          to_return(:status => 204)

        result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', 'example2.com:PING', :start_time => time.iso8601)
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for unscheduled maintenances on a check" do
        req = stub_request(:delete, "http://#{server}/unscheduled_maintenances/checks/example.com:SSH").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_unscheduled_maintenances_checks('example.com:SSH')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

      it "submits a DELETE request for unscheduled maintenances on several checks" do
        req = stub_request(:delete, "http://#{server}/unscheduled_maintenances/checks/example.com:SSH,example2.com:PING").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_unscheduled_maintenances_checks('example.com:SSH', 'example2.com:PING')
        req.should have_been_requested
        result.should_not be_nil
        result.should be_true
      end

    end
  end

  context 'reports' do
    context 'read' do

      ['status', 'scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

        it "submits a GET request for a #{report_type} report on all entities" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a GET request for a #{report_type} report on one entity" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '72')
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a GET request for a #{report_type} report on several entities" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72,150").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym, '72', '150')
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a GET request for a #{report_type} report on all checks" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a GET request for a #{report_type} report on one check" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com:SSH").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
            'example.com:SSH')
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a GET request for a #{report_type} report on several checks" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com:SSH,example2.com:PING").to_return(
            :body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
            'example.com:SSH', 'example2.com:PING')
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

      end

      ['scheduled_maintenance', 'unscheduled_maintenance', 'downtime', 'outage'].each do |report_type|

        let(:start_time) { Time.now }
        let(:end_time)   { start_time + (60 * 60 * 12) }

        it "submits a time-limited GET request for a #{report_type} report on all entities" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
            :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a time-limited GET request for a #{report_type} report on one entity" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
            '72', :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a time-limited GET request for a #{report_type} report on several entities" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/entities/72,150").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_entities".to_sym,
            '72', '150', :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a time-limited GET request for a #{report_type} report on all checks" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
            :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a time-limited GET request for a #{report_type} report on one check" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com:SSH").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
            'example.com:SSH', :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

        it "submits a time-limited GET request for a #{report_type} report on several checks" do
          req = stub_request(:get, "http://#{server}/#{report_type}_report/checks/example.com:SSH,example2.com:PING").
            with(:query => {:start_time => start_time.iso8601, :end_time => end_time.iso8601}).
            to_return(:body => response)

          result = Flapjack::Diner.send("#{report_type}_report_checks".to_sym,
            'example.com:SSH', 'example2.com:PING',
            :start_time => start_time, :end_time => end_time)
          req.should have_been_requested
          result.should_not be_nil
          result.should == response_body
        end

      end

    end
  end

  # it "returns a json list of entities from a non-standard port" do
  #   Flapjack::Diner.base_uri('flapjack.com:54321')

  #   req = stub_request(:get, "http://#{server}:54321/entities").to_return(
  #     :body => response)

  #   result = Flapjack::Diner.entities
  #   req.should have_been_requested
  #   result.should_not be_nil
  #   result.should == response_body
  # end

  # it "acknowledges a check's state for an entity" do
  #   req = stub_request(:post, "http://#{server}/acknowledgements").with(
  #     :body => {:check => {entity => check}, :summary => 'dealing with it'}).to_return(
  #     :status => 204)

  #   result = Flapjack::Diner.acknowledge!(entity, check, :summary => 'dealing with it')
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "acknowledges all checks on an entity" do
  #   req = stub_request(:post, "http://#{server}/acknowledgements").with(
  #     :body => {:entity => entity, :summary => 'dealing with it'}.to_json,
  #               :headers => {'Content-Type' => 'application/vnd.api+json'}).to_return(
  #     :status => 204)

  #   result = Flapjack::Diner.bulk_acknowledge!(:entity => entity, :summary => 'dealing with it')
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "acknowledges checks from multiple entities" do
  #   req = stub_request(:post, "http://#{server}/acknowledgements").with(
  #     :body => {:entity => [entity, 'lmn.net'], :summary => 'dealing with it'}.to_json,
  #               :headers => {'Content-Type' => 'application/vnd.api+json'}).to_return(
  #     :status => 204)

  #   result = Flapjack::Diner.bulk_acknowledge!(:entity => [entity, 'lmn.net'], :summary => 'dealing with it')
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "creates a scheduled maintenance period for an entity" do
  #   start_time = Time.now
  #   duration = 60 * 30 # in seconds, so 30 minutes
  #   summary = "fixing everything"

  #   req = stub_request(:post, "http://#{server}/scheduled_maintenances").
  #           with(:body => {:check => {entity => check}, :start_time => start_time.iso8601,
  #                          :duration => duration, :summary => summary},
  #                :headers => {'Content-Type' => 'application/vnd.api+json'}).to_return(
  #           :status => 204)

  #   result = Flapjack::Diner.create_scheduled_maintenance!(entity, check,
  #     :start_time => start_time, :duration => duration, :summary => summary)
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "creates scheduled maintenance periods for all checks on an entity" do
  #   start_time = Time.now
  #   duration = 60 * 30 # in seconds, so 30 minutes
  #   summary = "fixing everything"

  #   req = stub_request(:post, "http://#{server}/scheduled_maintenances").
  #           with(:body => {:entity => entity, :start_time => start_time.iso8601,
  #                          :duration => duration, :summary => summary},
  #                :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #           to_return(:status => 204)

  #   result = Flapjack::Diner.bulk_create_scheduled_maintenance!(:entity => entity,
  #     :start_time => start_time, :duration => duration, :summary => summary)
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "creates scheduled maintenance periods for checks from multiple entities" do
  #   start_time = Time.now
  #   duration = 60 * 30 # in seconds, so 30 minutes
  #   summary = "fixing everything"

  #   req = stub_request(:post, "http://#{server}/scheduled_maintenances").
  #           with(:body => {:check => {entity => 'ping', 'pqr.org' => 'ssh'}, :start_time => start_time.iso8601,
  #                          :duration => duration, :summary => summary},
  #                :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #           to_return(:status => 204)

  #   result = Flapjack::Diner.bulk_create_scheduled_maintenance!(:check => {entity => 'ping', 'pqr.org' => 'ssh'},
  #     :start_time => start_time, :duration => duration, :summary => summary)
  #   req.should have_been_requested
  #   result.should be_true
  # end

  # it "creates a notification rule" do
  #   rule_result = rule_data.merge('id' => '00001')

  #   req = stub_request(:post, "http://#{server}/notification_rules").
  #           with(:body => {'notification_rules'=>[rule_data]}.to_json,
  #                :headers => {'Content-Type'=>'application/vnd.api+json'}).
  #           to_return(:body => rule_result.to_json)

  #   result = Flapjack::Diner.create_notification_rule!(rule_data)
  #   req.should have_been_requested
  #   result.should == rule_result
  # end

  # it "updates a notification rule" do
  #   rule_id = '00001'

  #   rule_data_with_id = rule_data.merge('id' => rule_id)

  #   req = stub_request(:put, "http://#{server}/notification_rules/#{rule_id}").
  #           with(:body => {'notification_rules' => [rule_data_with_id]}.to_json,
  #                :headers => {'Content-Type'=>'application/vnd.api+json'}).
  #           to_return(:body => rule_data_with_id.to_json)

  #   result = Flapjack::Diner.update_notification_rule!(rule_id, rule_data_with_id)
  #   req.should have_been_requested
  #   result.should == rule_data_with_id
  # end

  # it "updates a contact's notification medium" do
  #   contact_id = '21'
  #   media_type = 'sms'
  #   media_data = {"address" => "dmitri@example.com",
  #                 "interval" => 900}

  #   req = stub_request(:put, "http://#{server}/contacts/#{contact_id}/media/#{media_type}").with(
  #     :body => media_data).to_return(:body => media_data.to_json)

  #   result = Flapjack::Diner.update_contact_medium!(contact_id, media_type, media_data)
  #   req.should have_been_requested
  #   result.should == media_data
  # end

  # context "logging" do

  #   let(:logger) { mock('logger') }

  #   before do
  #     Flapjack::Diner.logger = logger
  #   end

  #   it "logs a GET request without a path" do
  #     req = stub_request(:get, "http://#{server}/entities").to_return(
  #       :body => response)

  #     logger.should_receive(:info).with("GET http://#{server}/entities")
  #     logger.should_receive(:info).with("  Response Code: 200")
  #     logger.should_receive(:info).with("  Response Body: #{response}")

  #     result = Flapjack::Diner.entities
  #     req.should have_been_requested
  #     result.should_not be_nil
  #     result.should == response_body
  #   end

  #   it "logs a GET request with a path" do
  #     req = stub_request(:get, "http://#{server}/checks/#{entity}").to_return(
  #       :body => response)

  #     logger.should_receive(:info).with("GET http://#{server}/checks/#{entity}")
  #     logger.should_receive(:info).with("  Response Code: 200")
  #     logger.should_receive(:info).with("  Response Body: #{response}")

  #     result = Flapjack::Diner.checks(entity)
  #     req.should have_been_requested
  #     result.should_not be_nil
  #     result.should == response_body
  #   end

  #   it "logs a POST request" do
  #     req = stub_request(:post, "http://#{server}/acknowledgements").
  #             with(:body => {:check => {entity => check}, :summary => 'dealing with it'},
  #                  :headers => {'Content-Type'=>'application/json'}).
  #             to_return(:status => 204)
  #     logger.should_receive(:info).with("POST http://#{server}/acknowledgements\n" +
  #       "  Params: {:summary=>\"dealing with it\", :check=>{\"ex-abcd-data-17.example.com\"=>\"ping\"}}")
  #     logger.should_receive(:info).with("  Response Code: 204")

  #     result = Flapjack::Diner.acknowledge!(entity, check, :summary => 'dealing with it')
  #     req.should have_been_requested
  #     result.should be_true
  #   end

  #   it "logs a JSON put request" do
  #     contact_id = '21'
  #     timezone_data = {:timezone => "Australia/Perth"}

  #     req = stub_request(:put, "http://#{server}/contacts/#{contact_id}/timezone").with(
  #       :body => timezone_data).to_return(:body => timezone_data.to_json, :status => [200, 'OK'])

  #     logger.should_receive(:info).
  #       with("PUT http://#{server}/contacts/#{contact_id}/timezone\n  Params: #{timezone_data.inspect}")
  #     logger.should_receive(:info).with("  Response Code: 200 OK")
  #     logger.should_receive(:info).with("  Response Body: #{timezone_data.to_json}")

  #     result = Flapjack::Diner.update_contact_timezone!(contact_id, timezone_data[:timezone])
  #     req.should have_been_requested
  #     result.should == {'timezone' => "Australia/Perth"}
  #   end

  #   it "logs a DELETE request" do
  #     contact_id = '21'
  #     req = stub_request(:delete, "http://#{server}/contacts/#{contact_id}/timezone").to_return(
  #       :status => 204)

  #     logger.should_receive(:info).with("DELETE http://#{server}/contacts/#{contact_id}/timezone")
  #     logger.should_receive(:info).with("  Response Code: 204")

  #     result = Flapjack::Diner.delete_contact_timezone!(contact_id)
  #     req.should have_been_requested
  #     result.should be_true
  #   end

  # end

  # context "problems" do

  #   it "raises an exception on network failure" do
  #     req = stub_request(:get, "http://#{server}/entities").to_timeout

  #     expect {
  #       Flapjack::Diner.entities
  #     }.to raise_error
  #     req.should have_been_requested
  #   end

  #   it "raises an exception on invalid JSON data" do
  #     req = stub_request(:get, "http://#{server}/entities").to_return(
  #       :body => "{")

  #     expect {
  #       Flapjack::Diner.entities
  #     }.to raise_error
  #     req.should have_been_requested
  #   end

  #   it "raises an exception if a required argument is not provided" do
  #     req = stub_request(:get, /http:\/\/#{server}\/*/)

  #     expect {
  #       Flapjack::Diner.check_status(entity, nil)
  #     }.to raise_error
  #     req.should_not have_been_requested
  #   end

  #   it "raises an exception if bulk queries don't have entity or check arguments" do
  #     req = stub_request(:get, /http:\/\/#{server}\/*/)

  #     expect {
  #       Flapjack::Diner.bulk_downtime({})
  #     }.to raise_error
  #     req.should_not have_been_requested
  #   end

  #   it "raises an exception if bulk queries have invalid entity arguments" do
  #     req = stub_request(:get, /http:\/\/#{server}\/*/)

  #     expect {
  #       Flapjack::Diner.bulk_scheduled_maintenances(:entity => 23)
  #     }.to raise_error
  #     req.should_not have_been_requested
  #   end

  #   it "raises an exception if bulk queries have invalid check arguments" do
  #     req = stub_request(:get, /http:\/\/#{server}\/*/)

  #     expect {
  #       Flapjack::Diner.bulk_outages(:check => {'abc.com' => ['ping', 5]})
  #     }.to raise_error
  #     req.should_not have_been_requested
  #   end

  #   it "raises an exception if a time argument is provided with the wrong data type" do
  #     start_str  = '2011-08-01T00:00:00+10:00'
  #     finish_str = 'yesterday'

  #     start  = Time.iso8601(start_str)

  #     req = stub_request(:get, /http:\/\/#{server}\/*/)

  #     expect {
  #       Flapjack::Diner.downtime(entity, :start_time => start, :end_time => finish_str)
  #     }.to raise_error
  #     req.should_not have_been_requested
  #   end

  # end

end
