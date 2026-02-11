defmodule AbacatePay.HTTPClient do
  @moduledoc """
  HTTP client for making requests to the AbacatePay API.
  """

  alias AbacatePay.Config

  @user_agent "Elixir-SDK (#{Mix.Project.config()[:source_url]}, #{Mix.Project.config()[:version]})"

  @doc """
  Performs a GET request to the API.

  ## Examples

      iex> AbacatePay.Api.get("/customers/list")
      {:ok, [%{...}, ...]}
  """
  @spec get(path :: String.t()) :: {:ok, any(), map()} | {:error, any()}
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
  @spec post(path :: String.t(), body :: map()) :: {:ok, any()} | {:error, any()}
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
  @spec put(path :: String.t(), body :: map()) :: {:ok, any()} | {:error, any()}
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
  @spec delete(path :: String.t()) :: {:ok, any()} | {:error, any()}
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
          %{"data" => data, "pagination" => pagination} when data != nil and pagination != nil ->
            {:ok, data, pagination}

          %{"data" => data} when data != nil ->
            {:ok, data}

          %{"error" => _} = error when error != nil ->
            {:error, %AbacatePay.ApiError{status_code: status, message: error["error"]}}

          _ ->
            {:error,
             %AbacatePay.ApiError{status_code: status, message: "Unexpected response format"}}
        end

      {:error, %Jason.DecodeError{data: message}} ->
        {:error, %AbacatePay.ApiError{status_code: status, message: message}}
    end
  end

  @doc false
  @spec build_request(path :: String.t(), method :: atom()) :: Finch.Request.t()
  defp build_request(path, method) do
    api_url = Config.api_url()
    api_version = Config.api_version()
    api_key = Config.api_key()

    url = "#{api_url}/v#{api_version}" <> path

    headers =
      [
        {"Content-Type", "application/json"},
        {"Accept", "application/json"},
        {"User-Agent", @user_agent}
      ] ++ if api_key, do: [{"Authorization", "Bearer #{api_key}"}], else: []

    Finch.build(method, url, headers)
  end

  @doc false
  @spec build_request(path :: String.t(), method :: atom(), body :: map()) :: Finch.Request.t()
  defp build_request(path, method, body) do
    api_url = Config.api_url()
    api_version = Config.api_version()
    api_key = Config.api_key()

    url = "#{api_url}/v#{api_version}" <> path

    headers =
      [
        {"Content-Type", "application/json"},
        {"Accept", "application/json"},
        {"User-Agent", @user_agent}
      ] ++ if api_key, do: [{"Authorization", "Bearer #{api_key}"}], else: []

    Finch.build(method, url, headers, Jason.encode!(body))
  end
end
