# :nodoc:
class SocAuth < ActiveRecord::Base
  serialize :data

  belongs_to :user

  rails_admin do
    list do
      exclude_fields :created_at, :updated_at
    end
  end
end
