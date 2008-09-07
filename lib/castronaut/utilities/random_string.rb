require File.expand_path(File.dirname(__FILE__) + '../../../../vendor/isaac/crypt/ISAAC.rb')

module Castronaut
  module Utilities
    class RandomString
      MagicNumber = 4_294_619_050

      def self.generate(max_length = 29)
        isaac = ::Crypt::ISAAC.new
        random_numbers = [isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber),
                          isaac.rand(MagicNumber)]

        random_string = "#{Time.now.to_i}r%X%X%X%X%X%X%X%X" % random_numbers
        random_string[0..max_length-1]
      end
    end
  end
end
