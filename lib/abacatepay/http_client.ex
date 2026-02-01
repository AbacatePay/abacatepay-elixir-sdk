defmodule AbacatePay.HTTPClient do
  @moduledoc """
  HTTP client for making requests to the AbacatePay API.
  """

  @user_agent "Elixir-SDK (#{Mix.Project.config()[:source_url]}, #{Mix.Project.config()[:version]})"

  defp api_url do
    Application.get_env(:abacatepay, :api_url, "https://api.abacatepay.com")
  end

  defp api_version do
    Application.get_env(:abacatepay, :api_version, "1")
  end

  defp api_key do
    Application.get_env(:abacatepay, :api_key, nil)
  end

  @doc """
  Performs a GET request to the API.

  ## Examples

      iex> AbacatePay.Api.get("/customers/list")
      {:ok, [%{...}, ...]}
  """
  def get(path) do
    path
    |> build_request(:get)
    |> Finch.request(AbacatePay.Finch)
    |> case do
      {:ok, %Finch.Response{body: body, status: status}} ->
        parse_response({:ok, %Finch.Response{body: body, status: status}})

      other ->
        other
    end
  end

  @doc """
  Performs a POST request to the API.

  ## Examples

      iex> AbacatePay.Api.post("/customers/create", %{name: "Daniel Lima", cellphone: "(11) 4002-8922", email: "daniel_lima@abacatepay.com", taxId: "123.456.789-01"})
      {:ok, %{...}}
  """
  def post(path, body) do
    path
    |> build_request(:post, body)
    |> Finch.request(AbacatePay.Finch)
    |> case do
      {:ok, %Finch.Response{body: body, status: status}} ->
        parse_response({:ok, %Finch.Response{body: body, status: status}})

      other ->
        other
    end
  end

  @doc """
  Performs a PUT request to the API.
  """
  def put(path, body) do
    path
    |> build_request(:put, body)
    |> Finch.request(AbacatePay.Finch)
    |> case do
      {:ok, %Finch.Response{body: body, status: status}} ->
        parse_response({:ok, %Finch.Response{body: body, status: status}})

      other ->
        other
    end
  end

  @doc """
  Performs a DELETE request to the API.
  """
  def delete(path) do
    path
    |> build_request(:delete)
    |> Finch.request(AbacatePay.Finch)
    |> case do
      {:ok, %Finch.Response{body: body, status: status}} ->
        parse_response({:ok, %Finch.Response{body: body, status: status}})

      other ->
        other
    end
  end

  @doc false
  defp parse_response({:ok, %Finch.Response{body: _body, status: 204}}) do
    {:ok, nil}
  end

  @doc false
  defp parse_response({:ok, %Finch.Response{body: body, status: status}}) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        case decoded do
          %{"data" => data} when data != nil ->
            {:ok, data}

          %{"error" => _} = error when error != nil ->
            {:error, %AbacatePay.ApiError{status_code: status, message: error["error"]}}

          _ ->
            {:error,
             %AbacatePay.ApiError{status_code: status, message: "Unexpected response format"}}
        end

      {:error, %Jason.DecodeError{data: error_message}} ->
        {:error, %AbacatePay.ApiError{status_code: status, message: error_message}}
    end
  end

  @doc false
  defp build_request(path, method) do
    url = "#{api_url()}/v#{api_version()}" <> path

    headers =
      [
        {"Content-Type", "application/json"},
        {"Accept", "application/json"},
        {"User-Agent", @user_agent}
      ] ++ if api_key(), do: [{"Authorization", "Bearer #{api_key()}"}], else: []

    Finch.build(method, url, headers)
  end

  @doc false
  defp build_request(path, method, body) do
    url = "#{api_url()}/v#{api_version()}" <> path

    headers =
      [
        {"Content-Type", "application/json"},
        {"Accept", "application/json"},
        {"User-Agent", @user_agent}
      ] ++ if api_key(), do: [{"Authorization", "Bearer #{api_key()}"}], else: []

    Finch.build(method, url, headers, Jason.encode!(body))
  end
end
