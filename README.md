# GDC Breast Cancer Transcriptome GEM

Matt Harrington, Clemson University

2025-03-24

Access the code on GitHub: https://github.com/MHarrington576/make-gem-gdc

This script should be executed in the same directory that houses the directories of datasets downloaded from the manifest file.

To access the data to create the GEM:

1. Download the breast cancer (BRCA) manifest file from the GDC Data Portal
   
   • Connect to https://portal.gdc.cancer.gov/
   
   • Cohort Builder > Project > type TCGA-BRCA
   
   • Select: "Available Data", Data Category: "Transcriptome profiling", Experimental Strategy: "RNAseq", & Data Type: "Gene expression quantification"
   
   • Download the manifest file

2. Download the GDC client in a Linux environment and copy it into your PATH
```
   $ wget https://gdc.cancer.gov/system/files/public/file/gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip

   $ unzip gdc-client_2.3_Ubuntu_x64-py3.8-ubuntu-20.04.zip

   $ pip install
```
   • Copy the gdc client to your PATH


3. Access datasets from the manifest file via the GDC Client
```
   $ gdc-client download -m [name_of_manifest_file]
```
