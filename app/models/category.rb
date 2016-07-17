class Category < ActiveRecord::Base
  has_and_belongs_to_many :books

  validates :name,  presence: true, length: {maximum: 128}

  class << self
    def items_for_navigation
      all.map do |categ|
        "category.item \"#{categ.name}\", \"#{categ.name}\", 'shop/categories/#{categ.id}'"
      end.join("\n ")
    end
  end
end
