This repository is designed to work with the Metricks repository from AOIPLab. The specific release is forked as Metricks_Warr_2024.

Originator of Metricks Code
Warr E, Grieshop J, Cooper RF, Carroll J. The effect of sampling window size on topographical maps of foveal cone density. Front Ophthalmol (Lausanne). 2024 Apr 9;4:1348950. doi: 10.3389/fopht.2024.1348950. PMID: 38984138; PMCID: PMC11182112.

University of Houston College of Optometry

Principal Investigator: Jason Porter

Developer: Godfred Sakyi Badu

Background to AutoMetricks.
Previously, generating Metricks for different regions of interest (ROIs) within the same montage had to be performed sequentially, which was time‑consuming. AutoMetricks was developed to address this limitation by enabling the simultaneous generation of Metricks for all ROIs extracted from a single montage.
In the Porter Lab, each generated ROI is expected to contain approximately 100 bound cones. Accordingly, the program verifies the cone count for each ROI. Any ROIs that do not meet this criterion are flagged, and their names are automatically saved to an Excel file for further review.

Steps to Use AutoMetricks
1.	Run autoROIMetricks.m matlab cod

2.	Select Folder containing Regions of Interests (ROIs).
   
a.	For correct naming, the program excepts the ROIs to be named with the “Location “space” Distance from Fovea. For example, for an ROI of Inferior 50 microns, Folder name should be = “Inferior 50”
    <img width="887" height="488" alt="image" src="https://github.com/user-attachments/assets/b5f298e1-9fa2-405b-b432-af1e15009021" />
3.Select the Folder containing the AutoMetricks Code
<img width="1073" height="617" alt="Screenshot (18)" src="https://github.com/user-attachments/assets/7c2da675-a8ad-425d-982a-fbaa67891cc3" />

 
4.	Enter scaling in microns per pixels (Scaling parameters are applied to every ROI in the folder)
<img width="427" height="274" alt="image" src="https://github.com/user-attachments/assets/f8957a0a-86ef-4e7b-acc5-ea6e5040ba2b" />

 
5.	 Enter scaling in pixels per degree
	 <img width="470" height="274" alt="image" src="https://github.com/user-attachments/assets/56d5ee68-25fd-4d16-a65f-4af65ba1ab20" />

 
6.	Select the output units. Typically (microns (mm) density) is selected.
	<img width="438" height="738" alt="image" src="https://github.com/user-attachments/assets/bda036f2-3fb7-42ca-b89d-786f1805c7fe" />

  
7.	Program runs 

8.	If there are any ROIs which could not have the required number of Bound Cells, they are written in a CSV file.

a.	For these ROIs,  just get a larger ROIs size in Mosaics, and run the Program, “Coordinate_Mosaic_Metrics_non_Map_modified.m” 
