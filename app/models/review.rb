class Review < ActiveRecord::Base
  belongs_to :book

  rails_admin do
    edit do
      field :approved
    end
  end
end
