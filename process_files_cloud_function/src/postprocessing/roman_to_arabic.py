import re


def roman_to_arabic(roman_num):
    roman_num_dict = {'I': 1, 'V': 5, 'X': 10,
                      'L': 50, 'C': 100, 'D': 500, 'M': 1000}
    result = 0
    for i in range(len(roman_num)):
        if i + 1 < len(roman_num) and roman_num_dict[roman_num[i]] < roman_num_dict[roman_num[i + 1]]:
            result -= roman_num_dict[roman_num[i]]
        else:
            result += roman_num_dict[roman_num[i]]
    return str(result)


def is_roman_number(roman_num):
    pattern = re.compile(r"""   
                                ^M{0,3}
                                (CM|CD|D?C{0,3})?
                                (XC|XL|L?X{0,3})?
                                (IX|IV|V?I{0,3})?$
            """, re.VERBOSE)
    if re.match(pattern, roman_num):
        return True
    return False
