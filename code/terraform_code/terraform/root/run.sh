export cde_processor_id=$(terraform output cde_processor_name)
pip3 install -r requirements.txt
python3 docai_processor_creation.py