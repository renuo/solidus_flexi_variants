module Spree
  module LineItemDecorator
    class << self
      def prepended(klass)
        klass.has_many :ad_hoc_option_values_line_items, dependent: :destroy
        klass.has_many :ad_hoc_option_values, through: :ad_hoc_option_values_line_items
        klass.has_many :product_customizations, dependent: :destroy
      end
    end

    def options_text # REFACTOR
      if customized?
        str = []

        ad_hoc_opt_values = ad_hoc_option_values.sort_by(&:position)
        ad_hoc_option_values.sort_by(&:position).each do |pov|
          str << "#{pov.option_value.option_type.presentation} = #{pov.option_value.presentation}"
        end

        product_customizations.each do |customization|
          price_adjustment = customization.price == 0 ? '' : " (#{Spree::Money.new(customization.price)})"
          customization_type_text = "#{customization.product_customization_type.presentation}#{price_adjustment}"
          opts_text = customization.customized_product_options.map(&:display_text).join(', ')
          str << customization_type_text + ": #{opts_text}"
        end

        str.join('\n')
      else
        variant.options_text
      end
    end

    def customized?
      product_customizations.present? || ad_hoc_option_values.present?
    end

    def cost_price
      (variant.cost_price || 0) + ad_hoc_option_values.map(&:cost_price).sum
    end

    def cost_money
      Spree::Money.new(cost_price, currency: currency)
    end

    def add_customizations(product_customizations_values)
      self.product_customizations = product_customizations_values
      product_customizations_values.each { |product_customization| product_customization.line_item = self }
      product_customizations_values.map(&:save) # it is now safe to save the customizations we built
      customizations_offset_price = product_customizations_values.map { |product_customization| product_customization.price(variant) }.compact.sum
      customizations_offset_price
    end

    def add_ad_hoc_option_values(ad_hoc_option_value_ids)
      product_option_values = ad_hoc_option_value_ids.map do |cid|
        Spree::AdHocOptionValue.find(cid) if cid.present?
      end.compact
      self.ad_hoc_option_values = product_option_values
      ad_hoc_options_offset_price = product_option_values.map(&:price_modifier).compact.sum
      ad_hoc_options_offset_price
    end
  end
end

Spree::LineItem.prepend Spree::LineItemDecorator
