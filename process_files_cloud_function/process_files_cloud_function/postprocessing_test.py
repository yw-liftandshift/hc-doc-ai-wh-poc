from unittest.mock import Mock
from google.cloud import documentai_v1 as documentai
import proto.marshal.collections.repeated



from api_call_utils import DocumentWarehouseProperties
from postprocessing import (
    DocumentType,
    build_documents_warehouse_properties_from_entities,
)


def test_get_document_type():
    assert DocumentType.LRS_DOCUMENTS_TYPE == DocumentType["LRS_DOCUMENTS_TYPE"]
    assert DocumentType.GENERAL_DOCUMENTS_TYPE == DocumentType["GENERAL_DOCUMENTS_TYPE"]


def test_build_documents_warehouse_properties_from_entities():
    file_number = "9999-B888A-7777"
    barcode_number = "55555555555555"
    classification_code = "1"
    classification_level = "2"
    file_title = "Drug Research"
    volume = "1"
    org_code = "4"
    display_name = "test"

    documentWarehousePropertiesExpected = DocumentWarehouseProperties()
    documentWarehousePropertiesExpected.file_number = file_number
    documentWarehousePropertiesExpected.barcode_number = barcode_number
    documentWarehousePropertiesExpected.classification_code = classification_code
    documentWarehousePropertiesExpected.classification_level = classification_level
    documentWarehousePropertiesExpected.file_title = file_title
    documentWarehousePropertiesExpected.volume = volume
    documentWarehousePropertiesExpected.org_code = org_code
    documentWarehousePropertiesExpected.display_name = display_name
    
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

    documentWarehousePropertiesActual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.LRS_DOCUMENTS_TYPE
    )

    assert documentWarehousePropertiesExpected == documentWarehousePropertiesActual

def test_build_documents_warehouse_properties_from_entities_general_document_type():
    file_number = "9999-B888A-7777"
    file_title = "Drug Research"
    volume = "1"
    printed_date = "01/01/2022"
    company_name = "Some Pharm Company"
    address = "123 Main St, Anytown, Canada"
    display_name = "test"

    documentWarehousePropertiesExpected = DocumentWarehouseProperties()
    documentWarehousePropertiesExpected.file_number = [file_number]
    documentWarehousePropertiesExpected.file_title = 'Drug Research - Some Pharm Company - 123 Main St, Anytown, Canada'
    documentWarehousePropertiesExpected.volume = volume
    documentWarehousePropertiesExpected.display_name = 'ATT_V_FN_test'
    documentWarehousePropertiesExpected.date = printed_date
    
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

    documentWarehousePropertiesActual = build_documents_warehouse_properties_from_entities(
        entities, display_name, DocumentType.GENERAL_DOCUMENTS_TYPE
    )

    assert documentWarehousePropertiesExpected == documentWarehousePropertiesActual
    