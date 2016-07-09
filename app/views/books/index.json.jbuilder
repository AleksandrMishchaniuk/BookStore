json.array!(@books) do |book|
  json.extract! book, :id, :title, :short_description, :full_description, :image, :price
  json.url book_url(book, format: :json)
end
