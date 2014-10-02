require 'spec_helper'

describe Shb::Client do

  it "does not use cookies" do
    stub_request(:any, 'supremegolf.com').to_return {|r| 
      { headers: {'Set-Cookie' => 'cookie123'} }
    }
    shb = Shb::Client.new
    shb.config.use_cookies = false

    expect(shb.get('/').request.options[:headers]['Cookie']).to be_nil
    expect(shb.get('/').request.options[:headers]['Cookie']).to be_nil
  end

  it "uses cookies" do
    stub_request(:any, 'supremegolf.com').to_return {|r| 
      { headers: {'Set-Cookie' => 'cookie123'} }
    }
    shb = Shb::Client.new
    shb.config.use_cookies = true

    expect(shb.get('/').request.options[:headers]['Cookie']).to be_nil
    expect(shb.get('/').request.options[:headers]['Cookie']).to eq 'cookie123'
  end

end
