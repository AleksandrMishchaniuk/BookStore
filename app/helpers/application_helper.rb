module ApplicationHelper
  def authors_list(authors)
    authors.map { |author| author.name }.join(', ')
  end
  def awesome_remove
    haml_tag :i, class: 'fa fa-remove fa-lg'
  end

  def formated_price(price)
    "$ %.02f" % price
  end

  def error_message(object, field)
    haml_tag :span, object.errors[field].first, class: 'help-block small error_msg'
  end
end
