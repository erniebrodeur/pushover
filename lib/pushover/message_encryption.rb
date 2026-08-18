require 'base64'
require 'openssl'
require 'securerandom'
require 'stringio'
require 'zlib'

module Pushover
  # MessageEncryption implements Pushover's end-to-end encryption wire format.
  class MessageEncryption
    FIELDS = %i[message title url url_title].freeze

    def initialize(hexadecimal_key)
      @key = [hexadecimal_key].pack('H*')
    end

    def encrypt(params)
      params.merge(encrypted: 1).tap do |encrypted|
        FIELDS.each { |field| encrypted[field] = encrypt_field(params[field]) if params.key?(field) }
      end
    end

    private

    def encrypt_field(plaintext)
      iv = SecureRandom.random_bytes(16)
      encryptor = cipher(iv)
      ciphertext = encryptor.update(compress(plaintext)) + encryptor.final
      hmac = OpenSSL::HMAC.digest('SHA256', @key, iv + ciphertext)
      Base64.strict_encode64(iv + ciphertext + hmac)
    end

    def cipher(initialization_vector)
      OpenSSL::Cipher.new('aes-256-cbc').encrypt.tap do |cipher|
        cipher.key = @key
        cipher.iv = initialization_vector
      end
    end

    def compress(plaintext)
      output = StringIO.new(''.b)
      writer = Zlib::GzipWriter.new(output, Zlib::BEST_COMPRESSION)
      writer.mtime = 0
      writer.write(plaintext)
      writer.close
      output.string
    end
  end
end
