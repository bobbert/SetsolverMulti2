require 'test_helper'

class ClassControllerTest < ActionController::TestCase
  test "should get PagesController" do
    get :PagesController
    assert_response :success
  end

end
