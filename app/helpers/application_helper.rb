module ApplicationHelper
  def authors_list(authors)
    authors.map { |author| author.full_name }.join(', ')
  end
end
