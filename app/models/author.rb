class Author < ActiveRecord::Base
  has_and_belongs_to_many :books

  validates :first_name,  presence: true, length: {maximum: 64}
  validates :last_name,                   length: {maximum: 64}

  def full_name
    first_name.to_s + " " + last_name.to_s
  end

  rails_admin do
    object_label_method do
      :full_name
    end
  end
end
