import pytest
from src.roman_to_arabic import roman_to_arabic, is_roman_number

@pytest.mark.parametrize("roman, arabic",[("I","1"),("V","5"),("X","10"),("L","50"),("C", "100"),
                                          ("MMDCCLXXIII", "2773"), ("MMMCMXCIX", "3999"), ("IV","4"),
                                          ("VIII", "8"),("IX", "9"), ("XVI", "16")])
def test_roman_to_arabic(roman, arabic):
    assert roman_to_arabic(roman) == arabic

@pytest.mark.parametrize("roman, output",[("I",True),("V",True),("X",True),("L",True),("C", True),
                                          ("MMDCCLXXIII", True), ("MMMCMXCIX", True), ("IV",True),
                                          ("VIII", True),("IX", True), ("XVI", True),
                                          ("9", False),("5", False),("16", False),("1", False)])
def test_is_roman_number(roman, output):
    assert is_roman_number(roman) == output
