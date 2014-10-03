module Shb
  class AbstractClient

    include ActiveSupport::Configurable
    include HTTParty

    AGENT_ALIASES = [
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.71 (KHTML, like Gecko) Version/6.1 Safari/537.71', # Safari on OSX Lion
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko) Version/7.0 Safari/537.71', # Safari on OSX Mavericks
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:17.0) Gecko/20100101 Firefox/17.0', # Firefox on Mac
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36', # Chrome on Mac
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.66 Safari/537.36', # Chrome on Windows 7
      'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)', # IE10 on Windows 7
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0', # Firefox on Windows 7
    ]

    config.cache = !!(ENV['SHB_CACHE'] =~ /^[T1Y]/i) # TRUE, 1, YES
    config.cache_class = ::Shb::Cache
    config.cycle_user_agent = false
    config.use_cookies = false
    config.logger = nil

    parser ::Shb::Parser
    follow_redirects false
    headers 'User-Agent' => AGENT_ALIASES.first

    def initialize(base_uri: 'http://supremegolf.com')
      self.class.base_uri base_uri
      @root_uri = URI.parse(self.class.base_uri.to_s)
    end

    def get(path, options = {}, &block)
      make_request!(:get, path, options, &block)
    end

    def post(path, options = {}, &block)
      make_request!(:post, path, options, &block)
    end

    def put(path, options = {}, &block)
      make_request!(:put, path, options, &block)
    end

    ################################################################################
    private

    #
    def make_request!(method, path, options = {}, &block)
      uri = path_to_uri(path)
      if (response = cache_read(method, uri, options)).nil?
        log_request!(method, uri, options)
        cycle_user_agent!
        set_cookies!
        response = self.class.send(method, uri.to_s, options, &block)
        save_cookies!(response)
        cache_write(response, uri, options)
      end
      response
    rescue SocketError, Net::ReadTimeout => e
      logger.error "ERROR #{e.inspect} : uri=#{uri}"
      sleep 60
      retry
    end

    #
    def path_to_uri(path)
      @root_uri.merge(path.to_s.gsub(' ', '%20'))
    end

    #
    def log_request!(method, uri, options)
      logger.info "#{method.to_s.upcase} #{uri.to_s}#{options[:query].nil? ? nil : "?#{HashConversions.to_params(options[:query])}"}"
    end

    #
    def cycle_user_agent!
      return unless config.cycle_user_agent
      @user_agent_alias_idx ||= 0
      self.class.headers('User-Agent' => AGENT_ALIASES[@user_agent_alias_idx])
      @user_agent_alias_idx += 1
      @user_agent_alias_idx %= AGENT_ALIASES.size
    end

    #
    def set_cookies!
      return unless config.use_cookies && !@cookies.nil?
      self.class.headers('Cookie' => @cookies)
    end

    #
    def save_cookies!(response)
      return unless config.use_cookies
      @cookies = response.headers['set-cookie']
    end

    #
    def logger
      return @logger unless @logger.nil?

      @logger = if config.logger
                  ::Logger.new(config.logger)
                elsif defined?(::Rails)
                  ::Logger.new( File.join(::Rails.root, 'log', 'shb.log') )
                else
                  ::Logger.new(STDERR)
                end

      @logger.formatter = proc do |severity, datetime, progname, msg|
        "%-7s [%s] -- %s\n" % [severity, datetime, msg]
      end

      @logger
    end

    #
    def cache_write(response, uri, options = {})
      return true unless config.cache
      return true if response.code >= 400 # Don't cache bad responses
      config.cache_class.write(response, uri, options)
    end

    def cache_read(method, uri, options = {})
      return nil unless config.cache

      logger.info "#{method.to_s.upcase} CACHE #{uri.to_s}#{method == :get && !options[:query].to_s.empty? ? "?#{HashConversions.to_params(options[:query])}" : nil}"

      response = config.cache_class.read(method, uri, options)

      return nil if response.nil?

      HTTParty::Response.new(OpenStruct.new(options:options), response,
         ->{ self.class.parser.call(response.body, options[:format] || self.class.parser.format_from_mimetype(response.content_type)) }, 
         body: response.body)

    end

  end # of class AbstractClient
end
