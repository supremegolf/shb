require 'spec_helper'
require 'tempfile'

describe Shb::Client do
  before do
    stub_request(:any, 'supremegolf.com')
  end

  it "does not debug by default" do
    shb = Shb::Client.new
    tmpfile = Tempfile.new('shb-debug')
    shb.class.config.debug_log = tmpfile.path
    expect(File).not_to receive(:open).with(tmpfile.path, 'a')
    shb.get('/')
  end

  it "debug to specified logfile" do
    shb = Shb::Client.new
    tmpfile = Tempfile.new('shb-debug')
    shb.class.config.debug = true
    shb.class.config.debug_log = tmpfile.path
    expect(File).to receive(:open).with(tmpfile.path, 'a').and_call_original
    shb.get('/')
  end

  it "debug to STDERR" do
    shb = Shb::Client.new
    tmpfile = Tempfile.new('shb-debug')
    shb.class.config.debug = true
    shb.class.config.debug_log = nil
    expect(STDERR).to receive(:puts).at_least(:twice).and_call_original
    shb.get('/')
  end


end
