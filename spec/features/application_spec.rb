require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do

  context 'admininistrator privilages' do
    before :each do
      hashed_pass = BCrypt::Password.create("1234")
      DB[:users].insert(
        :user_email => 'admin@gmail.com',
        :password_digest => hashed_pass,
        :administrator => true)
    end

    scenario 'admin can view all users' do
      visit '/'
      click_on('Login')
      fill_in 'user_email', with: 'admin@gmail.com'
      fill_in 'user_password', with: '1234'
      click_on('Login')
      click_on('View all users')
      expect(page).to have_content('Users')
    end
  end

  scenario 'Shows the welcome message' do
    visit '/'
    expect(page).to have_content 'Welcome!'
  end

  context 'user registers' do
    scenario "user cannot register if passwords don't match" do
      visit '/'
      click_on('Register')
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: '123456'
      fill_in 'confirm_password', with: '12345'
      click_on('Register')
      expect(page).to have_content "Passwords do not match"
    end
  end

  context 'registered user logs in' do
    before :each do
      visit '/'
      click_on('Register')
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: '123456'
      fill_in 'confirm_password', with: '123456'
      click_on('Register')
    end

    scenario 'User can logout' do
      expect(page).to have_content('Welcome user@test.com!')
      click_on('Logout')
      expect(page).to have_content 'Welcome!'
    end

    scenario 'User gets error with correct email but wrong password' do
      click_on('Logout')
      click_on('Login')
      expect(page).to have_content 'Login'
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: 'ilikesocks'
      click_on('Login')
      expect(page).to have_content 'Email/password is invalid'
    end

    scenario 'User gets error with wrong email address' do
      click_on('Logout')
      click_on('Login')
      expect(page).to have_content 'Login'
      fill_in 'user_email', with: 'wrong@test.com'
      fill_in 'user_password', with: '12345'
      click_on('Login')
      expect(page).to have_content 'Email/password is invalid'
    end

    scenario 'User can login' do
      click_on('Logout')
      click_on('Login')
      expect(page).to have_content 'Login'
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: '123456'
      click_on('Login')
      expect(page).to have_content('Welcome user@test.com!')
    end
  end
end
