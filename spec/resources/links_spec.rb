require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Links, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  it 'adds a tag to a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a POST request adding a tag to a check").
      with(:method => :post, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:tags => tag_data[:name]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_checks_link_tags(check_data[:id], tag_data[:name])
    expect(result).to be true
  end

  it 'adds two tags to a check' do
    flapjack.given("a check and two tags exist").
      upon_receiving("a POST request adding two tags to a check").
      with(:method => :post, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:tags => [tag_data[:name], tag_2_data[:name]]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_checks_link_tags(check_data[:id],
      tag_data[:name], tag_2_data[:name])
    expect(result).to be true
  end

  it 'gets tags for a check' do
    flapjack.given("a check exists").
      upon_receiving("a GET request for all tags on a check").
      with(:method => :get, :path => "/checks/#{check_data[:id]}/links/tags").
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; charset=utf-8'},
        :body => {:tags => [tag_data]} )

    result = Flapjack::Diner.checks_link_tags(check_data[:id])
    expect(result).to eq([tag_data])
  end

  it 'updates tags for a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a PUT request updating tags for a check").
      with(:method => :put, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:tags => [tag_data[:name]]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_checks_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'deletes a tag from a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a DELETE request deleting a tag from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/links/tags/#{tag_data[:name]}",
           :body => nil).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_checks_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'deletes two tags from a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a DELETE request deleting two tags from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/links/tags/#{tag_data[:name]},#{tag_2_data[:name]}",
           :body => nil).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_checks_link_tags(check_data[:id],
      tag_data[:name], tag_2_data[:name])
    expect(result).to be true
  end

  it 'sets the contact for a medium' do
    flapjack.given("a contact and a medium exist").
      upon_receiving("a POST request adding a contact to a medium").
      with(:method => :post, :path => "/media/#{email_data[:id]}/links/contact",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:contact => contact_data[:id]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_media_link_contact(email_data[:id],
      contact_data[:id])
    expect(result).to be true
  end

  it 'updates the contact for a medium' do
    flapjack.given("a contact and a medium exist").
      upon_receiving("a PUT request updating the contact for a medium").
      with(:method => :put, :path => "/media/#{email_data[:id]}/links/contact",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:contact => contact_data[:id]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_media_link_contact(email_data[:id],
      contact_data[:id])
    expect(result).to be true
  end

  it 'deletes the contact from a rule' do
    flapjack.given("a contact and a rule exist").
      upon_receiving("a DELETE request deleting a contact from a rule").
      with(:method => :delete, :path => "/rules/#{rule_data[:id]}/links/contact/#{contact_data[:id]}",
           :body => nil).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_rules_link_contact(rule_data[:id],
      contact_data[:id])
    expect(result).to be true
  end

end
