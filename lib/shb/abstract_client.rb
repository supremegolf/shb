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
    config.cycle_user_agent = false
    config.use_cookies = false

    parser ::Shb::Parser
    follow_redirects false
    headers 'User-Agent' => AGENT_ALIASES.first

    def initialize(base_uri: 'http://supremegolf.com')
      self.class.base_uri base_uri
      @root_uri = URI.parse(self.class.base_uri.to_s)
      @cookies = nil
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

    def absolute_url(path)
      @root_uri.merge path.to_s.gsub(' ', '%20')
    end

    ################################################################################
    private

    #
    def make_request!(method, path, options = {}, &block)
      path = absolute_url(path)
      if (response = cache_read(method, path, options)).nil?
        logger.info "#{method.to_s.upcase} #{path.to_s}#{options[:query].nil? ? nil : "?#{HashConversions.to_params(options[:query])}"}"
        if config.cycle_user_agent
          self.class.headers('User-Agent' => AGENT_ALIASES.shuffle.first)
        end
        if config.use_cookies && !@cookies.nil?
          self.class.headers('Cookie' => URI.unescape(@cookies.map{|c| [c.name, c.value].join('=') }.join(';') ))
        end
        response = self.class.send(method, path.to_s, options, &block)
        @cookies = begin 
                     HTTP::CookieJar.new.parse(response.headers['set-cookie'], path)
                   rescue
                     nil
                   end
        cache_write(response, path, options)
      end
      response
    rescue SocketError, Net::ReadTimeout => e
      logger.error "ERROR #{e.inspect} : path=#{path}"
      sleep 60
      retry
    end

    #
    def logger
      return @logger unless @logger.nil?
      # TODO @logger = ::Logger.new( File.join(Rails.root, 'log', 'shb.log') )
      @logger = ::Logger.new(STDERR)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "%-7s [%s] -- %s\n" % [severity, datetime, msg]
      end
      @logger
    end

    #
    def cache_write(response, path, options = {})
      return true unless config.cache
      return true if response.code >= 400 # Don't cache bad responses

      file = cache_file(path, options)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') do |f|
        f.puts YAML::dump(response.response)
      end
    end

    def cache_read(method, path, options = {})
      raise unless config.cache

      file = cache_file(path, options)
      raise unless File.exist?(file)
      logger.info "#{method.to_s.upcase} CACHE #{path.to_s}#{method == :get && !options[:query].empty? ? "?#{HashConversions.to_params(options[:query])}" : nil}"
      r = YAML::load_file(file)
      raise if r.content_type.nil?
      HTTParty::Response.new(OpenStruct.new(options:options), r,
                             ->{ ShbParser.call(r.body, options[:format] || ShbParser.format_from_mimetype(r.content_type)) }, 
                             body: r.body)
    rescue 
      nil
    end

    def cache_file(uri, options = {})
      bits = [Rails.root]
      bits << 'tmp'
      bits << uri.host
      path = uri.path == '/' ? 'ROOT' : uri.path.parameterize
      query = options.empty? ? nil : "?#{HashConversions.to_params(options)}"
      bits << Digest::MD5.hexdigest([path,uri.fragment,uri.query,query].join)
      File.join(bits)
    end

  end # of class AbstractClient
end
