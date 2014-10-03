require 'spec_helper'

describe Shb::Client do
  before do
    stub_request(:any, 'supremegolf.com')
  end

  it "logs to STDERR by default" do
    expect(::Logger).to receive(:new).with(STDERR).and_call_original
    shb = Shb::Client.new
    shb.get('/')
  end

  it "logs to custom location if specified" do
    expect(::Logger).to receive(:new).with(STDOUT).and_call_original
    shb = Shb::Client.new
    shb.config.logger = STDOUT
    shb.get('/')
  end

  it "logs to Rails.root/tmp/shb.log if using Rails" do
    skip "How to double ::Rails and ::Rails.root?"
    shb = Shb::Client.new
    expect(::Logger).to receive(:new).with('rails-root/log/shb.log').and_call_original
    shb.get('/')
  end


end
