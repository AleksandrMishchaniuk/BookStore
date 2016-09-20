class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :lockable
   devise  :omniauthable, :omniauth_providers => [:facebook]

  has_many :orders
  has_many :reviews
  has_many :soc_auths
  has_one :shipping_address, class_name: 'Address', foreign_key: :shipping_for_user
  has_one :billing_address, class_name: 'Address', foreign_key: :billing_for_user

  rails_admin do
    object_label_method do
      :email
    end
    show do
      include_all_fields
      fields :billing_address, :shipping_address do
        pretty_value { bindings[:view].admin_pretty_address(value) if value }
      end
    end
  end

  def admin?
    ENV['ADMIN_EMAIL'] == self.email
  end

  def order_in_progress
    order = orders.in_progress
    (order.try(:id) && order.order_state)? order : nil
  end

  def data
    return nil if soc_auths.empty?
    soc_auths.reverse.inject({}) do |res, auth|
      if auth.try(:data) && auth.data.kind_of?(Hash)
        res.merge!(auth.data.delete_if{ |key, val| val.blank? })
      end
      res
    end
  end

end
