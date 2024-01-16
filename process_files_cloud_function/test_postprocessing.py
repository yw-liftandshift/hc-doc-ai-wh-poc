from unittest.mock import Mock
from google.cloud import documentai_v1 as documentai
import proto.marshal.collections.repeated
import pytest



from api_call_utils import DocumentWarehouseProperties
from postprocessing import (
    DocumentType,
    get_document_type,
    build_documents_warehouse_properties_from_entities,
)


def test_get_document_type():
    assert DocumentType.LRS_DOCUMENTS_TYPE == get_document_type("LRS_DOCUMENTS_TYPE")
    assert DocumentType.GENERAL_DOCUMENTS_TYPE == get_document_type("GENERAL_DOCUMENTS_TYPE")
    assert None == get_document_type("UNKNOWN_TYPE")


def test_build_documents_warehouse_properties_from_entities():
    file_number = "9999-B888A-7777"
    barcode_number = "55555555555555"
    classification_code = "1"
    classification_level = "2"
    file_title = "Drug Research"
    volume = "1"
    org_code = "4"
    display_name = "test"

    document_warehouse_properties_expected = DocumentWarehouseProperties()
    document_warehouse_properties_expected.file_number = file_number
    document_warehouse_properties_expected.barcode_number = barcode_number
    document_warehouse_properties_expected.classification_code = classification_code
    document_warehouse_properties_expected.classification_level = classification_level
    document_warehouse_properties_expected.file_title = file_title
    document_warehouse_properties_expected.volume = volume
    document_warehouse_properties_expected.org_code = org_code
    document_warehouse_properties_expected.display_name = display_name
    
    entities = Mock(spec=proto.marshal.collections.repeated.RepeatedComposite)

    items_ = [
        ('file_number', file_number),
        ('barcode_number', barcode_number),
        ('classification_code', classification_code),
        ('classification_level', classification_level),
        ('file_title', file_title),
        ('volume', volume),
        ('org_code', org_code),
    ]
    mocked_entities = [Mock(spec=documentai.Document.Entity) for _ in range(len(items_))]

    for i, (type_, mention_text) in enumerate(items_):
        mocked_entities[i].type_ = type_
        mocked_entities[i].mention_text = mention_text

    entities.pb = mocked_entities

    document_warehouse_properties_actual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.LRS_DOCUMENTS_TYPE
    )

    assert document_warehouse_properties_expected == document_warehouse_properties_actual

def test_build_documents_warehouse_properties_from_entities_general_document_type():
    file_number = "9999-B888A-7777"
    file_title = "Drug Research"
    volume = "1"
    printed_date = "01/01/2022"
    company_name = "Some Pharm Company"
    address = "123 Main St, Anytown, Canada"
    display_name = "test"

    document_warehouse_properties_expected = DocumentWarehouseProperties()
    document_warehouse_properties_expected.file_number = [file_number]
    document_warehouse_properties_expected.file_title = 'Drug Research - Some Pharm Company - 123 Main St, Anytown, Canada'
    document_warehouse_properties_expected.volume = volume
    document_warehouse_properties_expected.display_name = 'ATT_V_FN_test'
    document_warehouse_properties_expected.date = printed_date
    
    entities = Mock(spec=proto.marshal.collections.repeated.RepeatedComposite)

    items_ = [
        ('file_no', file_number),
        ('full_title', file_title),
        ('volume', volume),
        ('printed_date', printed_date),
        ('company_name', company_name),
        ('address', address),
    ]
    mocked_entities = [Mock(spec=documentai.Document.Entity) for _ in range(len(items_))]

    for i, (type_, mention_text) in enumerate(items_):
        mocked_entities[i].type_ = type_
        mocked_entities[i].mention_text = mention_text
        if (type_ == 'printed_date'):
            mocked_entities[i].normalized_value = Mock(spec=documentai.Document.Entity.NormalizedValue)
            mocked_entities[i].normalized_value.text = printed_date

    entities.pb = mocked_entities

    document_warehouse_properties_actual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.GENERAL_DOCUMENTS_TYPE
    )

    assert document_warehouse_properties_expected == document_warehouse_properties_actual

