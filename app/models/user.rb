class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :lockable

  #  devise  :omniauthable, :omniauth_providers => [:facebook]

  def admin?
    ENV['ADMIN_EMAIL'] == self.email
  end

end
