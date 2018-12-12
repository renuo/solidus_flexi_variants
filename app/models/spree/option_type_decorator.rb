module Spree
  module OptionTypeDecorator
    class << self
      def prepended(klass)
        klass.has_many :ad_hoc_option_types, dependent: :destroy
      end
    end
  end
end

Spree::OptionType.prepend Spree::OptionTypeDecorator
