require 'rails_helper'

RSpec.describe "books/index", type: :view do
  before(:each) do
    assign(:books, [
      Book.create!(
        :title => "Title",
        :short_description => "MyText",
        :full_description => "MyText",
        :image => "Image",
        :price => "9.99"
      ),
      Book.create!(
        :title => "Title",
        :short_description => "MyText",
        :full_description => "MyText",
        :image => "Image",
        :price => "9.99"
      )
    ])
  end

  it "renders a list of books" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Image".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
