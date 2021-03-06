require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_reset_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_reset_path, password_reset: { email: "" }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Form password reset
    user = assigns(:user)
    # Non-active user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Valid email, invalid token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Valid email, valid token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), email: user.email, 
                                                 user: {  password: "foobaz", 
                                                 password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Nill password
    patch password_reset_path(user.reset_token), email: user.email, 
                                                 user: {  password: "", 
                                                 password_confirmation: "" }
    assert_select 'div#error_explanation'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token), email: user.email, 
                                                 user: {  password: "foobar", 
                                                 password_confirmation: "foobar" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
    end
end
