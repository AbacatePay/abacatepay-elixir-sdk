defmodule AbacatePay.ApiError do
  @moduledoc """
  Represents a failed response from the AbacatePay API.

  This occurs when the AbacatePay API doesn't respond with `200` or `204`.
  """

  defexception [
    :status_code,
    :message
  ]

  @type t :: %__MODULE__{
          status_code: status_code,
          message: message
        }

  @type status_code :: 100..511
  @type message :: String.t()

  @impl true
  def message(%__MODULE__{status_code: status_code, message: message}) do
    "API request failed with status code #{status_code}: #{message}"
  end
end
