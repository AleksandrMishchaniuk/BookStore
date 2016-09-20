module OrderAdmin
  extend ActiveSupport::Concern

  included do
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
        field :order_state do
          associated_collection_scope do
            Proc.new do |scope|
              scope = scope.where.not(id_of_state: OrderState.in_progress.id)
            end
          end
        end
      end
    end
  end

end
