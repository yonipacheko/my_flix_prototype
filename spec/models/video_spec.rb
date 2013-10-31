require 'spec_helper'

describe Video do
  it 'saves itself' do
    video = Fabricate(:videos)
    expect(Video.first) =~ (video)

  end
  it { should have_many(:categories).through(:categorizations) }

  #it 'validates when title is not included' do
  #  video = Video.create(title:'something')
  #  expect(Video.count).to eq(0)
  #end

  it "Doesn't validate when title is not included" do
    video = Video.create(description:'something')
    expect(Video.count).to eq(2) # there are already 2 times in table
  end

  #validating when title is not included using shoulda_matchers
  it { should validate_presence_of (:title) }

  describe 'Search_by_title' do
    it " returns an empty array if there's no match " do
      v1 = Fabricate(:videos)
      v2 = Fabricate(:videos)
      expect(Video.search_by_title('hola')).to eq([])
    end

    it "return an array of one video for an exact match" do
      v1 = Fabricate(:videos)
      v2 = Fabricate(:videos)
      expect(Video.search_by_title("#{v1.title}")).to eq([v1])
    end
    it 'return an array of video for a partial match' do
      v1 = Video.create(title: 'tututut', description: 'fa')
      expect(Video.search_by_title("tu")).to eq([v1])
    end
    it 'return an array of all matches ordered by created_at'  do
    v1 = Video.create(title: 'nica', description: 'fa', created_at: 1.day.ago)
    v2 = Video.create(title: 'nica', description: 'fa')
    expect(Video.search_by_title("Nica")).to eq([v2, v1])
    end

    it ' when the user doesnt write anything in the search field' do
      expect(Video.search_by_title('')).to eq([])

    end
  end

end