require 'openssl'

module Clearance
  module PasswordStrategies
    module Blowfish
      extend ActiveSupport::Concern

      # Am I authenticated with given password?
      #
      # @param [String] plain-text password
      # @return [true, false]
      # @example
      #   user.authenticated?('password')
      def authenticated?(password)
        encrypted_password == encrypt(password)
      end

      protected

      def encrypt_password
        initialize_salt_if_necessary
        if password.present?
          self.encrypted_password = encrypt(password)
        end
      end

      def generate_hash(string)
        # TODO: 1.9 vs 1.8 testing
        cipher = OpenSSL::Cipher::Cipher.new('bf-cbc').encrypt
        cipher.key = Digest::SHA256.digest(salt)
        cipher.update(string) << cipher.final
      end

      def encrypt(string)
        generate_hash("--#{salt}--#{string}--")
      end

      def initialize_salt_if_necessary
        if salt.blank?
          self.salt = generate_random_code
        end
      end
    end
  end
end