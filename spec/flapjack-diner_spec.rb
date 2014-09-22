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

  context 'contacts' do
    context 'create' do

      it "submits a POST request for a contact" do
        data = [{:first_name => 'Jim',
                 :last_name  => 'Smith',
                 :email      => 'jims@example.com',
                 :timezone   => 'UTC',
                 :tags       => ['admin', 'night_shift']}]

        req = stub_request(:post, "http://#{server}/contacts").
          with(:body => {:contacts => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('contacts', data))

        result = Flapjack::Diner.create_contacts(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a POST request for several contacts" do
        data = [{:first_name => 'Jim',
                 :last_name  => 'Smith',
                 :email      => 'jims@example.com',
                 :timezone   => 'UTC',
                 :tags       => ['admin', 'night_shift']},
                {:first_name => 'Joan',
                 :last_name  => 'Smith',
                 :email      => 'joans@example.com'}]

        req = stub_request(:post, "http://#{server}/contacts").
          with(:body => {:contacts => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('contacts', data))

        result = Flapjack::Diner.create_contacts(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'read' do
      it "submits a GET request for all contacts" do
        data = [{:id => "21"}]

        req = stub_request(:get, "http://#{server}/contacts").to_return(
          :status => 200, :body => response_with_data('contacts', data))

        result = Flapjack::Diner.contacts
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_an_instance_of(Array)
        expect(result.length).to be(1)
        expect(result[0]).to be_an_instance_of(Hash)
        expect(result[0]).to have_key('id')
      end

      it "can return keys as symbols" do
        Flapjack::Diner.return_keys_as_strings = false
        data = [{
          :id         => "21",
          :first_name => "Ada",
          :last_name  => "Lovelace",
          :email      => "ada@example.com",
          :timezone   => "Europe/London",
          :tags       => [ "legend", "first computer programmer" ],
          :links      => {
            :entities           => ["7", "12", "83"],
            :media              => ["21_email", "21_sms"],
            :notification_rules => ["30fd36ae-3922-4957-ae3e-c8f6dd27e543"]
          }
        }]

        req = stub_request(:get, "http://#{server}/contacts").to_return(
          :status => 200, :body => response_with_data('contacts', data))

        result = Flapjack::Diner.contacts
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_an_instance_of(Array)
        expect(result.length).to be(1)
        expect(result[0]).to be_an_instance_of(Hash)
        expect(result[0]).to have_key(:id)
        expect(result[0]).to have_key(:links)
        expect(result[0][:links]).to have_key(:entities)
      end

      it "submits a GET request for one contact" do
        req = stub_request(:get, "http://#{server}/contacts/72").to_return(
          :body => response_with_data('contacts'))

        result = Flapjack::Diner.contacts('72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several contacts" do
        req = stub_request(:get, "http://#{server}/contacts/72,150").to_return(
          :body => response_with_data('contacts'))

        result = Flapjack::Diner.contacts('72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for one contact" do
        req = stub_request(:patch, "http://#{server}/contacts/23").
          with(:body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_contacts(23, :timezone => 'UTC')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for several contacts" do
        req = stub_request(:patch, "http://#{server}/contacts/23,87").
          with(:body => [{:op => 'replace', :path => '/contacts/0/timezone', :value => 'UTC'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_contacts(23, 87, :timezone => 'UTC')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request to change a link for one contact" do
        req = stub_request(:patch, "http://#{server}/contacts/23").
          with(:body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '57'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_contacts(23, :add_entity => '57')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request to change links for several contacts" do
        req = stub_request(:patch, "http://#{server}/contacts/23,87").
          with(:body => [{:op => 'add', :path => '/contacts/0/links/entities/-', :value => '57'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_contacts(23, 87, :add_entity => '57')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do
      it "submits a DELETE request for one contact" do
        req = stub_request(:delete, "http://#{server}/contacts/72").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_contacts('72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for several contacts" do
        req = stub_request(:delete, "http://#{server}/contacts/72,150").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_contacts('72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end
    end
  end

  context 'media' do
    context 'create' do

      it "submits a POST request for a medium" do
        data = [{
          :type             => 'sms',
          :address          => '0123456789',
          :interval         => 300,
          :rollup_threshold => 5
        }]

        req = stub_request(:post, "http://#{server}/contacts/1/media").
          with(:body => {:media => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('media', data))

        result = Flapjack::Diner.create_contact_media(1, data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a POST request for several media" do
        data = [{
          :type             => 'sms',
          :address          => '0123456789',
          :interval         => 300,
          :rollup_threshold => 5
        }, {
          :type             => 'email',
          :address          => 'ablated@example.org',
          :interval         => 180,
          :rollup_threshold => 3
        }]

        req = stub_request(:post, "http://#{server}/contacts/1/media").
          with(:body => {:media => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('media', data))

        result = Flapjack::Diner.create_contact_media(1, data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'read' do
     it "submits a GET request for all media" do
        req = stub_request(:get, "http://#{server}/media").
          to_return(:body => response_with_data('media'))

        result = Flapjack::Diner.media
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for one medium" do
        req = stub_request(:get, "http://#{server}/media/72_sms").
          to_return(:body => response_with_data('media'))

        result = Flapjack::Diner.media('72_sms')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several media" do
        req = stub_request(:get, "http://#{server}/media/72_sms,150_email").
          to_return(:body => response_with_data('media'))

        result = Flapjack::Diner.media('72_sms', '150_email')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for one medium" do
        req = stub_request(:patch, "http://#{server}/media/23_email").
          with(:body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                         {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_media('23_email', :interval => 50, :rollup_threshold => 3)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for several media" do
        req = stub_request(:patch, "http://#{server}/media/23_email,87_sms").
          with(:body => [{:op => 'replace', :path => '/media/0/interval', :value => 50},
                         {:op => 'replace', :path => '/media/0/rollup_threshold', :value => 3}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_media('23_email', '87_sms', :interval => 50, :rollup_threshold => 3)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do
      it "submits a DELETE request for one medium" do
        req = stub_request(:delete, "http://#{server}/media/72_sms").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_media('72_sms')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for several media" do
        req = stub_request(:delete, "http://#{server}/media/72_sms,150_email").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_media('72_sms', '150_email')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end
    end
  end

  context 'pagerduty credentials' do
    context 'create' do

      it "submits a POST request for pagerduty credentials" do
        data = [{:service_key => 'abc',
                 :subdomain   => 'def',
                 :username    => 'ghi',
                 :password    => 'jkl',
                }]

        req = stub_request(:post, "http://#{server}/contacts/1/pagerduty_credentials").
          with(:body => {:pagerduty_credentials => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('pagerduty_credentials', data))

        result = Flapjack::Diner.create_contact_pagerduty_credentials(1, data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'read' do
     it "submits a GET request for all pagerduty credentials" do
        req = stub_request(:get, "http://#{server}/pagerduty_credentials").
          to_return(:body => response_with_data('pagerduty_credentials'))

        result = Flapjack::Diner.pagerduty_credentials
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for one set of pagerduty credentials" do
        req = stub_request(:get, "http://#{server}/pagerduty_credentials/72").
          to_return(:body => response_with_data('pagerduty_credentials'))

        result = Flapjack::Diner.pagerduty_credentials('72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several sets of pagerduty credentials" do
        req = stub_request(:get, "http://#{server}/pagerduty_credentials/72,150").
          to_return(:body => response_with_data('pagerduty_credentials'))

        result = Flapjack::Diner.pagerduty_credentials('72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for one set of pagerduty credentials" do
        req = stub_request(:patch, "http://#{server}/pagerduty_credentials/23").
          with(:body => [{:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'lmno'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_pagerduty_credentials('23', :password => 'lmno')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for several sets of pagerduty credentials" do
        req = stub_request(:patch, "http://#{server}/pagerduty_credentials/23,87").
          with(:body => [{:op => 'replace', :path => '/pagerduty_credentials/0/username', :value => 'hijk'},
                         {:op => 'replace', :path => '/pagerduty_credentials/0/password', :value => 'lmno'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_pagerduty_credentials('23', '87', :username => 'hijk', :password => 'lmno')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do
      it "submits a DELETE request for one set of pagerduty credentials" do
        req = stub_request(:delete, "http://#{server}/pagerduty_credentials/72").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_pagerduty_credentials('72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for several media" do
        req = stub_request(:delete, "http://#{server}/pagerduty_credentials/72,150").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_pagerduty_credentials('72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end
    end
  end

  context 'notification rules' do

    context 'create' do

      it "submits a POST request for a notification rule" do
        data = [{
          "entity_tags"        => ["database","physical"],
          "entities"           => ["foo-app-01.example.com"],
          "time_restrictions"  => nil,
          "warning_media"      => ["email"],
          "critical_media"     => ["sms", "email"],
          "warning_blackhole"  => false,
          "critical_blackhole" => false
        }]

        req = stub_request(:post, "http://#{server}/contacts/1/notification_rules").
          with(:body => {:notification_rules => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('notification_rules', data))


        result = Flapjack::Diner.create_contact_notification_rules(1, data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a POST request for several notification rules" do
        data = [{
          "entity_tags"        => ["database","physical"],
          "entities"           => ["foo-app-01.example.com"],
          "time_restrictions"  => nil,
          "warning_media"      => ["email"],
          "critical_media"     => ["sms", "email"],
          "warning_blackhole"  => false,
          "critical_blackhole" => false
        }, {
          "entity_tags"        => nil,
          "entities"           => ["foo-app-02.example.com"],
          "time_restrictions"  => nil,
          "warning_media"      => ["email"],
          "critical_media"     => ["sms", "email"],
          "warning_blackhole"  => true,
          "critical_blackhole" => false
        }]

        req = stub_request(:post, "http://#{server}/contacts/1/notification_rules").
          with(:body => {:notification_rules => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('notification_rules', data))

        result = Flapjack::Diner.create_contact_notification_rules(1, data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'read' do
     it "submits a GET request for all notification rules" do
        req = stub_request(:get, "http://#{server}/notification_rules").
          to_return(:body => response_with_data('notification_rules'))

        result = Flapjack::Diner.notification_rules
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for one notification rule" do
        req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
          to_return(:body => response_with_data('notification_rules'))

        result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several media" do
        req = stub_request(:get, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
          to_return(:body => response_with_data('notification_rules'))

        result = Flapjack::Diner.notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for one notification rule" do
        req = stub_request(:patch, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
          with(:body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', :warning_blackhole => false)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a PATCH request for several notification rules" do
        req = stub_request(:patch, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
          with(:body => [{:op => 'replace', :path => '/notification_rules/0/warning_blackhole', :value => false}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543',
          'bfd8be61-3d80-4b95-94df-6e77183ce4e3', :warning_blackhole => false)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

    end

    context 'delete' do
      it "submits a DELETE request for a notification rule" do
        req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a DELETE request for several notification rules" do
        req = stub_request(:delete, "http://#{server}/notification_rules/30fd36ae-3922-4957-ae3e-c8f6dd27e543,bfd8be61-3d80-4b95-94df-6e77183ce4e3").
          to_return(:status => 204)

        result = Flapjack::Diner.delete_notification_rules('30fd36ae-3922-4957-ae3e-c8f6dd27e543', 'bfd8be61-3d80-4b95-94df-6e77183ce4e3')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end
    end
  end

  context 'entities' do

    context 'create' do

     it "submits a POST request for an entity" do
        data = [{
          :name => 'example.org',
          :id   => '57_example'
        }]

        req = stub_request(:post, "http://#{server}/entities").
          with(:body => {:entities => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('entities', data))

        result = Flapjack::Diner.create_entities(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a POST request for several entities" do
        data = [{
          :name => 'example.org',
          :id   => '57_example'
        }, {
          :name => 'example2.org',
          :id   => '58'
        }]

        req = stub_request(:post, "http://#{server}/entities").
          with(:body => {:entities => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('entities', data))

        result = Flapjack::Diner.create_entities(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

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

      context 'test notifications' do

        it "submits a POST request for an entity" do
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, [:summary => 'testing'])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for several entities" do
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72,150").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, 150, [:summary => 'testing'])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on an entity" do
          data = [{:summary => 'testing'}, {:summary => 'another test'}]
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on several entities" do
          data = [{:summary => 'testing'}, {:summary => 'another test'}]
          req = stub_request(:post, "http://#{server}/test_notifications/entities/72,150").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_entities(72, 150, data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

    context 'read' do
      it "submits a GET request for all entities" do
        req = stub_request(:get, "http://#{server}/entities").
          to_return(:body => response_with_data('entities'))

        result = Flapjack::Diner.entities
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for one entity" do
        req = stub_request(:get, "http://#{server}/entities/72").
          to_return(:body => response_with_data('entities'))

        result = Flapjack::Diner.entities('72')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several entities" do
        req = stub_request(:get, "http://#{server}/entities/72,150").
          to_return(:body => response_with_data('entities'))

        result = Flapjack::Diner.entities('72', '150')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for an entity" do
        req = stub_request(:patch, "http://#{server}/entities/57").
          with(:body => [{:op => 'replace', :path => '/entities/0/name', :value => 'example3.com'}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_entities('57', :name => 'example3.com')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

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

     it "submits a POST request for a check" do
        data = [{
          :name       => 'PING',
          :entity_id  => '357'
        }]

        req = stub_request(:post, "http://#{server}/checks").
          with(:body => {:checks => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('checks', data))

        result = Flapjack::Diner.create_checks(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

      it "submits a POST request for several checks" do
        data = [{
          :name       => 'SSH',
          :entity_id  => '357'
        }, {
          :name       => 'PING',
          :entity_id  => '358'
        }]

        req = stub_request(:post, "http://#{server}/checks").
          with(:body => {:checks => data}.to_json,
               :headers => {'Content-Type'=>'application/vnd.api+json'}).
          to_return(:status => 201, :body => response_with_data('checks', data))

        result = Flapjack::Diner.create_checks(data)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

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

      context 'test notifications' do

        it "submits a POST request for a check" do
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH").
            with(:body => {:test_notifications => [{:summary => 'testing'}]}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', [{:summary => 'testing'}])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for several checks" do
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH,example2.com%3APING").
            with(:test_notifications => [{:summary => 'testing'}]).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', 'example2.com:PING', [{:summary => 'testing'}])
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on a check" do
          data = [{:summary => 'testing'}, {:summary => 'more testing'}]
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

        it "submits a POST request for multiple notifications on several checks" do
          data = [{:summary => 'testing'}, {:summary => 'more testing'}]
          req = stub_request(:post, "http://#{server}/test_notifications/checks/example.com%3ASSH,example2.com%3APING").
            with(:body => {:test_notifications => data}.to_json,
                 :headers => {'Content-Type'=>'application/vnd.api+json'}).
            to_return(:status => 204)

          result = Flapjack::Diner.create_test_notifications_checks('example.com:SSH', 'example2.com:PING', data)
          expect(req).to have_been_requested
          expect(result).not_to be_nil
          expect(result).to be_truthy
        end

      end

    end

    context 'read' do
      it "submits a GET request for all checks" do
        req = stub_request(:get, "http://#{server}/checks").
          to_return(:body => response_with_data('checks'))

        result = Flapjack::Diner.checks
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for one check" do
        req = stub_request(:get, "http://#{server}/checks/example.com%3ASSH").
          to_return(:body => response_with_data('checks'))

        result = Flapjack::Diner.checks('example.com:SSH')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end

      it "submits a GET request for several checks" do
        req = stub_request(:get, "http://#{server}/checks/example.com%3ASSH,example2.com%3APING").
          to_return(:body => response_with_data('checks'))

        result = Flapjack::Diner.checks('example.com:SSH', 'example2.com:PING')
        expect(req).to have_been_requested
        expect(result).not_to be_nil
      end
    end

    context 'update' do

      it "submits a PATCH request for a check" do
        req = stub_request(:patch, "http://#{server}/checks/www.example.com%3APING").
          with(:body => [{:op => 'replace', :path => '/checks/0/enabled', :value => false}].to_json,
               :headers => {'Content-Type'=>'application/json-patch+json'}).
          to_return(:status => 204)

        result = Flapjack::Diner.update_checks('www.example.com:PING', :enabled => false)
        expect(req).to have_been_requested
        expect(result).not_to be_nil
        expect(result).to be_truthy
      end

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

  context 'reports' do
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

  context "logging" do

    let(:logger) { double('logger') }

    before do
      Flapjack::Diner.logger = logger
    end

    it "logs a GET request without a path" do
      response = response_with_data('entities')
      req = stub_request(:get, "http://#{server}/entities").
        to_return(:body => response)

      expect(logger).to receive(:info).with("GET http://#{server}/entities")
      expect(logger).to receive(:info).with("  Response Code: 200")
      expect(logger).to receive(:info).with("  Response Body: #{response}")

      result = Flapjack::Diner.entities
      expect(req).to have_been_requested
      expect(result).not_to be_nil
    end

    it "logs a POST request" do
      req = stub_request(:post, "http://#{server}/test_notifications/entities/27").
              to_return(:status => 200)
      expect(logger).to receive(:info).with("POST http://#{server}/test_notifications/entities/27\n" +
        "  Params: {:test_notifications=>[{:summary=>\"dealing with it\"}]}")
      expect(logger).to receive(:info).with("  Response Code: 200")

      result = Flapjack::Diner.create_test_notifications_entities(27, [{:summary => 'dealing with it'}])
      expect(req).to have_been_requested
      expect(result).to be_truthy
    end

    it "logs a DELETE request" do
      req = stub_request(:delete, "http://#{server}/scheduled_maintenances/checks/example.com%3ASSH").
        with(:query => {:start_time => time.iso8601}).
        to_return(:status => 204)

      expect(logger).to receive(:info).with("DELETE http://#{server}/scheduled_maintenances/checks/example.com:SSH?start_time=#{URI.encode_www_form_component(time.iso8601)}")
      expect(logger).to receive(:info).with("  Response Code: 204")

      result = Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => time)
      expect(req).to have_been_requested
      expect(result).to be_truthy
    end

  end

  context "problems" do

    it "raises an exception on network failure" do
      req = stub_request(:get, "http://#{server}/entities").to_timeout

      expect {
        Flapjack::Diner.entities
      }.to raise_error
      expect(req).to have_been_requested
    end

    it "raises an exception on invalid JSON data" do
      req = stub_request(:get, "http://#{server}/entities").to_return(
        :body => "{")

      expect {
        Flapjack::Diner.entities
      }.to raise_error
      expect(req).to have_been_requested
    end

    it "raises an exception if a required argument is not provided" do
      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.delete_scheduled_maintenances_checks('example.com:SSH', :start_time => nil)
      }.to raise_error
      expect(req).not_to have_been_requested
    end

    it "raises an exception if a time argument is provided with the wrong data type" do
      start_str  = '2011-08-01T00:00:00+10:00'
      finish_str = 'yesterday'

      start  = Time.iso8601(start_str)

      req = stub_request(:get, /http:\/\/#{server}\/*/)

      expect {
        Flapjack::Diner.downtime_report_checks('example.com:SSH',
          :start_time => start_time, :end_time => end_time)
      }.to raise_error
      expect(req).not_to have_been_requested
    end

  end

end
