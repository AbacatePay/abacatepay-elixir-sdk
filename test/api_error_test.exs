defmodule AbacatePay.ApiErrorTest do
  use ExUnit.Case
  doctest AbacatePay.ApiError

  describe "ApiError struct" do
    test "creates an ApiError with status code and message" do
      error = %AbacatePay.ApiError{status_code: 404, message: "Not Found"}

      assert error.status_code == 404
      assert error.message == "Not Found"
    end

    test "implements Exception protocol with message/1" do
      error = %AbacatePay.ApiError{status_code: 500, message: "Internal Server Error"}

      assert AbacatePay.ApiError.message(error) ==
               "API request failed with status code 500: Internal Server Error"
    end

    test "can be raised as an exception" do
      error = %AbacatePay.ApiError{status_code: 403, message: "Forbidden"}

      assert_raise AbacatePay.ApiError, fn ->
        raise error
      end
    end

    test "message formatting with different status codes" do
      error_400 = %AbacatePay.ApiError{status_code: 400, message: "Bad Request"}
      error_422 = %AbacatePay.ApiError{status_code: 422, message: "Validation Error"}

      assert String.contains?(AbacatePay.ApiError.message(error_400), "400")
      assert String.contains?(AbacatePay.ApiError.message(error_422), "422")
    end
  end
end
