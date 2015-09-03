require 'spec_helper'
require 'flapjack-diner'

describe Flapjack::Diner::Resources::Relationships, :pact => true do

  before(:each) do
    Flapjack::Diner.base_uri('localhost:19081')
    Flapjack::Diner.logger = nil
  end

  it 'adds a tag to a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a POST request adding a tag to a check").
      with(:method => :post, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_check_link_tags(check_data[:id], tag_data[:name])
    expect(result).to be true
  end

  it 'adds two tags to a check' do
    flapjack.given("a check and two tags exist").
      upon_receiving("a POST request adding two tags to a check").
      with(:method => :post, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'},
                               {:id => tag_2_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.create_check_link_tags(check_data[:id],
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

    result = Flapjack::Diner.check_link_tags(check_data[:id])
    expect(result).to eq([{:id => tag_data[:name], :type => 'tag'}])
  end

  it 'gets tags for a check with full tag records' do
    included_data = [
      tag_json(tag_data).merge(:relationships => tag_rel(tag_data))
    ]

    flapjack.given("a check with a tag exists").
      upon_receiving("a GET request for all tags on a check, with full tag records").
      with(:method => :get,
           :path => "/checks/#{check_data[:id]}/tags",
           :query => "include=tags").
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
        :body => {:data => [{:id => tag_data[:name], :type => 'tag'}],
                  :included => included_data})

    result = Flapjack::Diner.check_link_tags(check_data[:id], :include => 'tags')
    expect(result).to eq([{:id => tag_data[:name], :type => 'tag'}])
    expect(Flapjack::Diner.context[:included]).to eq([resultify(included_data[0])])
  end

  it 'gets tags for a check with full tag and rule record' do
    included_data = [
      tag_json(tag_data).merge(:relationships => tag_rel(tag_data)),
      rule_json(rule_data).merge(:relationships => rule_rel(rule_data))
    ]

    flapjack.given("a check with a tag and a rule exists").
      upon_receiving("a GET request for all tags on a check, with full tag and rule records").
      with(:method => :get,
           :path => "/checks/#{check_data[:id]}/tags",
           :query => 'include=tags.rules').
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
        :body => {:data => [{:id => tag_data[:name], :type => 'tag'}],
                  :included => included_data})

    result = Flapjack::Diner.check_link_tags(check_data[:id], :include => 'rules')
    expect(result).to eq([{:id => tag_data[:name], :type => 'tag'}])
    expect(Flapjack::Diner.context[:included]).to eq([resultify(included_data[0]),
      resultify(included_data[1])])
  end

  it 'updates tags for a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a PATCH request updating tags for a check").
      with(:method => :patch, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_check_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'clears all tags from a check' do
    flapjack.given("a check and a tag exist").
      upon_receiving("a PATCH request clearing tags for a check").
      with(:method => :patch, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => []}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.update_check_link_tags(check_data[:id], [])
    expect(result).to be true
  end

  it 'deletes a tag from a check' do
    flapjack.given("a check with a tag exists").
      upon_receiving("a DELETE request deleting a tag from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_check_link_tags(check_data[:id],
      tag_data[:name])
    expect(result).to be true
  end

  it 'deletes two tags from a check' do
    flapjack.given("a check with two tags exists").
      upon_receiving("a DELETE request deleting two tags from a check").
      with(:method => :delete, :path => "/checks/#{check_data[:id]}/relationships/tags",
           :headers => {'Content-Type' => 'application/vnd.api+json'},
           :body => {:data => [{:id => tag_data[:name], :type => 'tag'},
                               {:id => tag_2_data[:name], :type => 'tag'}]}).
      will_respond_with(:status => 204,
                        :body => '')

    result = Flapjack::Diner.delete_check_link_tags(check_data[:id],
      tag_data[:name], tag_2_data[:name])
    expect(result).to be true
  end

  it 'gets the contact for a medium' do
    flapjack.given("a contact with a medium exists").
      upon_receiving("a GET request for a medium's contact").
      with(:method => :get, :path => "/media/#{email_data[:id]}/contact").
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
        :body => {:data => {:id => contact_data[:id], :type => 'contact'}})

    result = Flapjack::Diner.medium_link_contact(email_data[:id])
    expect(result).to eq(:id => contact_data[:id], :type => 'contact')
  end

  it "doesn't duplicate linked data references in included data" do
    resp_check = check_json(check_data).merge(:relationships => check_rel(check_data))
    resp_check[:relationships][:current_state][:data] = {
      :type => 'state', :id => state_data[:id]
    }

    # NB: this is missing from the first piece of data in the pact response,
    # but it's included in the spec-breaking *second* included check data record :(
    resp_check[:relationships][:latest_notifications][:data] = [
      {:type => 'state', :id => state_data[:id]}
    ]

    sd = state_data.delete_if {|k, _| [:created_at, :updated_at].include?(k)}

    included_data = [
      resp_check,
      state_json(sd).merge(:relationships => state_rel(sd)),
    ]

    flapjack.given("a check with a tag, current state and a latest notification exists").
      upon_receiving("a GET request for a check's ").
      with(:method => :get,
           :path => "/tags/#{tag_data[:name]}/checks",
           :query => 'include=checks.current_state%2Cchecks.latest_notifications').
      will_respond_with(
        :status => 200,
        :headers => {'Content-Type' => 'application/vnd.api+json; supported-ext=bulk; charset=utf-8'},
        :body => {
          :data => [
            {:id => check_data[:id], :type => 'check'},
          ],
          :included => included_data
        })

    result = Flapjack::Diner.tag_link_checks(tag_data[:name],
      :include => ['checks.current_state', 'checks.latest_notifications'])
    expect(result).to eq([
      {:id => check_data[:id], :type => 'check'}
    ])
    expect(Flapjack::Diner.context[:included]).to eq(
      included_data.map {|d| resultify(d) }
    )
  end

end
