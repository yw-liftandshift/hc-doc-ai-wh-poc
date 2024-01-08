import re
from enum import Enum

class FilenameFlags:
    """
    This class is responsible for adding the necessary flags to the filename.
    """
    class __FilenameFlagsEnum(Enum):
        FN = "FN_"
        V = "V_"

    def __add_filename_flag_to_filename_if_necessary(self, blob_name, file_number_list):
        # if we have more than one or zero file numbers than we have to add flag ATT_FN
        return (blob_name if len(file_number_list) == 1
                else self.__FilenameFlagsEnum.FN.value + blob_name)

    def __add_volume_flag_to_filename_if_necessary(self, blob_name, detected_volume):
        """
        Checks if the volume recognized by the OCR matches the volume in the blob name.
        If not, adds the flag ATT_FN to the blob name.

        Args:
            blob_name (str): The name of the blob.
            detected_volume (str): The volume recognized by the OCR.

        Returns:
            str: The blob name with the flag ATT_FN added if necessary.
        """
        # Regular expression to match "VOL" followed by digits and optional spaces
        pattern = r'VOL[-_ ]?(\d+)'

        # Search for the pattern in the text
        match = re.search(pattern, blob_name, re.IGNORECASE)

        volume_number_from_blob = match.group(1) if match is not None else None

        parts = []

        # volume might be format: N OF N', get only N
        if detected_volume is not None:
            parts = [part.strip()
                     for part in detected_volume.upper().split('OF')]

        volume_number_from_docai = parts[0] if len(parts) > 0 else None

        if volume_number_from_blob != volume_number_from_docai:
            return self.__FilenameFlagsEnum.V.value + blob_name
        else:
            return blob_name
        
    def add_necessary_flags(self, blob_name, detected_volume, file_number_list):
        """
        Adds the necessary flags to the blob name
        """
        new_blob_name = self.__add_filename_flag_to_filename_if_necessary(blob_name, file_number_list)
        new_blob_name = self.__add_volume_flag_to_filename_if_necessary(new_blob_name, detected_volume)

        if new_blob_name != blob_name:
            new_blob_name = "ATT_" + new_blob_name 
        return new_blob_name
