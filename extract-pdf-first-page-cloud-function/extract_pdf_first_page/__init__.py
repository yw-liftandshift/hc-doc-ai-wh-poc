import io
import pypdf
from .config import config


def extract_pdf_first_page(pdf_content: bytes):
    with io.BytesIO(pdf_content) as pdf_content_bytes_stream:
        # Open the pdf file from memory
        pdf_reader = pypdf.PdfReader(pdf_content_bytes_stream)
        first_page = pdf_reader.pages[0]

        # Create a buffer for the new pdf file
        output_pdf_buffer = io.BytesIO()
        pdf_writer = pypdf.PdfWriter(output_pdf_buffer)
        pdf_writer.add_page(first_page)

        # Save the first page of the file in memory
        output_pdf_stream = io.BytesIO()
        pdf_writer.write(output_pdf_stream)
        output_pdf_stream.seek(0)

        return output_pdf_stream
