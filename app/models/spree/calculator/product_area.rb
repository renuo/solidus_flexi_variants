module Spree
  class Calculator::ProductArea < Calculator
    preference :multiplier, :decimal

    preference :min_pricing_area, :integer # the minimum size we'll use for pricing (we might sell you a 4x4, but we'll charge u for a 10x10

    preference :min_width, :integer, default: 0
    preference :max_width, :integer, default: 100

    preference :min_height, :integer, default: 0
    preference :max_height, :integer, default: 100

    # preference :min_area, :integer  # the minimum sized frame we'll sell

    # these can be reflected in the custom partials?
    #  preference :measurement_units, :string, default: 'inches'
    #  preference :granularity, :string, default: 'eighths'

    def self.description
      'Product Area Calculator'
    end

    def self.register
      super
      ProductCustomizationType.register_calculator(self)
    end

    def create_options
      # This calculator knows that it needs two CustomizableOptions, width & height
      [
        CustomizableProductOption.create(name: 'width', presentation: 'Width'),
        CustomizableProductOption.create(name: 'height', presentation: 'Height')
      ]
    end

    # as object we always get line items, as calculable we have Coupon, ShippingMethod
    def compute(product_customization, _variant = nil)
      return 0 unless valid_configuration? product_customization

      width = get_option(product_customization, 'width')
      height = get_option(product_customization, 'height')

      # here's the custom logic for this calculator:  min total width + height = 20.
      [(width.value.to_f * height.value.to_f), (preferred_min_pricing_area || 0)].max * (preferred_multiplier || 0)
    end

    def valid_configuration?(product_customization)
      # expecting exactly two CustomizedProductOptions

      all_opts = product_customization.customized_product_options.map { |cpo| cpo.customizable_product_option.name }

      # do we have the necessary inputs?
      has_inputs = all_opts.include?('width') && all_opts.include?('height')

      # do the inputs meet the criteria?
      width = get_option(product_customization, 'width')
      height = get_option(product_customization, 'height')

      #    return has_inputs && width && height && (width.value.to_f * height.value.to_f) >= preferred_min_area

      #    rescue false
      width.value || height.value
    end

    private

    def get_option(product_customization, name)
      product_customization.customized_product_options.detect { |cpo| cpo.customizable_product_option.name == name }
    end
  end
end
