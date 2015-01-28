require 'spec_helper'
require 'uri'

describe CropsController, :type => :controller do
  it 'Should direct to a new page' do
    user = FactoryGirl.create(:user)
    sign_in user
    get 'new'
    expect(response).to render_template(:new)
    expect(response.status).to eq(200)
  end

  it 'Should redirect to crop_searches' do
    get 'index'
    expect(response).to redirect_to controller: 'crop_searches', action: 'search'
    expect(response.status).to eq(302)
  end

  it 'Should render a show page' do
    crop = FactoryGirl.create(:crop)
    get 'show', id: crop.id
    expect(response).to render_template(:show)
    expect(response.status).to eq(200)
  end

  it 'Should direct to create guide page after successful crop creation' do
    crop = FactoryGirl.attributes_for(:crop)
    user = FactoryGirl.create(:user)
    sign_in user
    post 'create', crop: crop
    expect(response.status).to eq(302)
    expect(response).to redirect_to(
      "/en/guides/new?crop_id=#{assigns(:crop).id}")
  end

  it 'Should redirect back to form after unsuccessful crop creation' do
    crop = FactoryGirl.attributes_for(:crop)
    user = FactoryGirl.create(:user)
    sign_in user
    crop[:name] = ""
    post 'create', crop: crop
    expect(response).to render_template(:new)
    expect(response.status).to eq(200)
  end

  it 'should render an edit page if the user is logged in' do
    user = FactoryGirl.create(:user)
    sign_in user
    crop = FactoryGirl.create(:crop)
    get 'edit', id: crop.id
    expect(response).to render_template(:edit)
    expect(response.status).to eq(200)
  end

  it 'should rerender the edit page if not all params are good' do
    crop = FactoryGirl.create(:crop)
    user = FactoryGirl.create(:user, admin: true)
    sign_in user
    initial_name = crop.name
    put 'update',
        id: crop.id,
        crop: { name: '' }
    expect(crop.reload.name).to eq(initial_name)
    expect(response.status).to eq(200)
  end

  it 'post successful updates to a crop' do
    crop = FactoryGirl.create(:crop)
    user = FactoryGirl.create(:user, admin: true)
    sign_in user
    put 'update',
        id: crop.id,
        crop: { name: 'Updated name' }
    expect(crop.reload.name).to eq('Updated name')
    expect(response.status).to eq(302)
  end
end
