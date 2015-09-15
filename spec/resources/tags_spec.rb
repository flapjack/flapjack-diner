require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a tag" do
      req_data  = tag_json(tag_data)
      resp_data = req_data.merge(:relationships => tag_rel(tag_data))

      flapjack.given("no data exists").
        upon_receiving("a POST request with one tag").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:data => resp_data}
        )

      result = Flapjack::Diner.create_tags(tag_data)
      expect(result).to eq(resultify(resp_data))
    end

    it "submits a POST request for several tags" do
      req_data = [tag_json(tag_data), tag_json(tag_2_data)]
      resp_data = [
        req_data[0].merge(:relationships => tag_rel(tag_data)),
        req_data[1].merge(:relationships => tag_rel(tag_2_data))
      ]

      flapjack.given("no data exists").
        upon_receiving("a POST request with two tags").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => req_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {'data' => resp_data}
        )

      result = Flapjack::Diner.create_tags(tag_data, tag_2_data)
      expect(result).to eq(resultify(resp_data))
    end

    # TODO fails to create with invalid data
  end

  context 'read' do

    context 'GET all tags' do

      it "has no data" do
        flapjack.given("no data exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => []} )

        result = Flapjack::Diner.tags
        expect(result).to eq([])
      end

      it "has some data" do
        resp_data = [tag_json(tag_data).merge(:relationships => tag_rel(tag_data))]

        flapjack.given("a tag exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

        result = Flapjack::Diner.tags
        expect(result).to eq(resultify(resp_data))
      end

    end

    context 'GET a single tag' do

      it "has some data" do
        resp_data = tag_json(tag_data).merge(:relationships => tag_rel(tag_data))

        flapjack.given("a tag exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:id]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:data => resp_data} )

        result = Flapjack::Diner.tags(tag_data[:id])
        expect(result).to eq(resultify(resp_data))
      end

      it "can't find tag" do
        flapjack.given("no data exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:id]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
            :body => {:errors => [{
              :status => '404',
              :detail => "could not find Tag record, id: '#{tag_data[:id]}'"
            }]}
          )

        result = Flapjack::Diner.tags(tag_data[:id])
        expect(result).to be_nil
        expect(Flapjack::Diner.error).to eq([{:status => '404',
          :detail => "could not find Tag record, id: '#{tag_data[:id]}'"}])
      end

    end

  end

  context 'update' do

    it 'submits a PATCH request for a tag' do
      flapjack.given("a tag exists").
        upon_receiving("a PATCH request for a single tag").
        with(:method => :patch,
             :path => "/tags/#{tag_data[:id]}",
             :body => {:data => {:id => tag_data[:id], :type => 'tag', :attributes => {:name => 'database_only'}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_tags(:id => tag_data[:id], :name => 'database_only')
      expect(result).to be_a(TrueClass)
    end

    it 'submits a PATCH request for several tags' do
      flapjack.given("two tags exist").
        upon_receiving("a PATCH request for two tags").
        with(:method => :patch,
             :path => "/tags",
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :body => {:data => [{:id => tag_data[:id], :type => 'tag', :attributes => {:name => 'database_only'}},
                                 {:id => tag_2_data[:id], :type => 'tag', :attributes => {:name => 'app_only'}}]}).
        will_respond_with(
          :status => 204,
          :body => '' )

      result = Flapjack::Diner.update_tags(
        {:id => tag_data[:id], :name => 'database_only'},
        {:id => tag_2_data[:id], :name => 'app_only'})
      expect(result).to be_a(TrueClass)
    end

    it "can't find the tag to update" do
      flapjack.given("no data exists").
        upon_receiving("a PATCH request for a single tag").
        with(:method => :patch,
             :path => "/tags/#{tag_data[:id]}",
             :body => {:data => {:id => tag_data[:id], :type => 'tag', :attributes => {:name => 'database_only'}}},
             :headers => {'Content-Type' => 'application/vnd.api+json'}).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
              :status => '404',
              :detail => "could not find Tag record, id: '#{tag_data[:id]}'"
            }]}
          )

      result = Flapjack::Diner.update_tags(:id => tag_data[:id], :name => 'database_only')
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Tag record, id: '#{tag_data[:id]}'"}])
    end
  end

  context 'delete' do

    it "submits a DELETE request for a tag" do
      flapjack.given("a tag exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:id]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several tags" do
      tags_data = [{:type => 'tag', :id => tag_data[:id]},
                   {:type => 'tag', :id => tag_2_data[:id]}]

      flapjack.given("two tags exist").
        upon_receiving("a DELETE request for two tags").
        with(:method => :delete,
             :headers => {'Content-Type' => 'application/vnd.api+json; ext=bulk'},
             :path => "/tags",
             :body => {:data => tags_data}).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:id], tag_2_data[:id])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the tag to delete" do
      flapjack.given("no data exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:id]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
          :body => {:errors => [{
            :status => '404',
            :detail => "could not find Tag record, id: '#{tag_data[:id]}'"
          }]}
        )

      result = Flapjack::Diner.delete_tags(tag_data[:id])
      expect(result).to be_nil
      expect(Flapjack::Diner.error).to eq([{:status => '404',
        :detail => "could not find Tag record, id: '#{tag_data[:id]}'"}])
    end
  end

end
