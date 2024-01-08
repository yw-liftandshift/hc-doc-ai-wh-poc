import pytest

from ...src.postprocessing.filename_flags import FilenameFlags


@pytest.mark.parametrize(
    "blob_name, file_number_list, expected_new_blob_name",
    [
        ("123456.pdf", ["123456"], "FN_123456.pdf"),
        ("123456.pdf", ["123456", "789012"], "ATT_FN_123456.pdf"),
        ("123456_VOL1_OF_2.pdf", "1", "123456_VOL1_OF_2.pdf"),
        ("123456_VOL1_OF_2.pdf", "2", "V_123456_VOL1_OF_2.pdf"),
        ("123456.pdf", [], "FN_123456.pdf"),
        ("123456_VOL1_OF_2.pdf", None, "FN_123456_VOL1_OF_2.pdf"),
    ],
)
def test_add_filename_flag_to_filename_if_necessary(blob_name, file_number_list, expected_new_blob_name
):
    filename_flags = FilenameFlags()

    actual_new_blob_name = filename_flags.add_necessary_flags(
        blob_name, None, file_number_list
    )

    assert expected_new_blob_name == actual_new_blob_name

@pytest.mark.parametrize(
    "blob_name, detected_volume, expected_new_blob_name",
    [
        ("123456_VOL1_OF_2.pdf", "1", "123456_VOL1_OF_2.pdf"),
        ("123456_VOL1_OF_2.pdf", "2", "V_123456_VOL1_OF_2.pdf"),
    ],
)
def test_add_volume_flag_to_filename_if_necessary(
    blob_name, detected_volume, expected_new_blob_name
):
    filename_flags = FilenameFlags()

    actual_new_blob_name = filename_flags.add_volume_flag_to_filename_if_necessary(
        blob_name, detected_volume
    )

    assert expected_new_blob_name == actual_new_blob_name

@pytest.mark.parametrize(
    "blob_name, file_number_list, detected_volume, expected_new_blob_name",
    [
        ("123456.pdf", ["123456"], None, "FN_123456.pdf"),
        ("123456.pdf", [], "2", "V_123456.pdf"),
        ("123456_VOL1_OF_2.pdf", ["123456", "789012"], "2", "ATT_FN_123456_VOL1_OF_2.pdf"),
    ],
)
def test_add_necessary_flags(
    blob_name, file_number_list, detected_volume, expected_new_blob_name
):
    filename_flags = FilenameFlags()

    actual_new_blob_name = filename_flags.add_necessary_flags(
        blob_name, detected_volume, file_number_list
    )

    assert expected_new_blob_name == actual_new_blob_name
