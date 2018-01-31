require 'spec_helper'

describe 'User sessions' do
  # include IntegrationHelper

  let(:user) { FactoryGirl.create(:user) }
  # To generate test cases after merging new homepage UI - WIP
  pending 'registers for an account should not be confirmed' do
    visit root_path
    click_link 'register'
    fill_in :user_display_name, with: 'Rick'
    fill_in :user_password, with: 'password123'
    fill_in :user_email, with: 'm@il.com'
    click_button 'Join OpenFarm'
    usr = User.find_by(email: 'm@il.com')
    expect(usr.display_name).to eq('Rick')
    expect(usr.valid_password?('password123')).to eq(true)
    expect(usr.agree).to eq(true)
    expect(usr.email).to eq('m@il.com')
    expect(usr.confirmed?).to eq(false)
  end

  pending 'logs out' do
    login_as user
    visit root_path
    page.first(:link, 'Log out').click
    see('Signed out successfully.')
  end

  it 'does not let the user access the admin panel' do
    visit rails_admin.dashboard_path
    expect(page).to have_content('I told you kids to get out of here!')
  end

  pending 'should create a new garden for a newly registered user' do
    usr = sign_up_procedure

    expect(Garden.all.last.user).to eq (usr)
  end

  pending 'user gets redirected to finish page after confirmation', js: true do
    usr = sign_up_procedure
    expect(page).to have_content('Your account was successfully confirmed')
    see 'Thanks for joining!'
    click_button I18n::t('users.finish.next_step')
    see('Gardens')
    expect(page).to have_content('Gardens')
  end

  it 'should register the user location', js: true do
    login_as user
    visit users_finish_path
    wait_for_ajax
    fill_in :location, with: 'Chicago'
    click_button I18n::t('users.finish.next_step')
    see('This is your member profile')
    expect(user.reload.user_setting.location).to eq('Chicago')
  end

  it 'should register the user unit preference', js: true do
    login_as user
    visit users_finish_path
    wait_for_ajax
    choose 'units-imperial'
    click_button I18n::t('users.finish.next_step')
    see('This is your member profile')
    expect(user.reload.user_setting.units).to eq('imperial')
  end

  pending 'should redirect to sign up page when user is not authorized' do
    usr = sign_up_procedure
    logout

    visit new_crop_path
    see('You\'re not authorized to go to there.')

    fill_in :user_email, with: usr[:email]
    fill_in :user_password, with: 'password123'
    click_button 'Sign in'
    expect(page).to have_content('Add a new crop')
  end

  pending 'should direct to root after log in' do
    usr = sign_up_procedure
    logout

    visit root_path
    click_link 'Log in'

    fill_in :user_email, with: usr[:email]
    fill_in :user_password, with: 'password123'
    click_button 'Sign in'
    expect(page).to have_content("Hi, #{usr.display_name}")
  end

  pending 'should redirect if there was a problem with the token' do
    vispending '/users/confirmation?confirmation_token=fake_token'
    expect(page).to have_content('Resend confirmation instructions')
  end

  pending 'should let the user set favorite crop on profile page', js: true do
    FactoryGirl.create(:crop, name: 'Tomato')
    login_as user
    visit user_path('en', user)
    see('Success!')
    see('This is your Member Profile page.')
    wait_for_ajax
    fill_in :search_crop_name, with: 'tomat'
    wait_for_ajax
    click_button :submit_crop
    see('Tomato')
  end
  def extract_url_from_email(email)
    doc = Nokogiri::HTML(email.to_s)

    hrefs = doc.xpath("//a[starts-with(text(), 'C')]/@href").map(&:to_s)

    # We don't actually want our string to say test.test.com, cause
    # apparently that's a website!
    hrefs[0]['http://test.test.com'] = ''
    hrefs[0]
  end

  def sign_up_procedure
    visit root_path
    click_link 'register'
    fill_in :user_display_name, with: 'Rick'
    fill_in :user_password, with: 'password123'
    fill_in :user_email, with: 'm@il.com'

    click_button 'Join OpenFarm'
    usr = User.find_by(email: 'm@il.com')

    # This is a bit of a hack, but I can't think of a different
    # way to get the token that is sent via email (it's different from
    # what gets stored in the DB)
    href = extract_url_from_email(usr.resend_confirmation_instructions.body)

    visit href
    usr
  end
end
