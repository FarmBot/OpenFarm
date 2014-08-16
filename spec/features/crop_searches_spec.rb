require "spec_helper"

describe 'Crop search', :type => :controller do
  let!(:crop){FactoryGirl.create(:crop)}

  it 'finds documents' do
    visit root_path
    fill_in 'cropsearch_searchtext', with: 'radish'
    click_button 'Search!'
    expect(page).to have_content('Horseradish (Armoracia rusticana, syn. Cochlearia armoracia)')
  end

  it 'handles empty searches' do
    visit root_path
    fill_in 'cropsearch_searchtext', with: ''
    click_button 'Search!'
    current_url.should == root_url
  end

  it 'handles pagination'

  it 'paginates results'

end
