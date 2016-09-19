require "rails_helper"

RSpec.describe Author, type: :model do

  describe '#name' do
    it 'returns author full name' do
      author = create :author
      full_name = author.first_name.to_s + " " + author.last_name.to_s
      expect(author.name).to eq(full_name)
    end
  end

end
