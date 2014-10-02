require 'spec_helper'

describe Shb::Client do
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
