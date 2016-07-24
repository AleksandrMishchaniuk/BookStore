class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :lockable
  #  devise  :omniauthable, :omniauth_providers => [:facebook]

  has_many :orders
  has_many :reviews
  has_one :shipping_address, class_name: 'Address', foreign_key: :shipping_for_user
  has_one :billing_address, class_name: 'Address', foreign_key: :billing_for_user

  rails_admin do
    object_label_method do
      :email
    end
  end

  def admin?
    ENV['ADMIN_EMAIL'] == self.email
  end

  def order_in_progress
    orders.find_by(order_state: OrderState.in_progress)
  end
end
