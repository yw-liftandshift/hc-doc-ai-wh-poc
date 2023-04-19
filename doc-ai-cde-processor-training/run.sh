#!/bin/bash

set -euxo pipefail

unzip data/tagged_data.zip
gsutil -m cp -r tagged_data/exported-cde-tagged-data gs://marcus-test-doc-wh-poc-1-cde-processor-training-bucket
pip3 install -r requirements.txt
python3 doc_ai_processor_training.py