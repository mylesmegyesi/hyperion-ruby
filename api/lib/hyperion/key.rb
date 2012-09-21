require 'base64'
require 'uuidtools'

module Hyperion
  class Key
    class << self

      def encode_key(value)
        normalize(encode(value))
      end

      def decode_key(value)
        decode(denormalize(value))
      end

      def compose_key(kind, id=nil)
        _id = id.nil? || id.to_s.strip == "" ? generate_id : id.to_s
        encode_key("#{encode_key(kind.to_s)}:#{encode_key(_id)}")
      end

      def decompose_key(key)
        decode_key(key).split(/:/).map {|part| decode_key(part)}
      end

      def generate_id
        UUIDTools::UUID.random_create.to_s.gsub(/-/, '')
      end

      private

      def encode(str)
        [str].pack('m').tr('+/','-_').gsub("\n",'')
      end

      def decode(str)
        str.tr('-_','+/').unpack('m')[0]
      end

      def normalize(value)
        value.chomp.gsub(/=/, '')
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
