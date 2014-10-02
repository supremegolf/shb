module Shb
  class Client
    # http://rubyscale.com/blog/2012/09/24/being-classy-with-httparty/
    class << self
      def new(*args)
        Class.new(AbstractClient).new(*args)
      end
    end
  end
end
