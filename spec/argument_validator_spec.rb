require 'spec_helper'
require "flapjack-diner/argument_validator"

describe Flapjack::ArgumentValidator do

  let(:path) do
    {:entity => 'myservice', :check => 'HOST'}
  end

  let(:query) do
    {:start_time => Time.now, :duration => 10}
  end

  subject { Flapjack::ArgumentValidator.new(path, query) }

  context 'required' do
    it 'does not raise an exception when path entity is valid' do
      lambda { subject.validate(:path => :entity, :as => :required) }.should_not raise_exception(ArgumentError)
    end

    it 'raises ArgumentError when path entity is invalid' do
      path[:entity] = nil
      lambda { subject.validate(:path => :entity, :as => :required) }.should raise_exception(ArgumentError)
    end

    it 'handles arrays as path values valid' do
      lambda { subject.validate(:path => [:entity, :check], :as => :required) }.should_not raise_exception(ArgumentError)
    end

    it 'handles arrays as path values valid' do
      path[:check] = nil
      lambda { subject.validate(:path => [:entity, :check], :as => :required) }.should raise_exception(ArgumentError)
    end
  end

  context 'time' do
    it 'does not raise an exception when query start_time is valid' do
      lambda { subject.validate(:query => :start_time, :as => :time) }.should_not raise_exception(ArgumentError)
    end

    it 'raises an exception when query start_time is invalid' do
      query[:start_time] = 1234
      lambda { subject.validate(:query => :start_time, :as => :time) }.should raise_exception(ArgumentError)
    end

    it 'handles arrays as query values valid' do
      query[:end_time] = Time.now
      lambda { subject.validate(:query => [:start_time, :end_time], :as => :time) }.should_not raise_exception(ArgumentError)
    end

    it 'handles arrays as query values invalid' do
      query[:end_time] = 3904
      lambda { subject.validate(:query => [:start_time, :end_time], :as => :time) }.should raise_exception(ArgumentError)
    end

    it 'handles dates as query values' do
      query[:end_time] = Date.today
      lambda { subject.validate(:query => :end_time, :as => :time) }.should_not raise_exception(ArgumentError)
    end
  end

  context 'integer via method missing' do
    it 'does not raise an exception when query duration is valid' do
      lambda { subject.validate(:query => :duration, :as => :integer) }.should_not raise_exception(ArgumentError)
    end

    it 'raises an exception when query duration is invalid' do
      query[:duration] = '23'
      lambda { subject.validate(:query => :duration, :as => :integer) }.should raise_exception(ArgumentError)
    end
  end

  context 'multiple validations' do
    it 'does not raise an exception when query start_time is valid' do
      lambda { subject.validate(:query => :start_time, :as => [:time, :required]) }.should_not raise_exception(ArgumentError)
    end

    it 'raises an exception when query start_time is invalid' do
      query[:start_time] = nil
      lambda { subject.validate(:query => :start_time, :as => [:time, :required]) }.should raise_exception(ArgumentError)
    end
  end
end
