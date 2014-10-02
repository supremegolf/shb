require 'nokogiri'
require 'json'

module Shb
  class Parser < HTTParty::Parser
    SupportedFormats.merge!(
      'text/html'           => :html,
      'text/xml'            => :xml,
      'application/jsonnet' => :json,
      'application/json'    => :json
    )

    def html
      Nokogiri::HTML(body)
    end

    def xml
      Nokogiri::XML(body)
    end

    def json
      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end
  end
end
