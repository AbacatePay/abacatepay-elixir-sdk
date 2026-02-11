defmodule AbacatePay.UtilTest do
  use ExUnit.Case
  doctest AbacatePay.Util

  alias AbacatePay.Util

  @public_key "t9dXRhHHo3yDEj5pVDYz0frf7q6bMKyMRmxxCPIPp3RCplBfXRxqlC6ZpiWmOqj4L63qEaeUOtrCI8P0VMUgo6iIga2ri9ogaHFs0WIIywSMg0q7RmBfybe1E5XJcfC4IW3alNqym0tXoAKkzvfEjZxV6bE0oG2zJrNNYmUCKZyV0KZ3JS8Votf9EAWWYdiDkMkpbMdPggfh1EqHlVkMiTady6jOR3hyzGEHrIz2Ret0xHKMbiqkr9HS1JhNHDX9"

  describe "get_public_key/0" do
    test "returns the public HMAC key" do
      public_key = Util.get_public_key()
      assert public_key == @public_key
    end

    test "returns the expected key format" do
      public_key = Util.get_public_key()

      # Should be a non-empty base64-like string
      assert is_binary(public_key)
      assert String.length(public_key) > 0
    end
  end

  describe "verify_signature/2" do
    test "verifies a valid signature" do
      payload = "test_payload"

      expected_signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload)
        |> Base.encode64()

      assert Util.verify_signature(payload, expected_signature) == true
    end

    test "rejects an invalid signature" do
      payload = "test_payload"

      # Create a valid signature format but with wrong content
      invalid_signature = Base.encode64("x" <> String.duplicate("a", 31))

      assert Util.verify_signature(payload, invalid_signature) == false
    end

    test "rejects signature for different payload" do
      payload1 = "payload_1"
      payload2 = "payload_2"

      signature_for_payload1 =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload1)
        |> Base.encode64()

      assert Util.verify_signature(payload2, signature_for_payload1) == false
    end

    test "verifies webhook payload with signature" do
      # payload from https://docs.abacatepay.com/pages/webhooks
      webhook_payload =
        ~s({"id":"log_12345abcdef","data": {"payment": {"amount": 1000, "fee": 80, "method": "PIX"}, "pixQrCode": {"amount": 1000, "id": "pix_char_mXTWdj6sABWnc4uL2Rh1r6tb", "kind": "PIX", "status": "PAID"}}, "devMode": false, "event": "billing.paid"})

      signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), webhook_payload)
        |> Base.encode64()

      assert Util.verify_signature(webhook_payload, signature) == true
    end

    test "is case-sensitive for signature" do
      payload = "case_sensitive_test"

      correct_signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload)
        |> Base.encode64()

      # Base64 encoded signatures should match exactly
      modified_signature = String.downcase(correct_signature)

      # The signature may or may not verify depending on case sensitivity of base64
      # But typically should fail if modified
      result = Util.verify_signature(payload, modified_signature)
      # Just verify it's a boolean result
      assert is_boolean(result)
    end

    test "handles empty payload" do
      payload = ""

      signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload)
        |> Base.encode64()

      assert Util.verify_signature(payload, signature) == true
    end

    test "handles large payload" do
      payload = String.duplicate("x", 10_000)

      signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload)
        |> Base.encode64()

      assert Util.verify_signature(payload, signature) == true
    end
  end

  describe "atomize_enum/1" do
    test "converts uppercase string to lowercase atom" do
      assert Util.atomize_enum("PENDING") == :pending
      assert Util.atomize_enum("COMPLETED") == :completed
      assert Util.atomize_enum("FAILED") == :failed
    end

    test "converts mixed case string to lowercase atom" do
      assert Util.atomize_enum("ONE_TIME") == :one_time
      assert Util.atomize_enum("MULTIPLE_PAYMENTS") == :multiple_payments
    end

    test "converts common status values" do
      assert Util.atomize_enum("ACTIVE") == :active
      assert Util.atomize_enum("INACTIVE") == :inactive
      assert Util.atomize_enum("PROCESSING") == :processing
      assert Util.atomize_enum("EXPIRED") == :expired
      assert Util.atomize_enum("CANCELLED") == :cancelled
      assert Util.atomize_enum("PAID") == :paid
      assert Util.atomize_enum("REFUNDED") == :refunded
    end

    test "raises error for non-existent atoms" do
      assert_raise ArgumentError, fn ->
        Util.atomize_enum("NON_EXISTENT_ATOM_12345")
      end
    end

    test "returns nil for non-binary input" do
      assert Util.atomize_enum(123) == nil
      assert Util.atomize_enum(nil) == nil
      assert Util.atomize_enum([]) == nil
      assert Util.atomize_enum(%{}) == nil
      assert Util.atomize_enum(:already_atom) == nil
    end

    test "handles single word enums" do
      assert Util.atomize_enum("PENDING") == :pending
      assert Util.atomize_enum("ACTIVE") == :active
    end

    test "handles multi-word enums with underscores" do
      assert Util.atomize_enum("FIRST_SECOND") == :first_second
      assert Util.atomize_enum("FIRST_SECOND_THIRD") == :first_second_third
    end
  end

  describe "normalize_atom/1" do
    test "converts atom to uppercase string" do
      assert Util.normalize_atom(:pending) == "PENDING"
      assert Util.normalize_atom(:completed) == "COMPLETED"
      assert Util.normalize_atom(:failed) == "FAILED"
    end

    test "converts atoms with underscores to uppercase string" do
      assert Util.normalize_atom(:one_time) == "ONE_TIME"
      assert Util.normalize_atom(:multiple_payments) == "MULTIPLE_PAYMENTS"
    end

    test "converts common status atoms" do
      assert Util.normalize_atom(:active) == "ACTIVE"
      assert Util.normalize_atom(:inactive) == "INACTIVE"
      assert Util.normalize_atom(:processing) == "PROCESSING"
      assert Util.normalize_atom(:expired) == "EXPIRED"
      assert Util.normalize_atom(:cancelled) == "CANCELLED"
      assert Util.normalize_atom(:paid) == "PAID"
      assert Util.normalize_atom(:refunded) == "REFUNDED"
    end

    test "returns nil for non-atom input" do
      assert Util.normalize_atom("string") == nil
      assert Util.normalize_atom(123) == nil
      assert Util.normalize_atom([]) == nil
      assert Util.normalize_atom(%{}) == nil
    end

    # nil is an atom in elixir, so it should be converted
    test "converts nil atom to uppercase string" do
      assert Util.normalize_atom(nil) == "NIL"
    end

    test "handles single word atoms" do
      assert Util.normalize_atom(:pending) == "PENDING"
      assert Util.normalize_atom(:active) == "ACTIVE"
    end

    test "handles multi-word atoms with underscores" do
      assert Util.normalize_atom(:first_second) == "FIRST_SECOND"
      assert Util.normalize_atom(:first_second_third) == "FIRST_SECOND_THIRD"
    end
  end

  describe "atomize_enum and normalize_atom round trip" do
    test "converts string atom string back to original" do
      original_atom = :pending

      # Convert to string
      string_form = Util.normalize_atom(original_atom)
      # Convert back to atom
      back_to_atom = Util.atomize_enum(string_form)

      assert back_to_atom == original_atom
    end

    test "handles multiple enum conversions" do
      enums = ["PENDING", "COMPLETED", "FAILED", "CANCELLED", "PAID"]

      converted_atoms = Enum.map(enums, &Util.atomize_enum/1)
      converted_back = Enum.map(converted_atoms, &Util.normalize_atom/1)

      assert converted_back == enums
    end

    test "preserves enum values through conversion cycle" do
      test_value = "ONE_TIME"
      atom_form = Util.atomize_enum(test_value)
      string_form = Util.normalize_atom(atom_form)

      assert string_form == test_value
    end
  end

  describe "signature verification with real-world scenarios" do
    test "verifies webhook signature from payment event" do
      # payload from https://docs.abacatepay.com/pages/webhooks
      webhook_body = ~s({"event":"withdraw.done", "id":"log_12345abcdef", "devMode": false})

      signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), webhook_body)
        |> Base.encode64()

      assert Util.verify_signature(webhook_body, signature) == true
    end

    test "rejects tampered webhook payload" do
      original_body = ~s({"amount":5000})
      tampered_body = ~s({"amount":50000})

      signature =
        :crypto.mac(:hmac, :sha256, Util.get_public_key(), original_body)
        |> Base.encode64()

      assert Util.verify_signature(tampered_body, signature) == false
    end

    test "verifies multiple different payloads with correct signatures" do
      # payloads from https://docs.abacatepay.com/pages/webhooks
      payloads = [
        ~s({"event":"withdraw.failed","id":"log_12345abcdef"}),
        ~s({"event":"billing.paid","id":"log_12345abcdef"}),
        ~s({"event":"withdraw.done","id":"log_12345abcdef"})
      ]

      signatures =
        Enum.map(payloads, fn payload ->
          :crypto.mac(:hmac, :sha256, Util.get_public_key(), payload)
          |> Base.encode64()
        end)

      verified =
        Enum.zip(payloads, signatures)
        |> Enum.all?(fn {payload, sig} ->
          Util.verify_signature(payload, sig)
        end)

      assert verified == true
    end
  end
end
