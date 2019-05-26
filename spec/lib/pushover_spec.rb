require 'spec_helper'

describe Pushover do
  it "is expected to have a VERSION" do
    expect(Pushover::VERSION).not_to be_nil
  end
end
