This repository is designed to work with the Metricks repository from AOIPLab. The specific release is forked as Metricks_Warr_2024.
University of Houston College of Optometry
Principal Investigator: Jason Porter
Developer: Godfred Sakyi Badu

Background to AutoMetricks.
Previously, generating Metricks for different regions of interest (ROIs) within the same montage had to be performed sequentially, which was time‑consuming. AutoMetricks was developed to address this limitation by enabling the simultaneous generation of Metricks for all ROIs extracted from a single montage.
In the Porter Lab, each generated ROI is expected to contain approximately 100 bound cones. Accordingly, the program verifies the cone count for each ROI. Any ROIs that do not meet this criterion are flagged, and their names are automatically saved to an Excel file for further review.
