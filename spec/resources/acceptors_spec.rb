require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Acceptors, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for an acceptor" do
      req_data  = acceptor_json(acceptor_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )
      resp_data = acceptor_json(acceptor_data).merge(:relationships => acceptor_rel(acceptor_data))

      flapjack.given("a contact exists").
        upon_receiving("a POST request with one acceptor").
        with(:method => :post, :path => '/acceptors',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
         :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_acceptors(acceptor_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several acceptors" do
      req_data = [acceptor_json(acceptor_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      ), acceptor_json(acceptor_2_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )]
      resp_data = [
        acceptor_json(acceptor_data).merge(:relationships => acceptor_rel(acceptor_data)),
        acceptor_json(acceptor_2_data).merge(:relationships => acceptor_rel(acceptor_2_data))
      ]

      flapjack.given("a contact exists").
        upon_receiving("a POST request with two acceptors").
        with(:method => :post, :path => '/acceptors',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_acceptors(acceptor_data.merge(:contact => contact_data[:id]),
                                            acceptor_2_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    # TODO error due to invalid data

  end

  context 'read' do

    it "submits a GET request for all acceptors" do
      resp_data = [acceptor_json(acceptor_data).merge(:relationships => acceptor_rel(acceptor_data))]

      flapjack.given("an acceptor exists").
        upon_receiving("a GET request for all acceptors").
        with(:method => :get, :path => '/acceptors').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.acceptors
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for one acceptor" do
      resp_data = acceptor_json(acceptor_data).merge(:relationships => acceptor_rel(acceptor_data))

      flapjack.given("an acceptor exists").
        upon_receiving("a GET request for a single acceptor").
        with(:method => :get, :path => "/acceptors/#{acceptor_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data}
        )

      result = Flapjack::Diner.acceptors(acceptor_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for several acceptors" do
      resp_data = [
        acceptor_json(acceptor_data).merge(:relationships => acceptor_rel(acceptor_data)),
        acceptor_json(acceptor_2_data).merge(:relationships => acceptor_rel(acceptor_2_data))
      ]

      acceptors_data = [acceptor_data.merge(:type => 'acceptor'), acceptor_2_data.merge(:type => 'acceptor')]

      flapjack.given("two acceptors exist").
        upon_receiving("a GET request for two acceptors").
        with(:method => :get, :path => "/acceptors",
             :query => "filter%5B%5D=id%3A#{acceptor_data[:id]}%7C#{acceptor_2_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.acceptors(acceptor_data[:id], acceptor_2_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "can't find the acceptor to read" do
      flapjack.given("no data exists").
        upon_receiving("a GET request for a single acceptor").
        with(:method => :get, :path => "/acceptors/#{acceptor_data[:id]}").
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Acceptor record, id: '#{acceptor_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.acceptors(acceptor_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Acceptor record, id: '#{acceptor_data[:id]}'"}])
    end

  end

  # # Not immediately relevant, no data fields to update until time_restrictions are fixed
  # context 'update' do
  #   it 'submits a PUT request for an acceptor' do
  #     flapjack.given("an acceptor exists").
  #       upon_receiving("a PUT request for a single acceptor").
  #       with(:method => :put,
  #            :path => "/acceptors/#{acceptor_data[:id]}",
  #            :body => {:acceptors => {:id => acceptor_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_acceptors(:id => acceptor_data[:id], :time_restrictions => [])
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it 'submits a PUT request for several acceptors' do
  #     flapjack.given("two acceptors exist").
  #       upon_receiving("a PUT request for two acceptors").
  #       with(:method => :put,
  #            :path => "/acceptors/#{acceptor_data[:id]},#{acceptor_2_data[:id]}",
  #            :body => {:acceptors => [{:id => acceptor_data[:id], :time_restrictions => []},
  #            {:id => acceptor_2_data[:id], :enabled => true}]},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_acceptors(
  #       {:id => acceptor_data[:id], :time_restrictions => []},
  #       {:id => acceptor_2_data[:id], :enabled => true})
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it "can't find the acceptor to update" do
  #     flapjack.given("no data exists").
  #       upon_receiving("a PUT request for a single acceptor").
  #       with(:method => :put,
  #            :path => "/acceptors/#{acceptor_data[:id]}",
  #            :body => {:acceptors => {:id => acceptor_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 404,
  #         :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
  #         :body => {:errors => [{
  #             :status => '404',
  #             :detail => "could not find Acceptor records, ids: '#{acceptor_data[:id]}'"
  #           }]}
  #         )

  #     result = Flapjack::Diner.update_acceptors(:id => acceptor_data[:id], :time_restrictions => [])
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq([{:status => '404',
  #       :detail => "could not find Acceptor records, ids: '#{acceptor_data[:id]}'"}])
  #   end
  # end

  context 'delete' do

    it "submits a DELETE request for an acceptor" do
      flapjack.given("an acceptor exists").
        upon_receiving("a DELETE request for a single acceptor").
        with(:method => :delete,
             :path => "/acceptors/#{acceptor_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_acceptors(acceptor_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several acceptors" do
      acceptors_data = [{:type => 'acceptor', :id => acceptor_data[:id]},
                    {:type => 'acceptor', :id => acceptor_2_data[:id]}]

      flapjack.given("two acceptors exist").
        upon_receiving("a DELETE request for two acceptors").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/acceptors",
             :body => {:data => acceptors_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_acceptors(acceptor_data[:id], acceptor_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the acceptor to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single acceptor").
        with(:method => :delete,
             :path => "/acceptors/#{acceptor_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Acceptor record, id: '#{acceptor_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_acceptors(acceptor_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Acceptor record, id: '#{acceptor_data[:id]}'"}])
    end
  end

end
