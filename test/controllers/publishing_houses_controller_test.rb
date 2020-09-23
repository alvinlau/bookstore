require 'test_helper'

class PublishingHousesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @publishing_house = publishing_houses(:one)
  end

  test "should get index" do
    get publishing_houses_url, as: :json
    assert_response :success
  end

  test "should create publishing_house" do
    assert_difference('PublishingHouse.count') do
      post publishing_houses_url, params: { publishing_house: { discount: @publishing_house.discount, g: @publishing_house.g, name: @publishing_house.name, publishing_house: @publishing_house.publishing_house, scaffold: @publishing_house.scaffold } }, as: :json
    end

    assert_response 201
  end

  test "should show publishing_house" do
    get publishing_house_url(@publishing_house), as: :json
    assert_response :success
  end

  test "should update publishing_house" do
    patch publishing_house_url(@publishing_house), params: { publishing_house: { discount: @publishing_house.discount, g: @publishing_house.g, name: @publishing_house.name, publishing_house: @publishing_house.publishing_house, scaffold: @publishing_house.scaffold } }, as: :json
    assert_response 200
  end

  test "should destroy publishing_house" do
    assert_difference('PublishingHouse.count', -1) do
      delete publishing_house_url(@publishing_house), as: :json
    end

    assert_response 204
  end
end
