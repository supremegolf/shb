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

  context "requests with data", :focus do
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

  context "JSON requests" do
    before do 
      stub_request(:any, 'supremegolf.com').to_return {|r| 
        {
          body: '{"one":1}', 
          headers: {'Content-Type' => 'application/json'}
        }
      }
      stub_request(:any, 'supremegolf.com/bad-json').to_return {|r| 
        {
          body: '{missing_first_double_quote":1}', 
          headers: {'Content-Type' => 'application/json'}
        }
      }
    end
    let(:shb) { Shb::Client.new }

    specify { expect(shb.get('/').parsed_response).to be_a Hash }
    specify { expect(shb.get('/').parsed_response['one']).to eq 1 }
    specify { expect(shb.get('/bad-json').parsed_response).to eq nil }
  end

  context "XML requests" do
    before do 
      stub_request(:any, 'supremegolf.com').to_return {|r| 
        {
          body: '<xml><title>Test</title></xml>', 
          headers: {'Content-Type' => 'text/xml'}
        }
      }
    end
    let(:shb) { Shb::Client.new }

    specify { expect(shb.get('/').parsed_response).to be_a Nokogiri::XML::Document }
    specify { expect(shb.get('/').parsed_response.at('title').text).to eq 'Test' }
  end

  context "HTML requests" do
    before do 
      stub_request(:any, 'supremegolf.com').to_return {|r| 
        {
          body: '<html><title>Test</title></html>', 
          headers: {'Content-Type' => 'text/html'}
        }
      }
    end
    let(:shb) { Shb::Client.new }

    specify { expect(shb.get('/').parsed_response).to be_a Nokogiri::HTML::Document }
    specify { expect(shb.get('/').parsed_response.at('title').text).to eq 'Test' }
  end


end
