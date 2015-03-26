require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Checks, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a check" do
      flapjack.given("no check exists").
        upon_receiving("a POST request with one check").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => check_data.merge(:type => 'check')}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {'data' => check_data.merge(:type => 'check')})

      result = Flapjack::Diner.create_checks(check_data)
      expect(result).to eq(check_data.merge(:type => 'check'))
    end

    it "submits a POST request for several checks" do
      checks_data = [check_data.merge(:type => 'check'),
                     check_2_data.merge(:type => 'check')]

      flapjack.given("no check exists").
        upon_receiving("a POST request with two checks").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => checks_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {'data' => checks_data})

      result = Flapjack::Diner.create_checks(*checks_data)
      expect(result).to eq(checks_data)
    end

    # TODO fails to create with invalid data
  end

  context 'read' do

    context 'GET all checks' do

      it "has no data" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []} )

        result = Flapjack::Diner.checks
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a check exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => [check_data.merge(:type => 'check')]} )

        result = Flapjack::Diner.checks
        expect(result).to eq([check_data.merge(:type => 'check')])
      end

    end

    context 'GET several checks' do

      it 'has some data' do
        flapjack.given("two checks exist").
          upon_receiving("a GET request for two checks").
          with(:method => :get, :path => "/checks",
               :query => {"filter[]" => "id:#{check_data[:id]}|#{check_2_data[:id]}"}).
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => [check_data.merge(:type => 'check'),
                                check_2_data.merge(:type => 'check')]} )

        result = Flapjack::Diner.checks(check_data[:id], check_2_data[:id])
        expect(result).to eq([check_data.merge(:type => 'check'), check_2_data.merge(:type => 'check')])
      end

      it 'has no data' do
        flapjack.given("no check exists").
          upon_receiving("a GET request for two checks").
          with(:method => :get, :path => "/checks",
               :query => {"filter[]" => "id:#{check_data[:id]}|#{check_2_data[:id]}"}).
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []}
          )

        result = Flapjack::Diner.checks(check_data[:id], check_2_data[:id])
        expect(result).to eq([])
      end

    end

    context 'GET a single check' do

      it "has some data" do
        flapjack.given("a check exists").
          upon_receiving("a GET request for a check").
          with(:method => :get, :path => "/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => check_data.merge(:type => 'check')} )

        result = Flapjack::Diner.checks(check_data[:id])
        expect(result).to eq(check_data.merge(:type => 'check'))
      end

      it "can't find check" do
        flapjack.given("no check exists").
          upon_receiving("a GET request for a check").
          with(:method => :get, :path => "/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:errors => [{
                :status => '404',
                :detail => "could not find Check record, id: '#{check_data[:id]}'"
              }]}
            )

        result = Flapjack::Diner.checks(check_data[:id])
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq([{:status => '404',
          :detail => "could not find Check record, id: '#{check_data[:id]}'"}])
      end
    end
  end

  context 'update' do

    it 'submits a PATCH request for a check' do
      flapjack.given("a check exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => "/checks/#{check_data[:id]}",
             :body => {:data => {:id => check_data[:id], :type => 'check', :enabled => false}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_checks(:id => check_data[:id], :enabled => false)
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PATCH request for several checks' do
      flapjack.given("two checks exist").
        upon_receiving("a PATCH request for two checks").
        with(:method => :patch,
             :path => "/checks",
             :body => {:data => [{:id => check_data[:id], :type => 'check', :enabled => false},
                                 {:id => check_2_data[:id], :type => 'check', :enabled => true}]},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_checks(
        {:id => check_data[:id], :enabled => false},
        {:id => check_2_data[:id], :enabled => true})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the check to update" do
      flapjack.given("no check exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => "/checks/#{check_data[:id]}",
             :body => {:data => {:id => check_data[:id], :type => 'check', :enabled => false}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Check record, id: '#{check_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.update_checks(:id => check_data[:id], :enabled => false)
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Check record, id: '#{check_data[:id]}'"}])
    end

  end

end
