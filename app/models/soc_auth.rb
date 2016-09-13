class SocAuth < ActiveRecord::Base

  serialize :data

  belongs_to :user

end
