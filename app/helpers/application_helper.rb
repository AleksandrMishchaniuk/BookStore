module ApplicationHelper
  def authors_list(authors)
    authors.map { |author| author.full_name }.join(', ')
  end
  def awesome_remove
    haml_tag :i, class: 'fa fa-remove fa-lg'
  end
end
