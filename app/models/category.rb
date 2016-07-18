class Category < ActiveRecord::Base
  has_and_belongs_to_many :books

  validates :name,  presence: true, length: {maximum: 128}

  class << self
    def items_for_navigation(css_class)
      all.map do |categ|
        "category.item \"#{categ.name}\", \"#{categ.name}\", '/shop/categories/#{categ.id}', html: {class: '#{css_class}'}"
      end.join("\n ")
    end
  end
end
