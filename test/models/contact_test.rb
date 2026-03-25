require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "normalize_phone remove 55 em números BR de 13 dígitos" do
    assert_equal "22997574332", Contact.normalize_phone("5522997574332")
    assert_equal "22997574332", Contact.normalize_phone("+55 (22) 99757-4332")
  end

  test "phone_lookup_keys inclui variante com 55" do
    keys = Contact.phone_lookup_keys("22997574332")
    assert_includes keys, "22997574332"
    assert_includes keys, "5522997574332"
  end
end
