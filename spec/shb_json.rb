require 'spec_helper'

describe Shb::Client do
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
