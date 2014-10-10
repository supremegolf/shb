require 'spec_helper'

describe Shb::Client do

  it "does not cycle the user agent" do
    stub_request(:any, 'supremegolf.com')
    shb = Shb::Client.new
    shb.config.cycle_user_agent = false

    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::USER_AGENT
    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::USER_AGENT
    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::USER_AGENT
  end

  it "cycles the user agent" do
    stub_request(:any, 'supremegolf.com')
    shb = Shb::Client.new
    shb.config.cycle_user_agent = true

    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::AGENT_ALIASES[0]
    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::AGENT_ALIASES[1]
    expect(shb.get('/').request.options[:headers]['User-Agent']).to eq Shb::AbstractClient::AGENT_ALIASES[2]
  end

end
