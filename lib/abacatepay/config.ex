#  Forked from: https://github.com/getsentry/sentry-elixir/blob/master/lib/sentry/config.ex

defmodule AbacatePay.Config do
  @moduledoc false

  basic_options_schema = [
    api_url: [
      type: :string,
      default: "https://api.abacatepay.com",
      type_doc: "`t:String.t/0`",
      required: false,
      doc: "The base URL for the AbacatePay API."
    ],
    api_version: [
      type: :string,
      default: "2",
      type_doc: "`t:String.t/0`",
      required: false,
      doc: "The API version to use."
    ],
    api_key: [
      type: :string,
      type_doc: "`t:String.t/0`",
      doc: "The API key for authenticating with the AbacatePay API.",
      required: false
    ]
  ]

  @basic_options_schema NimbleOptions.new!(basic_options_schema)

  @raw_opts_schema Enum.concat([
                     basic_options_schema
                   ])

  @opts_schema NimbleOptions.new!(@raw_opts_schema)
  @valid_keys Keyword.keys(@raw_opts_schema)

  @spec validate!() :: keyword()
  def validate! do
    :abacatepay
    |> Application.get_all_env()
    |> validate!()
  end

  @spec validate!(keyword()) :: keyword()
  def validate!(config) when is_list(config) do
    config_opts =
      config
      |> Keyword.take(@valid_keys)
      |> fill_in_from_env(:api_url, "ABACATEPAY_API_URL")
      |> fill_in_from_env(:api_version, "ABACATEPAY_API_VERSION")
      |> fill_in_from_env(:api_key, "ABACATEPAY_API_KEY")

    case NimbleOptions.validate(config_opts, @opts_schema) do
      {:ok, opts} ->
        opts

      {:error, error} ->
        raise ArgumentError, """
        invalid configuration for the :abacatepay application, so we cannot start or update
        its configuration. The error was:

            #{Exception.message(error)}

        See the documentation for the AbacatePay module for more information on configuration.
        """
    end
  end

  @spec persist(keyword()) :: :ok
  def persist(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      :persistent_term.put({:abacatepay_config, key}, value)
    end)
  end

  @spec docs() :: String.t()
  def docs do
    """
    #### Basic Options

    #{NimbleOptions.docs(@basic_options_schema)}
    """
  end

  @spec api_url() :: String.t()
  def api_url, do: get(:api_url)

  @spec api_version() :: String.t()
  def api_version, do: get(:api_version)

  @spec api_key() :: String.t() | nil
  def api_key, do: get(:api_key)

  @spec put_config(atom(), term()) :: :ok
  def put_config(key, value) when is_atom(key) do
    unless key in @valid_keys do
      raise ArgumentError, "unknown option #{inspect(key)}"
    end

    renamed_key =
      case key do
        :before_send_event -> :before_send
        other -> other
      end

    [{key, value}]
    |> validate!()
    |> Keyword.take([renamed_key])
    |> persist()
  end

  ## Helpers

  defp fill_in_from_env(config, key, system_key) do
    case System.get_env(system_key) do
      nil -> config
      value -> Keyword.put_new(config, key, value)
    end
  end

  @compile {:inline, get: 1}
  defp get(key) do
    # Check process dictionary first for test-specific config overrides.
    # This allows tests to use put_test_config/1 for isolated configuration
    # without affecting other tests, even when running async: true.
    case Process.get({:abacatepay_test_config, key}, :__not_set__) do
      :__not_set__ ->
        :persistent_term.get({:abacatepay_config, key}, nil)

      value ->
        value
    end
  end
end
