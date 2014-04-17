require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  before :each do
    DB[:users].delete
  end

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

    context "admin can edit users" do
      before :each do
        visit '/'
        click_on('Register')
        fill_in 'user_email', with: 'user1@test.com'
        fill_in 'user_password', with: 'abcd'
        fill_in 'confirm_password', with: 'abcd'
        click_on('Register')
        click_on('Logout')

        click_on('Register')
        fill_in 'user_email', with: 'user2@test.com'
        fill_in 'user_password', with: 'abcd'
        fill_in 'confirm_password', with: 'abcd'
        click_on('Register')
        click_on('Logout')
      end
      scenario "edit user" do
        visit '/'
        click_on('Login')
        fill_in 'user_email', with: 'admin@gmail.com'
        fill_in 'user_password', with: '1234'
        click_on('Login')
        click_on('View all users')
        within('tr:nth-child(2)')  do
          click_on('Edit')
        end
        expect(page).to have_content('user1@test.com')
      end
    end
  end

  scenario 'Shows the welcome message' do
    visit '/'
    expect(page).to have_content 'Welcome!'
  end

  context 'user registers' do
    before :each do
      visit '/'
      click_on('Register')
      fill_in 'user_email', with: 'user@test.com'
    end
    scenario "User cannot register if their password is less than 3 characters" do
      fill_in 'user_password', with: 'xy'
      fill_in 'confirm_password', with: 'xy'
      click_on('Register')
      expect(page).to have_content "Password must be longer than 2 characters"
    end

    scenario "user cannot register if passwords don't match" do
      fill_in 'user_password', with: '123456'
      fill_in 'confirm_password', with: '12345'
      click_on('Register')
      expect(page).to have_content "Passwords do not match"
    end

    scenario "User cannot register if their password is blank" do
      fill_in 'user_password', with: ''
      fill_in 'confirm_password', with: ''
      click_on('Register')
      expect(page).to have_content "Password can't be blank"
    end

    scenario "User cannot register if their password is empty whitespace" do
      fill_in 'user_password', with: '    '
      fill_in 'confirm_password', with: '    '
      click_on('Register')
      expect(page).to have_content "Password can't be blank"
    end

    scenario "User cannot register with an email address that already exists" do
      fill_in 'user_password', with: '123456'
      fill_in 'confirm_password', with: '123456'
      click_on('Register')
      click_on('Logout') # first user

      click_on('Register')
      fill_in 'user_email', with: 'user@test.com'
      fill_in 'user_password', with: 'abcd'
      fill_in 'confirm_password', with: 'abcd'
      click_on('Register') # second user
      expect(page).to have_content "User email already taken"
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
