defmodule AbacatePay.MockHTTPServer do
  @moduledoc """
  Mock HTTP Server for testing API requests.

  This module provides helper functions to mock HTTP responses for testing
  API clients without making actual network requests.
  """

  use ExUnit.Case, async: true
  use Mimic

  @doc """
  Stub a successful GET request.

  ## Examples

      stub_get("/customers/list", %{"data" => [...]})
  """
  def stub_get(path, response_data) do
    expected_path = normalize_path(path)

    stub(AbacatePay.HTTPClient, :get, fn actual_path ->
      case normalize_path(actual_path) do
        ^expected_path -> normalize_response(response_data)
        _ -> raise(FunctionClauseError)
      end
    end)
  end

  @doc """
  Stub a successful POST request.

  ## Examples

      stub_post("/customers/create", %{name: "Daniel Lima", ...}, %{"data" => %{"id" => "cust_aebxkhDZNaMmJeKsy0AHS0FQ", ...}})
  """
  def stub_post(path, _body, response_data) do
    stub(AbacatePay.HTTPClient, :post, fn ^path, _body ->
      {:ok, response_data}
    end)
  end

  @doc """
  Stub a successful PUT request.
  """
  def stub_put(path, _body, response_data) do
    stub(AbacatePay.HTTPClient, :put, fn ^path, _body ->
      {:ok, response_data}
    end)
  end

  @doc """
  Stub a successful DELETE request.
  """
  def stub_delete(path, response_data) do
    expected_path = normalize_path(path)

    stub(AbacatePay.HTTPClient, :delete, fn actual_path ->
      case normalize_path(actual_path) do
        ^expected_path -> {:ok, response_data}
        _ -> raise(FunctionClauseError)
      end
    end)
  end

  @doc """
  Stub a request that returns an error.

  ## Examples

      stub_error(:get, "/invalid", %AbacatePay.ApiError{status_code: 404, message: "Not Found"})
  """
  def stub_error(method, path, error) when method in [:get, :delete] do
    expected_path = normalize_path(path)

    stub(AbacatePay.HTTPClient, method, fn actual_path ->
      case normalize_path(actual_path) do
        ^expected_path -> {:error, error}
        _ -> raise(FunctionClauseError)
      end
    end)
  end

  def stub_error(method, path, error) when method in [:post, :put] do
    stub(AbacatePay.HTTPClient, method, fn ^path, _body ->
      {:error, error}
    end)
  end

  @doc """
  Create a mock API error response.

  ## Examples

      mock_error(404, "Not Found")
      mock_error(422, "Invalid parameters")
  """
  def mock_error(status_code, message) do
    %AbacatePay.ApiError{status_code: status_code, message: message}
  end

  defp normalize_response(%{"data" => data, "pagination" => pagination}) do
    {:ok, data, pagination}
  end

  defp normalize_response(%{"data" => data}) do
    {:ok, data}
  end

  defp normalize_response(response_data) do
    {:ok, response_data}
  end

  defp normalize_path(path) do
    case String.split(path, "?", parts: 2) do
      [base, ""] ->
        base

      [base] ->
        base

      [base, query] ->
        normalized_query =
          query
          |> URI.decode_query()
          |> Enum.sort()
          |> URI.encode_query()

        base <> "?" <> normalized_query
    end
  end
end
