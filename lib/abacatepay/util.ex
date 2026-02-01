defmodule AbacatePay.Util do
  @moduledoc ~S"""
  Utils functions for AbacatePay.
  """

  # Public AbacatePay HMAC Key
  @public_key "t9dXRhHHo3yDEj5pVDYz0frf7q6bMKyMRmxxCPIPp3RCplBfXRxqlC6ZpiWmOqj4L63qEaeUOtrCI8P0VMUgo6iIga2ri9ogaHFs0WIIywSMg0q7RmBfybe1E5XJcfC4IW3alNqym0tXoAKkzvfEjZxV6bE0oG2zJrNNYmUCKZyV0KZ3JS8Votf9EAWWYdiDkMkpbMdPggfh1EqHlVkMiTady6jOR3hyzGEHrIz2Ret0xHKMbiqkr9HS1JhNHDX9"

  @doc """
  Returns the AbacatePay public HMAC key used for verifying webhooks.
  """
  @spec get_public_key() :: String.t()
  def get_public_key, do: @public_key

  @doc """
  Verifies if the AbacatePay signature matches the expected HMAC.
  """
  def verify_signature(payload, signature) do
    expected_signature =
      :crypto.mac(:hmac, :sha256, @public_key, payload)
      |> Base.encode64()

    :crypto.hash_equals(expected_signature, signature)
  end

  @doc """
  Converts a string enum value to an existing atom.

  ## Examples

      iex> AbacatePay.Util.atomize_enum("PENDING")
      :pending

      iex> AbacatePay.Util.atomize_enum("COMPLETED")
      :completed
      iex> AbacatePay.Util.atomize_enum("FAILED")
      :failed
  """
  @spec atomize_enum(value :: String.t()) :: atom()
  def atomize_enum(value) when is_binary(value) do
    value
    |> Macro.underscore()
    |> String.to_existing_atom()
  end

  def atomize_enum(_), do: nil

  @doc """
  Converts an existing atom to its string enum representation.

  ## Examples

      iex> AbacatePay.Util.normalize_atom(:pending)
      "PENDING"

      iex> AbacatePay.Util.normalize_atom(:completed)
      "COMPLETED"

      iex> AbacatePay.Util.normalize_atom(:failed)
      "FAILED"
  """
  @spec normalize_atom(value :: atom()) :: String.t()
  def normalize_atom(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.upcase()
  end

  def normalize_atom(_), do: nil
end
