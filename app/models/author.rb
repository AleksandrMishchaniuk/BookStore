# :nodoc:
class Author < ActiveRecord::Base
  has_and_belongs_to_many :books

  validates :first_name,  presence: true, length: { maximum: 64 }
  validates :last_name,                   length: { maximum: 64 }

  def name
    first_name.to_s + ' ' + last_name.to_s
  end

  rails_admin do
    list do
      exclude_fields :created_at, :updated_at
    end
  end
end
