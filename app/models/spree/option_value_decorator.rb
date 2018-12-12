Spree::OptionValue.class_eval do
  has_many :ad_hoc_option_values, dependent: :destroy

  has_attached_file :attachment,
                    styles: { mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>' },
                    default_style: :product,
                    url: '/spree/options/:id/:style/:basename.:extension',
                    path: ':rails_root/public/spree/options/:id/:style/:basename.:extension',
                    default_url: 'noimage/:style.png'

  validates_attachment :attachment, content_type: { content_type: %r{\Aimage/.*\Z} }
end
