import pytest

from src.postprocessing.filename_flags import FilenameFlags


@pytest.mark.parametrize(
    "blob_name, file_number_list, detected_volume, expected_new_blob_name",
    [
        ("123456 vol 1.pdf", ["123456"], "1", "123456 vol 1.pdf"),
        ("123456 vol 1.pdf", ["123456", "654321"], "1", "ATT_FN_123456 vol 1.pdf"),
        ("123456 vol 1.pdf", [], "1", "ATT_FN_123456 vol 1.pdf"),
        ("123456 vol 1.pdf", ["123457"], "1", "ATT_FN_123456 vol 1.pdf"),

        ("123456 vol 1.pdf", ["123456"], "1", "123456 vol 1.pdf"),
        ("123456 vol 1 of 2.pdf", ["123456"], "1", "123456 vol 1 of 2.pdf"),
        ("123456 vol 1.pdf", ["123456"], "2", "ATT_V_123456 vol 1.pdf"),
        ("123456 vol_1.pdf", ["123456"], "2", "ATT_V_123456 vol_1.pdf"),
        ("123456_vol-1.pdf", ["123456"], "2", "ATT_V_123456_vol-1.pdf"),
        ("123456-vol-1.pdf", ["123456"], "2", "ATT_V_123456-vol-1.pdf"),
        ("123456-vol-1-of-2.pdf", ["123456"], "2", "ATT_V_123456-vol-1-of-2.pdf"),
        ("123456 vol 1 of 2.pdf", ["123456"], "2", "ATT_V_123456 vol 1 of 2.pdf"),
        ("123456_vol_1_of_2.pdf", ["123456"], "2", "ATT_V_123456_vol_1_of_2.pdf"),
        
        ("123456_vol_1_of_2.pdf", ["123456", "654321"], "2", "ATT_V_FN_123456_vol_1_of_2.pdf"),
    ],
)
def test_add_filename_flag_to_filename_if_necessary(blob_name, file_number_list, detected_volume, expected_new_blob_name
):
    filename_flags = FilenameFlags()

    actual_new_blob_name = filename_flags.add_necessary_flags(
        blob_name, detected_volume, file_number_list
    )

    assert expected_new_blob_name == actual_new_blob_name