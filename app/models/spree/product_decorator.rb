module Spree
  module ProductDecorator
    class << self
      def prepended(klass)
        klass.has_many :ad_hoc_option_types, after_add: :attach_option_values

        # Each exclusion represents a disallowed combination of ad_hoc_option_values
        klass.has_many :ad_hoc_variant_exclusions, dependent: :destroy

        # allowed customizations
        klass.has_and_belongs_to_many :product_customization_types

        klass.make_permalink field: :slug
      end
    end

    def permalink
      slug
    end

    private

    def attach_option_values(ad_hoc_option_type)
      ad_hoc_option_type.option_type.option_values.each do |ov|
        ahot = Spree::AdHocOptionValue.new
        ahot.option_value_id = ov.id
        ahot.position = ov.position
        ahot.save
        ad_hoc_option_type.ad_hoc_option_values << ahot
      end
    end
  end
end

Spree::Product.prepend Spree::ProductDecorator
