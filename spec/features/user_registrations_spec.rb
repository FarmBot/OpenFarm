require 'spec_helper'

describe 'User registrations' do
  include IntegrationHelper

  let(:user) { FactoryGirl.create(:user) }

  it 'can change user settings' do
    login_as user
    visit edit_user_registration_path(user)
    fill_in :user_display_name, with: 'Bert'
    fill_in :user_current_password, with: user.password
    click_button 'Update User'
    see('You updated your account successfully')
    expect(user.reload.display_name).to eq('Bert')
  end

  it 'can change user password' do
    login_as user
    visit edit_user_registration_path(user)
    fill_in :user_current_password, with: user.password
    fill_in :user_password, with: "bert1234"
    click_button 'Update User'
    see('You updated your account successfully')
  end

  it 'should fail with wrong password' do
    login_as user
    original_name = user.display_name
    visit edit_user_registration_path(user)
    fill_in :user_current_password, with: 'wrongpassword'
    fill_in :user_display_name, with: 'Bert'
    click_button 'Update User'
    new_name = user.reload.display_name
    # Dunno why, but it wasn't liking user.reload.display_name
    # in the expect() below
    expect(new_name).to eq(original_name)
    see('Current password is invalid')
  end

  it 'should fail with faulty new password' do
    login_as user
    visit edit_user_registration_path(user)
    fill_in :user_current_password, with: user.password
    fill_in :user_password, with: "2short"
    click_button 'Update User'
    see('Password is too short')
  end

end
