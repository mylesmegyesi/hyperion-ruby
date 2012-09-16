require 'base64'
require 'uuidtools'

module Hyperion
  class Key
    class << self

      def encode_key(value)
        normalize(Base64.encode64(value))
      end

      def decode_key(value)
        Base64.decode64(denormalize(value))
      end

      def compose_key(kind, id=nil)
        _id = id.nil? || id.to_s.strip == "" ? generate_id : id.to_s
        encode_key("#{encode_key(kind.to_s)}:#{encode_key(_id)}")
      end

      def decompose_key(key)
        decode_key(key).split(/:/).map {|part| decode_key(part)}
      end

      private

      def generate_id
        UUIDTools::UUID.random_create.to_s.gsub(/-/, '')
      end

      def normalize(value)
        value.gsub(/=/, '').chomp
      end

      def denormalize(value)
        case value.length % 4
        when 3
          "#{value}="
        when 2
          "#{value}=="
        when 1
          "#{value}==="
        else
          value
        end
      end

    end
  end
end
