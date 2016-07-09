require 'rails_helper'

RSpec.describe "books/edit", type: :view do
  before(:each) do
    @book = assign(:book, Book.create!(
      :title => "MyString",
      :short_description => "MyText",
      :full_description => "MyText",
      :image => "MyString",
      :price => "9.99"
    ))
  end

  it "renders the edit book form" do
    render

    assert_select "form[action=?][method=?]", book_path(@book), "post" do

      assert_select "input#book_title[name=?]", "book[title]"

      assert_select "textarea#book_short_description[name=?]", "book[short_description]"

      assert_select "textarea#book_full_description[name=?]", "book[full_description]"

      assert_select "input#book_image[name=?]", "book[image]"

      assert_select "input#book_price[name=?]", "book[price]"
    end
  end
end
