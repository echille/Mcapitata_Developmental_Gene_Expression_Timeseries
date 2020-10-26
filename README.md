# Montipora_OA_Development_Timeseries

<div style="width: 640px; height: 480px; margin: 10px; position: relative;"><iframe allowfullscreen frameborder="0" style="width:640px; height:480px" src="https://app.lucidchart.com/documents/embeddedchart/be6d7b57-e86e-4c26-a279-ce26a17c4b7c" id="4nsIf4Emwm65"></iframe></div>


This repository provides data and scripts to analyze the influence of ocean acidification on the early development of *Montipora capitata* focusing on physiology and gene expression.

*M. capitata* bundles were collected from the reef during the peak releases of June 2018 and fertilized in the lab. The gametes and embryos were exposed from fertilization throughout the developmental stages to controlled ocean acidification conditions. In addition, samples from each treatment were collected across the developmental stages; eggs, fertilized embryos, early cell division, prawn chip, gastrula, morula, blastula, and swimming larvae, in order to identify candidate genes which are responsible for the control of mineralization process. Samples were snap frozen in liquid nitrogen and stored at -80°C. RNA was extracted from 2-3 biological replicates for each treatment at each sampling point to identify the impact of each treatment on the expression pattern of genes involved in the biomineralization process. Samples were sequenced using Illumina stranded mRNA sequencing on the HiSeq targeting ~15million reads per sample.

Contents:  
- Rproj
- Scripts (html and Rmd copies)
    - cleavage_analysis
    - prawn_chip_size_analysis
    - planulae_size_analysis
    - gastrula_size_analysis
    - fertilized_embryo_size_analysis
    - egg_size_analysis
    - developmental_morphology_timeseries
        - Script containing all size and cleavage analyses
- Data
    - cell_cleavage.csv
    - cell_cleavage_metadata.csv
    - size_metric_timeseries_metadata.csv
    - size_metric_timeseries_data.csv
- Output
    - fig2_embryo_development.pdf

---

**Please execute all scripts in Rproj