require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Blackholes, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a blackhole" do
      req_data  = blackhole_json(blackhole_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )
      resp_data = blackhole_json(blackhole_data).merge(:relationships => blackhole_rel(blackhole_data))

      flapjack.given("a contact exists").
        upon_receiving("a POST request with one blackhole").
        with(:method => :post, :path => '/blackholes',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
         :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_blackholes(blackhole_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several blackholes" do
      req_data = [blackhole_json(blackhole_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      ), blackhole_json(blackhole_2_data).merge(
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
        blackhole_json(blackhole_data).merge(:relationships => blackhole_rel(blackhole_data)),
        blackhole_json(blackhole_2_data).merge(:relationships => blackhole_rel(blackhole_2_data))
      ]

      flapjack.given("a contact exists").
        upon_receiving("a POST request with two blackholes").
        with(:method => :post, :path => '/blackholes',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_blackholes(blackhole_data.merge(:contact => contact_data[:id]),
                                            blackhole_2_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    # TODO error due to invalid data

  end

  context 'read' do

    it "submits a GET request for all blackholes" do
      resp_data = [blackhole_json(blackhole_data).merge(:relationships => blackhole_rel(blackhole_data))]

      flapjack.given("a blackhole exists").
        upon_receiving("a GET request for all blackholes").
        with(:method => :get, :path => '/blackholes').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.blackholes
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for one blackhole" do
      resp_data = blackhole_json(blackhole_data).merge(:relationships => blackhole_rel(blackhole_data))

      flapjack.given("a blackhole exists").
        upon_receiving("a GET request for a single blackhole").
        with(:method => :get, :path => "/blackholes/#{blackhole_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data}
        )

      result = Flapjack::Diner.blackholes(blackhole_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for several blackholes" do
      resp_data = [
        blackhole_json(blackhole_data).merge(:relationships => blackhole_rel(blackhole_data)),
        blackhole_json(blackhole_2_data).merge(:relationships => blackhole_rel(blackhole_2_data))
      ]

      blackholes_data = [blackhole_data.merge(:type => 'blackhole'), blackhole_2_data.merge(:type => 'blackhole')]

      flapjack.given("two blackholes exist").
        upon_receiving("a GET request for two blackholes").
        with(:method => :get, :path => "/blackholes",
             :query => "filter%5B%5D=id%3A#{blackhole_data[:id]}%7C#{blackhole_2_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.blackholes(blackhole_data[:id], blackhole_2_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "can't find the blackhole to read" do
      flapjack.given("no data exists").
        upon_receiving("a GET request for a single blackhole").
        with(:method => :get, :path => "/blackholes/#{blackhole_data[:id]}").
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Blackhole record, id: '#{blackhole_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.blackholes(blackhole_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Blackhole record, id: '#{blackhole_data[:id]}'"}])
    end

  end

  # # Not immediately relevant, no data fields to update until time_restrictions are fixed
  # context 'update' do
  #   it 'submits a PUT request for a blackhole' do
  #     flapjack.given("a blackhole exists").
  #       upon_receiving("a PUT request for a single blackhole").
  #       with(:method => :put,
  #            :path => "/blackholes/#{blackhole_data[:id]}",
  #            :body => {:blackholes => {:id => blackhole_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_blackholes(:id => blackhole_data[:id], :time_restrictions => [])
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it 'submits a PUT request for several blackholes' do
  #     flapjack.given("two blackholes exist").
  #       upon_receiving("a PUT request for two blackholes").
  #       with(:method => :put,
  #            :path => "/blackholes/#{blackhole_data[:id]},#{blackhole_2_data[:id]}",
  #            :body => {:blackholes => [{:id => blackhole_data[:id], :time_restrictions => []},
  #            {:id => blackhole_2_data[:id], :enabled => true}]},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_blackholes(
  #       {:id => blackhole_data[:id], :time_restrictions => []},
  #       {:id => blackhole_2_data[:id], :enabled => true})
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it "can't find the blackhole to update" do
  #     flapjack.given("no data exists").
  #       upon_receiving("a PUT request for a single blackhole").
  #       with(:method => :put,
  #            :path => "/blackholes/#{blackhole_data[:id]}",
  #            :body => {:blackholes => {:id => blackhole_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 404,
  #         :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
  #         :body => {:errors => [{
  #             :status => '404',
  #             :detail => "could not find Blackhole records, ids: '#{blackhole_data[:id]}'"
  #           }]}
  #         )

  #     result = Flapjack::Diner.update_blackholes(:id => blackhole_data[:id], :time_restrictions => [])
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq([{:status => '404',
  #       :detail => "could not find Blackhole records, ids: '#{blackhole_data[:id]}'"}])
  #   end
  # end

  context 'delete' do

    it "submits a DELETE request for a blackhole" do
      flapjack.given("a blackhole exists").
        upon_receiving("a DELETE request for a single blackhole").
        with(:method => :delete,
             :path => "/blackholes/#{blackhole_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_blackholes(blackhole_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several blackholes" do
      blackholes_data = [{:type => 'blackhole', :id => blackhole_data[:id]},
                    {:type => 'blackhole', :id => blackhole_2_data[:id]}]

      flapjack.given("two blackholes exist").
        upon_receiving("a DELETE request for two blackholes").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/blackholes",
             :body => {:data => blackholes_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_blackholes(blackhole_data[:id], blackhole_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the blackhole to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single blackhole").
        with(:method => :delete,
             :path => "/blackholes/#{blackhole_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Blackhole record, id: '#{blackhole_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_blackholes(blackhole_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Blackhole record, id: '#{blackhole_data[:id]}'"}])
    end
  end

end
