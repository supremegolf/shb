module Shb
  class Cache
    class << self

      def write(response, uri, options = {})
        file = cache_file(uri, options)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'w') do |f|
          f.puts YAML::dump(response.response)
        end
      end

      def read(method, uri, options = {})
        file = cache_file(uri, options)
        raise unless File.exist?(file)
        r = YAML::load_file(file)
        raise if r.content_type.nil?
        r
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

    end
  end
end
