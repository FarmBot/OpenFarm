require 'spec_helper'

describe 'Crop search', type: :controller do
  let!(:crop) { FactoryGirl.create(:crop, :radish) }

  it 'finds individual crops' do
    visit root_path
    FactoryGirl.create_list(:crop, 10)
    FactoryGirl.create(:crop, name: 'radish')
    Crop.searchkick_index.refresh
    fill_in 'q', with: 'radish'
    click_button 'Search'
    expect(page).to have_content('radish')
    expect(page).to_not have_content("Sorry, we don't have any crops matching")
  end

  it 'handles empty searches' do
    visit root_path
    fill_in 'q', with: ''
    FactoryGirl.create_list(:crop, 10)
    Crop.searchkick_index.refresh
    click_button 'Search'
    expect(page).to have_content(Crop.last.name)
  end

  it 'handles empty search results' do
    visit root_path
    fill_in 'q', with: 'pokemon'
    FactoryGirl.create_list(:crop, 10)
    Crop.searchkick_index.refresh
    click_button 'Search'
    expect(page).to have_content("Sorry, we don't have any crops matching")
  end

  it 'handles plurals' do
    visit root_path
    fill_in 'q', with: crop.name
    FactoryGirl.create_list(:crop, 10)
    Crop.searchkick_index.refresh
    click_button 'Search'
    expect(page).to have_content(crop.name)
    expect(page).to_not have_content("Sorry, we don't have any crops matching")
  end

  it 'handles misspellings' do
    visit root_path
    FactoryGirl.create_list(:crop, 10)
    FactoryGirl.create(:crop, name: 'radish')
    Crop.searchkick_index.refresh
    fill_in 'q', with: 'radis'
    click_button 'Search'
    expect(page).to have_content('radish')
    expect(page).to_not have_content("Sorry, we don't have any crops matching")
  end

  it 'handles multiple words' do
    visit root_path
    FactoryGirl.create_list(:crop, 10)
    FactoryGirl.create(:crop, name: 'radish')
    Crop.searchkick_index.refresh
    fill_in 'q', with: 'pear radish'
    click_button 'Search'
    expect(page).to have_content('radish')
    expect(page).to_not have_content("Sorry, we don't have any crops matching")
  end

  it 'has a top nav bar' do
    visit crop_search_via_get_path(cropsearch: { q: 'red' })
    fill_in 'q', with: crop.name
    FactoryGirl.create_list(:crop, 10)
    Crop.searchkick_index.refresh
    click_button 'Search'
    expect(page).to have_content(crop.name)
  end
end
