require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a check" do
      req_data  = check_json(check_data)
      resp_data = req_data.merge(:relationships => check_rel(check_data))

      flapjack.given("no data exists").
        upon_receiving("a POST request with one check").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.create_checks(check_data)
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several checks" do
      req_data = [check_json(check_data), check_json(check_2_data)]
      resp_data = [
        req_data[0].merge(:relationships => check_rel(check_data)),
        req_data[1].merge(:relationships => check_rel(check_2_data))
      ]

      flapjack.given("no data exists").
        upon_receiving("a POST request with two checks").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {'data' => resp_data})

      result = Flapjack::Diner.create_checks(check_data, check_2_data)
      expect(result).to eq(resultify(resp_data))
    end

    # TODO fails to create with invalid data

    it "creates a check and links it to a tag" do
      req_data  = check_json(check_data).merge(
        :relationships => {
          :tags => {
            :data => [{:type => 'tag', :id => tag_data[:id]}]
          }
        }
      )
      resp_data = req_data.merge(:relationships => check_rel(check_data))

      flapjack.given("a tag exists").
        upon_receiving("a POST request with a check linking to a tag").
        with(:method => :post, :path => '/checks',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data})

      result = Flapjack::Diner.create_checks(check_data.merge(:tags => [tag_data[:id]]))
      expect(result).to eq(resultify(resp_data))
    end

  end

  context 'read' do

    context 'GET all checks' do

      it "has no data" do
        flapjack.given("no data exists").
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
        resp_data = [check_json(check_data).merge(:relationships => check_rel(check_data))]

        flapjack.given("a check exists").
          upon_receiving("a GET request for all checks").
          with(:method => :get, :path => '/checks').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

        result = Flapjack::Diner.checks
        expect(result).to eq(resultify(resp_data))
      end

    end

    context 'GET several checks' do

      it 'has some data' do
        resp_data = [
          check_json(check_data).merge(:relationships => check_rel(check_data)),
          check_json(check_2_data).merge(:relationships => check_rel(check_2_data))
        ]

        flapjack.given("two checks exist").
          upon_receiving("a GET request for two checks").
          with(:method => :get, :path => "/checks",
               :query => "filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data})

        result = Flapjack::Diner.checks(check_data[:id], check_2_data[:id])
        expect(result).to eq(resultify(resp_data))
      end

      it 'has no data' do
        flapjack.given("no data exists").
          upon_receiving("a GET request for two checks").
          with(:method => :get, :path => "/checks",
               :query => "filter%5B%5D=id%3A#{check_data[:id]}%7C#{check_2_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []}
          )

        result = Flapjack::Diner.checks(check_data[:id], check_2_data[:id])
        expect(result).to eq([])
      end

    end

    context 'GET checks by name' do

      let(:name) { CGI.escape(check_data[:name]) }

      it 'has some data' do
        resp_data = [check_json(check_data).merge(:relationships => check_rel(check_data))]

        flapjack.given("a check exists").
          upon_receiving("a GET request for checks by name").
          with(:method => :get, :path => "/checks",
               :query => "filter%5B%5D=name%3A#{name}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

        result = Flapjack::Diner.checks(:filter => {:name => check_data[:name]})
        expect(result).to eq(resultify(resp_data))
      end

      it "can't find check" do
        flapjack.given("no data exists").
          upon_receiving("a GET request for checks by name").
          with(:method => :get, :path => "/checks",
               :query => "filter%5B%5D=name%3A#{name}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []}
          )

        result = Flapjack::Diner.checks(:filter => {:name => check_data[:name]})
        expect(result).to eq([])
      end

    end

    context 'GET a single check' do

      it "has some data" do
        resp_data = check_json(check_data).merge(:relationships => check_rel(check_data))

        flapjack.given("a check exists").
          upon_receiving("a GET request for a check").
          with(:method => :get, :path => "/checks/#{check_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

        result = Flapjack::Diner.checks(check_data[:id])
        expect(result).to eq(resultify(resp_data))
      end

      it "can't find check" do
        flapjack.given("no data exists").
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
        expect(Flapjack::Diner.error).to eq([{:status => '404',
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
             :body => {:data => {:id => check_data[:id], :type => 'check', :attributes => {:enabled => false}}},
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
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => [{:id => check_data[:id], :type => 'check',  :attributes => {:enabled => false}},
                                 {:id => check_2_data[:id], :type => 'check',  :attributes => {:enabled => true}}]}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_checks(
        {:id => check_data[:id], :enabled => false},
        {:id => check_2_data[:id], :enabled => true})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the check to update" do
      flapjack.given("no data exists").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => "/checks/#{check_data[:id]}",
             :body => {:data => {:id => check_data[:id], :type => 'check',  :attributes => {:enabled => false}}},
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
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Check record, id: '#{check_data[:id]}'"}])
    end

    it "replaces the tags for a check" do
      req_data = {
        :id => check_data[:id],
        :type => 'check',
        :relationships => {
          :tags => {
            :data => [{:type => 'tag', :id => tag_data[:id]}]
          }
        }
      }

      flapjack.given("a check and a tag exist").
        upon_receiving("a PATCH request for a single check").
        with(:method => :patch,
             :path => "/checks/#{check_data[:id]}",
             :body => {:data => req_data},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_checks(:id => check_data[:id], :tags => [tag_data[:id]])
      expect(result).to be_a(TrueClass)
    end

  end

end
