class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :order_state
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :shipping_address
  belongs_to :billing_address, class_name: 'Address', foreign_key: :billing_address
  belongs_to :credit_card
  belongs_to :delivery
  has_many :carts
  has_many :books, through: :carts
  has_one  :coupon

  validates :carts, presence: true

  scope :in_progress, -> { find_by(order_state: OrderState.in_progress) }
  scope :in_queue, -> { where(order_state: OrderState.in_queue) }
  scope :in_delivery, -> { where(order_state: OrderState.in_delivery) }
  scope :delivered, -> { where(order_state: OrderState.delivered) }

  after_create :set_coupon_after_save

  rails_admin do
    list do
      exclude_fields :carts, :credit_card, :created_at, :updated_at
    end
    show do
      include_all_fields
      field :billing_address
      field :shipping_address
      field :number do
        label I18n.t('checkout.order.show.order_number')
      end
      field :item_total do
        label I18n.t('views.partials.cart_table.subtotal').mb_chars.capitalize
      end
      field :item_discount do
        label I18n.t('activerecord.attributes.coupon.discount').mb_chars.capitalize
      end
      field :item_total_with_discount do
        label I18n.t('views.partials.cart_table.subtotal_with_discount').mb_chars.capitalize
      end
      field :order_total do
        label I18n.t('views.partials.cart_table.order_total').mb_chars.capitalize
      end
      field :carts do
        pretty_value { bindings[:view].admin_cart_table(value) }
      end
      fields :billing_address, :shipping_address do
        pretty_value { bindings[:view].admin_pretty_address(value) if value }
      end
      field :credit_card do
        pretty_value { bindings[:view].admin_pretty_credit_card(value) if value }
      end
      fields :item_discount, :item_total_with_discount do
        visible { bindings[:object].coupon }
      end
      fields :item_total, :order_total, :item_discount, :item_total_with_discount do
        pretty_value { bindings[:view].formated_price(value) }
      end
      exclude_fields :books
    end
    edit do
      field :order_state
    end
  end

  alias :cart_items :carts

  def item_total
    cart_items.inject(0) { |sum, item| sum + item.total_price }.to_f
  end

  def item_discount
    return 0 unless coupon
    item_total * coupon.discount
  end

  def item_total_with_discount
    item_total - item_discount
  end

  def order_total
    item_total_with_discount + ( delivery.try(:price) || 0 )
  end

  def number
    "R#{created_at.strftime("%Y%m%d")}#{id}"
  end

  def save_to_progress
    return false unless save
    unless cart_items.empty?
      cart_items.each { |item| item.save! }
    end
    true
  end

  def delete_from_progress
    unless cart_items.empty?
      cart_items.each { |item| item.destroy! }
    end
    destroy!
  end

  def ==(another)
    attributes == another.attributes && cart_items == another.cart_items
  end

  def coupon
    (persisted?)? super : get_coupon_from_session
  end

  def coupon_id
    coupon.try(:id)
  end

  def coupon=(object)
    return if object == coupon
    raise 'Object shoult be Coupon or NilClass' unless object.kind_of?(Coupon) || object.nil?
    detach_coupon
    object.attach if object
    if persisted?
      super(object)
    else
      save_coupon_to_session(object)
    end
  end

  def detach_coupon
    coupon.detach if coupon
    clear_coupon_in_session
  end

  protected

  def session
    Thread.current[:session]
  end

  def save_coupon_to_session(object)
    session[:coupon_id] = (object)? object.id : nil
  end

  def get_coupon_from_session
    (session[:coupon_id])? Coupon.find(session[:coupon_id]) : nil
  end

  def clear_coupon_in_session
    session[:coupon_id] = nil
  end

  def set_coupon_after_save
    if get_coupon_from_session
      update_attributes(coupon: get_coupon_from_session)
    end
  end

end
