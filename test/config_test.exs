defmodule AbacatePay.ConfigTest do
  use ExUnit.Case, async: true

  alias AbacatePay.Config

  describe "validate!/0" do
    test ":api_url from option" do
      assert Config.validate!(api_url: "https://custom-url.abacatepay.com")[:api_url] ==
               "https://custom-url.abacatepay.com"

      assert Config.validate!()[:api_url] == "https://api.abacatepay.com"
    end

    test ":api_url from system environment" do
      with_system_env("ABACATEPAY_API_URL", "https://system-env.abacatepay.com", fn ->
        assert Config.validate!()[:api_url] == "https://system-env.abacatepay.com"
      end)
    end

    test "invalid :api_url" do
      # Not a string.
      assert_raise ArgumentError, fn ->
        Config.validate!(api_url: :not_a_string)
      end
    end

    test ":api_version from option" do
      assert Config.validate!(api_version: "1")[:api_version] == "1"
      assert Config.validate!()[:api_version] == "2"
    end

    test ":api_version from system environment" do
      with_system_env("ABACATEPAY_API_VERSION", "2", fn ->
        assert Config.validate!()[:api_version] == "2"
      end)
    end

    test "invalid :api_version" do
      # Not a string.
      assert_raise ArgumentError, fn ->
        Config.validate!(api_version: :not_a_string)
      end
    end

    test ":api_key from option" do
      assert Config.validate!(api_key: "abc_dev_pWxM5GhSROzeerqmdkfu6mNN")[:api_key] ==
               "abc_dev_pWxM5GhSROzeerqmdkfu6mNN"

      assert Config.validate!()[:api_key] == nil
    end

    test ":api_key from system environment" do
      with_system_env("ABACATEPAY_API_KEY", "abc_dev_pWxM5GhSROzeerqmdkfu6mNN", fn ->
        assert Config.validate!()[:api_key] == "abc_dev_pWxM5GhSROzeerqmdkfu6mNN"
      end)
    end

    test "invalid :api_key" do
      # Not a string.
      assert_raise ArgumentError, fn ->
        Config.validate!(api_key: :not_a_string)
      end
    end
  end

  describe "put_config/2" do
    test "updates the configuration" do
      api_key_before = :persistent_term.get({:abacatepay_config, :api_key}, :__not_set__)

      on_exit(fn ->
        case api_key_before do
          :__not_set__ -> :persistent_term.erase({:abacatepay_config, :api_key})
          other -> :persistent_term.put({:abacatepay_config, :api_key}, other)
        end
      end)

      new_api_key = "abc_dev_pWxM5GhSROzeerqmdkfu6mNN"
      assert :ok = Config.put_config(:api_key, new_api_key)

      assert :persistent_term.get({:abacatepay_config, :api_key}) == new_api_key
    end

    test "validates the given key" do
      assert_raise ArgumentError, ~r/unknown option :non_existing/, fn ->
        Config.put_config(:non_existing, "value")
      end
    end
  end

  defp with_system_env(key, value, fun) when is_function(fun, 0) do
    original_env = System.fetch_env(key)
    System.put_env(key, value)

    try do
      fun.()
    after
      case original_env do
        {:ok, original_value} -> System.put_env(key, original_value)
        :error -> System.delete_env(key)
      end
    end
  end
end
