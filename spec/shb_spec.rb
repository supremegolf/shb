require 'spec_helper'

describe Shb::Client do

  context "defaults" do
    specify { expect(Shb::Client.new.config.cache).to be_falsey }
    specify { expect(Shb::Client.new.config.cycle_user_agent).to be_falsey }
    specify { expect(Shb::Client.new.config.use_cookies).to be_falsey }
    specify { expect(Shb::Client.new.class.default_options[:parser]).to eq Shb::Parser }
    specify { expect(Shb::Client.new.class.default_options[:follow_redirects]).to be_falsey }
    specify { expect(Shb::Client.new.class.default_options[:headers]['User-Agent']).to eq Shb::AbstractClient::AGENT_ALIASES.first }
  end

  context "simple requests" do
    before do 
      stub_request(:any, 'supremegolf.com').to_return {|r| 
        {
          status:200, 
          body: r.method.to_s.downcase
        }
      }
    end
    let(:shb) { Shb::Client.new }

    specify { expect(shb.get('/').code).to eq 200 }
    specify { expect(shb.get('/').body).to eq "get" }
    specify { expect(shb.post('/').code).to eq 200 }
    specify { expect(shb.post('/').body).to eq "post" }
    specify { expect(shb.put('/').code).to eq 200 }
    specify { expect(shb.put('/').body).to eq "put" }
  end

  context "requests with data" do
    before do 
      stub_request(:any, 'supremegolf.com?q=1').to_return {|r| 
        { status:200, body: [r.uri.query, r.body].join('&') }
      }
    end
    let(:shb) { Shb::Client.new }

    specify { expect(shb.get('/', query: {q: 1}).body).to eq "q=1&" }
    specify { expect(shb.post('/', query: {q: 1}, body: {body: 1}).body).to eq "q=1&body=1" }
    specify { expect(shb.put('/', query: {q: 1}, body: {body: 1}).body).to eq "q=1&body=1" }
  end


end
