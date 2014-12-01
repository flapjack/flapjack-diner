require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Tags, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  context 'create' do

    it "submits a POST request for a tag" do
      flapjack.given("no tag exists").
        upon_receiving("a POST request with one tag").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:tags => tag_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'tags' => tag_data} )

      result = Flapjack::Diner.create_tags(tag_data)
      expect(result).to eq(tag_data)
    end

    it "submits a POST request for several tags" do
      tags_data = [tag_data, tag_2_data]

      flapjack.given("no tag exists").
        upon_receiving("a POST request with two tags").
        with(:method => :post, :path => '/tags',
             :headers => {'Content-Type' => 'application/vnd.api+json'},
             :body => {:tags => tags_data}).
        will_respond_with(
          :status => 201,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {'tags' => tags_data})

      result = Flapjack::Diner.create_tags(*tags_data)
      expect(result).to eq(tags_data)
    end

    # TODO fails to create with invalid data
  end

  context 'read' do

    context 'GET all tags' do

      it "has no data" do
        flapjack.given("no tag exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => []} )

        result = Flapjack::Diner.tags
        expect(result).to eq([])
      end

      it "has some data" do
        flapjack.given("a tag exists").
          upon_receiving("a GET request for all tags").
          with(:method => :get, :path => '/tags').
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => [tag_data]} )

        result = Flapjack::Diner.tags
        expect(result).to eq([tag_data])
      end

    end

    context 'GET a single tag' do

      it "has some data" do
        flapjack.given("a tag exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:name]}").
          will_respond_with(
            :status => 200,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:tags => tag_data} )

        result = Flapjack::Diner.tags(tag_data[:name])
        expect(result).to eq(tag_data)
      end

      it "can't find tag" do
        flapjack.given("no tag exists").
          upon_receiving("a GET request for tag 'www.example.com:SSH'").
          with(:method => :get, :path => "/tags/#{tag_data[:name]}").
          will_respond_with(
            :status => 404,
            :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
            :body => {:errors => [{
              :status => '404',
              :detail => "could not find Tag record, id: '#{tag_data[:name]}'"
            }]}
          )

        result = Flapjack::Diner.tags(tag_data[:name])
        expect(result).to be_nil
        expect(Flapjack::Diner.last_error).to eq([{:status => '404',
          :detail => "could not find Tag record, id: '#{tag_data[:name]}'"}])
      end

    end

  end

  # no tag updates allowed

  context 'delete' do
    it "submits a DELETE request for a tag" do
      flapjack.given("a tag exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:name]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:name])
      expect(result).to be_a(TrueClass)
    end

    it "submits a DELETE request for several tags" do
      flapjack.given("two tags exist").
        upon_receiving("a DELETE request for two tags").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:name]},#{tag_2_data[:name]}",
             :body => nil).
        will_respond_with(:status => 204,
                          :body => '')

      result = Flapjack::Diner.delete_tags(tag_data[:name], tag_2_data[:name])
      expect(result).to be_a(TrueClass)
    end

    it "can't find the tag to delete" do
      flapjack.given("no tag exists").
        upon_receiving("a DELETE request for a single tag").
        with(:method => :delete,
             :path => "/tags/#{tag_data[:name]}",
             :body => nil).
        will_respond_with(
          :status => 404,
          :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
          :body => {:errors => [{
            :status => '404',
            :detail => "could not find Tag records, ids: '#{tag_data[:name]}'"
          }]}
        )

      result = Flapjack::Diner.delete_tags(tag_data[:name])
      expect(result).to be_nil
      expect(Flapjack::Diner.last_error).to eq([{:status => '404',
        :detail => "could not find Tag records, ids: '#{tag_data[:name]}'"}])

    end
  end

end
