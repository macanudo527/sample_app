require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
 
 def setup
   @admin     = users(:michael)
   @non_admin = users(:archer)
 end
 
 test "index as admin including pagination and delete links" do
   log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
 end
 
 test "index does not include non-activated users" do
   log_in_as(@non_admin)
   get users_path
   my_test_users = assigns(:users)
   my_test_users.total_pages.times do |n|
     page_o_users = User.paginate(page: n+1)
     page_o_users.each do |user|
       user.activated?
     end 
   end
 end
 
 test "index as non-admin" do
   log_in_as(@non_admin)
   get users_path
   assert_select 'a', text: 'delete', count: 0
 end
 
 
 
end
