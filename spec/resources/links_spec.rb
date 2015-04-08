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
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
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
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'},
                               {:id => tag_2_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_checks_link_tags(check_data[:id],
      tag_data[:name], tag_2_data[:name])
    expect(result).to be true
  end

  it 'gets tags for a check' do
    flapjack.given("a check with a tag exists").
      upon_receiving("a GET request for all tags on a check").
      with(:method => :get, :path => "/checks/#{check_data[:id]}/tags").
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
        :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]})

    result = Flapjack::Diner.checks_link_tags(check_data[:id])
    expect(result).to eq([{:id => tag_data[:name], :type => 'tag'}])
  end

  it 'updates tags for a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a PATCH request updating tags for a check").
      with(:method => :patch, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_checks_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'clears all tags from a check'

  it 'deletes a tag from a check' do
    flapjack.given("a check with a tag exists").
      upon_receiving("a DELETE request deleting a tag from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_checks_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'deletes two tags from a check' do
    flapjack.given("a check with two tags exists").
      upon_receiving("a DELETE request deleting two tags from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/links/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'},
                               {:id => tag_2_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_checks_link_tags(check_data[:id],
      tag_data[:name], tag_2_data[:name])
    expect(result).to be true
  end

  it 'gets the contact for a medium'

  it 'sets the contact for a medium' do
    flapjack.given("a contact and a medium exist").
      upon_receiving("a PATCH request updating the contact for a medium").
      with(:method => :patch, :path => "/media/#{email_data[:id]}/links/contact",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => {:id => contact_data[:id], :type => 'contact'}}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_media_link_contact(email_data[:id],
      contact_data[:id])
    expect(result).to be true
  end

  it 'clears the contact from a rule' do
    flapjack.given("a contact with a rule exists").
      upon_receiving("a PATCH request clearing a contact from a rule").
      with(:method => :patch, :path => "/rules/#{rule_data[:id]}/links/contact",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => nil}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_rules_link_contact(rule_data[:id], nil)
    expect(result).to be true
  end

end
