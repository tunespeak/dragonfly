# encoding: utf-8
require 'base64'
require 'multi_json'
require 'dragonfly/utils'

module Dragonfly
  module Serializer

    # Exceptions
    class BadString < RuntimeError; end
    class MaliciousString < RuntimeError; end

    extend self # So we can do Serializer.b64_encode, etc.

    def b64_encode(string)
      Base64.urlsafe_encode64(string)
    end

    def b64_decode(string)
      Base64.urlsafe_decode64(string)
    end

    def marshal_b64_encode(object)
      b64_encode(Marshal.dump(object))
    end

    def marshal_b64_decode(string, opts={})
      marshal_string = b64_decode(string)
      raise MaliciousString, "potentially malicious marshal string #{marshal_string.inspect}" if opts[:check_malicious] && marshal_string[/@[a-z_]/i]
      Marshal.load(marshal_string)
    rescue TypeError, ArgumentError => e
      raise BadString, "couldn't marshal decode string - got #{e}"
    end

    def json_encode(object)
      MultiJson.encode(object)
    end

    def json_decode(string)
      raise BadString, "can't decode blank string" if Utils.blank?(string)
      MultiJson.decode(string)
    rescue MultiJson::DecodeError => e
      raise BadString, "couldn't json decode string - got #{e}"
    end

    def json_b64_encode(object)
      b64_encode(json_encode(object))
    end

    def json_b64_decode(string)
      json_decode(b64_decode(string))
    end

  end
end
