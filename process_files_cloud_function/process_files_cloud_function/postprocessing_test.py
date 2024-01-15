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

    documentWarehousePropertiesExpected = DocumentWarehouseProperties()
    documentWarehousePropertiesExpected.file_number = file_number
    documentWarehousePropertiesExpected.barcode_number = barcode_number
    documentWarehousePropertiesExpected.classification_code = classification_code
    documentWarehousePropertiesExpected.classification_level = classification_level
    documentWarehousePropertiesExpected.file_title = file_title
    documentWarehousePropertiesExpected.volume = volume
    documentWarehousePropertiesExpected.org_code = org_code
    
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
        entities, "test.pdf", DocumentType.LRS_DOCUMENTS_TYPE
    )

    assert documentWarehousePropertiesExpected == documentWarehousePropertiesActual
    