require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  describe "GET #home" do
    it "returns http success" do
      allow(Book).to receive(:bestsellers)
      get :home
      expect(response).to have_http_status(:success)
    end

    it "pass to view array of books" do
      books = (1..5).map { create(:book) }
      get :home
      expect(assigns(:books)).to be_kind_of(Array)
      assigns(:books).each { |book| expect(book).to be_kind_of(Book) }
    end
  end

end
