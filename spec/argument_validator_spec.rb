require 'spec_helper'
require "flapjack-diner/argument_validator"

describe Flapjack::ArgumentValidator do

  context 'required' do

    let(:query) do
      {:name => 'HOST', :enabled => false}
    end

    subject { Flapjack::ArgumentValidator.new(query) }

    it 'does not raise an exception when query entity is valid' do
      expect { subject.validate(:query => :name, :as => :required) }.not_to raise_exception
    end

    it 'raises ArgumentError when query entity is invalid' do
      query[:name] = nil
      expect { subject.validate(:query => :name, :as => :required) }.to raise_exception
    end

    it 'handles arrays as query values valid' do
      expect { subject.validate(:query => [:name, :enabled], :as => :required) }.not_to raise_exception
    end

    it 'handles arrays as query values invalid' do
      query[:name] = nil
      expect { subject.validate(:query => [:name, :enabled], :as => :required) }.to raise_exception
    end
  end

  context 'time' do

    let(:query) do
      {:start_time => Time.now, :duration => 10}
    end

    subject { Flapjack::ArgumentValidator.new(query) }

    it 'does not raise an exception when query start_time is valid' do
      expect { subject.validate(:query => :start_time, :as => :time) }.not_to raise_exception
    end

    it 'raises an exception when query start_time is invalid' do
      query[:start_time] = 1234
      expect { subject.validate(:query => :start_time, :as => :time) }.to raise_exception
    end

    it 'handles arrays as query values valid' do
      query[:end_time] = Time.now
      expect { subject.validate(:query => [:start_time, :end_time], :as => :time) }.not_to raise_exception
    end

    it 'handles arrays as query values invalid' do
      query[:end_time] = 3904
      expect { subject.validate(:query => [:start_time, :end_time], :as => :time) }.to raise_exception
    end

    it 'handles dates as query values' do
      query[:end_time] = Date.today
      expect { subject.validate(:query => :end_time, :as => :time) }.not_to raise_exception
    end

    it 'handles ISO 8601 strings as query values' do
      query[:end_time] = Time.now.iso8601
      expect { subject.validate(:query => :end_time, :as => :time) }.not_to raise_exception
    end

    it 'raises an exception when invalid time strings are provided' do
      query[:end_time] = '2011-08-01T00:00'
      expect { subject.validate(:query => :end_time, :as => :time) }.to raise_exception
    end
  end

  context 'integer via method missing' do

    let(:query) do
      {:start_time => Time.now, :duration => 10}
    end

    subject { Flapjack::ArgumentValidator.new(query) }

    it 'does not raise an exception when query duration is valid' do
      expect { subject.validate(:query => :duration, :as => :integer) }.not_to raise_exception
    end

    it 'raises an exception when query duration is invalid' do
      query[:duration] = '23'
      expect { subject.validate(:query => :duration, :as => :integer) }.to raise_exception
    end
  end

  context 'multiple validations' do

    let(:query) do
      {:start_time => Time.now, :duration => 10}
    end

    subject { Flapjack::ArgumentValidator.new(query) }

    it 'does not raise an exception when query start_time is valid' do
      expect { subject.validate(:query => :start_time, :as => [:time, :required]) }.not_to raise_exception
    end

    it 'raises an exception when query start_time is invalid' do
      query[:start_time] = nil
      expect { subject.validate(:query => :start_time, :as => [:time, :required]) }.to raise_exception
    end
  end
end
