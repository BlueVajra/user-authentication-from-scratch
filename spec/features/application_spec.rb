require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  before :each do
    DB[:users].delete
  end

  scenario 'Shows the welcome message' do
    visit '/'
    expect(page).to have_content 'Welcome!'
  end

  context 'user registers and logs in' do
    before :each do
      visit '/'
      click_on('Register')
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: '123456'
      click_on('Register')
    end

    scenario 'New user can register' do
      expect(page).to have_content('Welcome user@test.com!')
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