@pytest.mark.parametrize("volume, output", [("XXVII", "27"),("I of IV", "1 OF 4"), ("1 of 2", "1 of 2")])
def test_build_documents_warehouse_properties_from_entities_general_volume(volume, output):
    file_number = "9999-B888A-7777"
    file_title = "Drug Research"
    printed_date = "01/01/2022"
    company_name = "Some Pharm Company"
    address = "123 Main St, Anytown, Canada"
    display_name = "test"

    document_warehouse_properties_expected = DocumentWarehouseProperties()
    document_warehouse_properties_expected.file_number = [file_number]
    document_warehouse_properties_expected.file_title = 'Drug Research - Some Pharm Company - 123 Main St, Anytown, Canada'
    document_warehouse_properties_expected.volume = output
    document_warehouse_properties_expected.display_name = 'ATT_V_FN_test'
    document_warehouse_properties_expected.date = printed_date
    
    entities = Mock(spec=proto.marshal.collections.repeated.RepeatedComposite)

    items_ = [
        ('file_no', file_number),
        ('full_title', file_title),
        ('volume', volume),
        ('printed_date', printed_date),
        ('company_name', company_name),
        ('address', address),
    ]
    mocked_entities = [Mock(spec=documentai.Document.Entity) for _ in range(len(items_))]

    for i, (type_, mention_text) in enumerate(items_):
        mocked_entities[i].type_ = type_
        mocked_entities[i].mention_text = mention_text
        if (type_ == 'printed_date'):
            mocked_entities[i].normalized_value = Mock(spec=documentai.Document.Entity.NormalizedValue)
            mocked_entities[i].normalized_value.text = printed_date

    entities.pb = mocked_entities

    document_warehouse_properties_actual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.GENERAL_DOCUMENTS_TYPE
    )

    assert document_warehouse_properties_expected == document_warehouse_properties_actual

@pytest.mark.parametrize("file_title, output", [(None, " - Some Pharm Company - 123 Main St, Anytown, Canada"),
                                                ("", " - Some Pharm Company - 123 Main St, Anytown, Canada"),
                                                ("Drug Research Some Pharm Company", "Drug Research Some Pharm Company - 123 Main St, Anytown, Canada")])
def test_build_documents_warehouse_properties_from_entities_general_file_title(file_title, output):
    file_number = "9999-B888A-7777"
    volume = "1"
    printed_date = "01/01/2022"
    company_name = "Some Pharm Company"
    address = "123 Main St, Anytown, Canada"
    display_name = "test"

    document_warehouse_properties_expected = DocumentWarehouseProperties()
    document_warehouse_properties_expected.file_number = [file_number]
    document_warehouse_properties_expected.file_title = output
    document_warehouse_properties_expected.volume = volume
    document_warehouse_properties_expected.display_name = 'ATT_V_FN_test'
    document_warehouse_properties_expected.date = printed_date
    
    entities = Mock(spec=proto.marshal.collections.repeated.RepeatedComposite)

    items_ = [
        ('file_no', file_number),
        ('full_title', file_title),
        ('volume', volume),
        ('printed_date', printed_date),
        ('company_name', company_name),
        ('address', address),
    ]
    mocked_entities = [Mock(spec=documentai.Document.Entity) for _ in range(len(items_))]

    for i, (type_, mention_text) in enumerate(items_):
        mocked_entities[i].type_ = type_
        mocked_entities[i].mention_text = mention_text
        if (type_ == 'printed_date'):
            mocked_entities[i].normalized_value = Mock(spec=documentai.Document.Entity.NormalizedValue)
            mocked_entities[i].normalized_value.text = printed_date

    entities.pb = mocked_entities

    document_warehouse_properties_actual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.GENERAL_DOCUMENTS_TYPE
    )

    assert document_warehouse_properties_expected == document_warehouse_properties_actual

@pytest.mark.parametrize("date, output", [("1999", "1999-00-00"),
                                          ("1999-05", "1999-05-00"),
                                          ("1999-05-07", "1999-05-07")])
def test_build_documents_warehouse_properties_from_entities_general_date(date, output):
    file_number = "9999-B888A-7777"
    file_title = "Drug Research"
    volume = "1"
    printed_date = date
    company_name = "Some Pharm Company"
    address = "123 Main St, Anytown, Canada"
    display_name = "test"

    document_warehouse_properties_expected = DocumentWarehouseProperties()
    document_warehouse_properties_expected.file_number = [file_number]
    document_warehouse_properties_expected.file_title = 'Drug Research - Some Pharm Company - 123 Main St, Anytown, Canada'
    document_warehouse_properties_expected.volume = volume
    document_warehouse_properties_expected.display_name = 'ATT_V_FN_test'
    document_warehouse_properties_expected.date = output
    
    entities = Mock(spec=proto.marshal.collections.repeated.RepeatedComposite)

    items_ = [
        ('file_no', file_number),
        ('full_title', file_title),
        ('volume', volume),
        ('printed_date', printed_date),
        ('company_name', company_name),
        ('address', address),
    ]
    mocked_entities = [Mock(spec=documentai.Document.Entity) for _ in range(len(items_))]

    for i, (type_, mention_text) in enumerate(items_):
        mocked_entities[i].type_ = type_
        mocked_entities[i].mention_text = mention_text
        if (type_ == 'printed_date'):
            mocked_entities[i].normalized_value = Mock(spec=documentai.Document.Entity.NormalizedValue)
            mocked_entities[i].normalized_value.text = printed_date

    entities.pb = mocked_entities

    document_warehouse_properties_actual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.GENERAL_DOCUMENTS_TYPE
    )

    assert document_warehouse_properties_expected == document_warehouse_properties_actual
    