require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  scenario 'Shows the welcome message' do
    visit '/'

    expect(page).to have_content 'Welcome!'
  end
  scenario 'New user can register' do
    visit '/'
    click_on('Register')
    fill_in 'user_email', with: 'user@test.com'
    fill_in 'user_password', with: '123456'
    click_on('Register')
    expect(page).to have_content('Welcome user@test.com!')
  end
end

#When a user goes to the home page
#And clicks "Register"
#And fills in "Email" with an email address
#And fills in "Password" with a password
#And clicks "Register"
#Then they should see a custom welcome message like "Hello <email address>"