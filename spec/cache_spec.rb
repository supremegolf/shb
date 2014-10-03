require 'spec_helper'

describe Shb::Client do
  before do
    stub_request(:any, 'supremegolf.com')
  end

  it "should test more than this" do
    shb = Shb::Client.new
    shb.config.cache = true
    shb.get('/')
    shb.get('/')
  end

end
