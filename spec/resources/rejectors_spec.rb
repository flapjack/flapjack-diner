require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Rejectors, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a rejector" do
      req_data  = rejector_json(rejector_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      )
      resp_data = rejector_json(rejector_data).merge(:relationships => rejector_rel(rejector_data))

      flapjack.given("a contact exists").
        upon_receiving("a POST request with one rejector").
        with(:method => :post, :path => '/rejectors',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
         :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_rejectors(rejector_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several rejectors" do
      req_data = [rejector_json(rejector_data).merge(
        :relationships => {
          :contact => {
            :data => {
              :type => 'contact',
              :id => contact_data[:id]
            }
          }
        }
      ), rejector_json(rejector_2_data).merge(
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
        rejector_json(rejector_data).merge(:relationships => rejector_rel(rejector_data)),
        rejector_json(rejector_2_data).merge(:relationships => rejector_rel(rejector_2_data))
      ]

      flapjack.given("a contact exists").
        upon_receiving("a POST request with two rejectors").
        with(:method => :post, :path => '/rejectors',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_rejectors(rejector_data.merge(:contact => contact_data[:id]),
                                            rejector_2_data.merge(:contact => contact_data[:id]))
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    # TODO error due to invalid data

  end

  context 'read' do

    it "submits a GET request for all rejectors" do
      resp_data = [rejector_json(rejector_data).merge(:relationships => rejector_rel(rejector_data))]

      flapjack.given("a rejector exists").
        upon_receiving("a GET request for all rejectors").
        with(:method => :get, :path => '/rejectors').
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.rejectors
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for one rejector" do
      resp_data = rejector_json(rejector_data).merge(:relationships => rejector_rel(rejector_data))

      flapjack.given("a rejector exists").
        upon_receiving("a GET request for a single rejector").
        with(:method => :get, :path => "/rejectors/#{rejector_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data}
        )

      result = Flapjack::Diner.rejectors(rejector_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a GET request for several rejectors" do
      resp_data = [
        rejector_json(rejector_data).merge(:relationships => rejector_rel(rejector_data)),
        rejector_json(rejector_2_data).merge(:relationships => rejector_rel(rejector_2_data))
      ]

      rejectors_data = [rejector_data.merge(:type => 'rejector'), rejector_2_data.merge(:type => 'rejector')]

      flapjack.given("two rejectors exist").
        upon_receiving("a GET request for two rejectors").
        with(:method => :get, :path => "/rejectors",
             :query => "filter%5B%5D=id%3A#{rejector_data[:id]}%7C#{rejector_2_data[:id]}").
        will_respond_with(
          :status => 200,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

      result = Flapjack::Diner.rejectors(rejector_data[:id], rejector_2_data[:id])
      expect(result).not_to be_nil
      expect(result).to eq(resultify(resp_data))
    end

    it "can't find the rejector to read" do
      flapjack.given("no data exists").
        upon_receiving("a GET request for a single rejector").
        with(:method => :get, :path => "/rejectors/#{rejector_data[:id]}").
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Rejector record, id: '#{rejector_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.rejectors(rejector_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Rejector record, id: '#{rejector_data[:id]}'"}])
    end

  end

  # # Not immediately relevant, no data fields to update until time_restrictions are fixed
  # context 'update' do
  #   it 'submits a PUT request for a rejector' do
  #     flapjack.given("a rejector exists").
  #       upon_receiving("a PUT request for a single rejector").
  #       with(:method => :put,
  #            :path => "/rejectors/#{rejector_data[:id]}",
  #            :body => {:rejectors => {:id => rejector_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_rejectors(:id => rejector_data[:id], :time_restrictions => [])
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it 'submits a PUT request for several rejectors' do
  #     flapjack.given("two rejectors exist").
  #       upon_receiving("a PUT request for two rejectors").
  #       with(:method => :put,
  #            :path => "/rejectors/#{rejector_data[:id]},#{rejector_2_data[:id]}",
  #            :body => {:rejectors => [{:id => rejector_data[:id], :time_restrictions => []},
  #            {:id => rejector_2_data[:id], :enabled => true}]},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 204,
  #         :body => '' )

  #     result = Flapjack::Diner.update_rejectors(
  #       {:id => rejector_data[:id], :time_restrictions => []},
  #       {:id => rejector_2_data[:id], :enabled => true})
  #     expect(result).to be_a(TrueClass)
  #   end

  #   it "can't find the rejector to update" do
  #     flapjack.given("no data exists").
  #       upon_receiving("a PUT request for a single rejector").
  #       with(:method => :put,
  #            :path => "/rejectors/#{rejector_data[:id]}",
  #            :body => {:rejectors => {:id => rejector_data[:id], :time_restrictions => []}},
  #            :headers => {'Content-Type' => 'application/vnd.api+json'}).
  #       will_respond_with(
  #         :status => 404,
  #         :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
  #         :body => {:errors => [{
  #             :status => '404',
  #             :detail => "could not find Rejector records, ids: '#{rejector_data[:id]}'"
  #           }]}
  #         )

  #     result = Flapjack::Diner.update_rejectors(:id => rejector_data[:id], :time_restrictions => [])
  #     expect(result).to be_nil
  #     expect(Flapjack::Diner.last_error).to eq([{:status => '404',
  #       :detail => "could not find Rejector records, ids: '#{rejector_data[:id]}'"}])
  #   end
  # end

  context 'delete' do

    it "submits a DELETE request for a rejector" do
      flapjack.given("a rejector exists").
        upon_receiving("a DELETE request for a single rejector").
        with(:method => :delete,
             :path => "/rejectors/#{rejector_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rejectors(rejector_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several rejectors" do
      rejectors_data = [{:type => 'rejector', :id => rejector_data[:id]},
                    {:type => 'rejector', :id => rejector_2_data[:id]}]

      flapjack.given("two rejectors exist").
        upon_receiving("a DELETE request for two rejectors").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/rejectors",
             :body => {:data => rejectors_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_rejectors(rejector_data[:id], rejector_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the rejector to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single rejector").
        with(:method => :delete,
             :path => "/rejectors/#{rejector_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Rejector record, id: '#{rejector_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.delete_rejectors(rejector_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Rejector record, id: '#{rejector_data[:id]}'"}])
    end
  end

end
