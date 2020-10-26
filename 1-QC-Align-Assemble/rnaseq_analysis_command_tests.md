# *M. capitata* RNAseq Analysis Pipeline Tests

Author: Erin Chille 
Last Updated: 2020/02/12  
Data uploaded and analyzed on KITT server (made by [J. Puritz](https://github.com/jpuritz))  

*The following document contains the commands and output we used to test the pipeline below for cleaning, aligning and assembling our raw RNA sequences. Please refer to [M. capitata RNAseq Analysis](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/mcap_rnaseq_analysis.md) for the full analysis.*

---

### Project overview

![bioinformatic_pipeline.png](https://raw.githubusercontent.com/echille/Montipora_OA_Development_Timeseries/master/_images/bioinformatic_pipeline.png)  

**Bioinformatic tools used in analysis:**  
Quality check: [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [MultiQC](https://multiqc.info/)  
Quality trimming: [Fastp](https://github.com/OpenGene/fastp)  
Alignment to reference genome: [HISAT2](https://ccb.jhu.edu/software/hisat2/index.shtml)  
Preparation of alignment for assembly: [SAMtools](http://www.htslib.org/doc/samtools.html)  
Transcript assembly and quantification: [StringTie](https://ccb.jhu.edu/software/stringtie/) 

### Quality control and read trimming

#### Cleaning reads - FastP
- Remove adapters
- Remove low-quality reads
- Remove reads with high abundance of unknown bases

Tested FastP on sample 119.

**FastP Arguments/Options Tested**  
- **--in1** - path to forward read input  
- **--in2** - path to reverse read input  
- **--out1** - path to forward read output  
- **--out2** - path to reservse read output  
- **--failed_out** - Specify file to store reads that fail filters  
- **--qualified_quality_phred** - Phred quality >= -q is qualified (20)
- **--unqualified_percent_limit** - % of bases allowed to be unqualified (10)  
- **--length_required** - Set required sequence length (100)
- **--detect_adapter_for_pe** - Adapters can be trimmed by overlap analysis, however, --detect_adapter_for_pe will usually result in slightly cleaner output than overlap detection alone. This results in a slightly slower run time  
- **--cut_right** - Move a sliding window from front to tail. Use cut_right_window_size to set the window size (5), and cut_right_mean_quality (20) to set the mean quality threshold.  
- **--html** - the html format report file name

```
fastp --in1 119_R1_001.fastq.gz --in2 119_R2_001.fastq.gz --out1 ../cleaned_reads/119_R1_001.clean.fastq.gz --out2 ../cleaned_reads/119_R2_001.clean.fastq.gz --failed_out ../cleaned_reads/119_failed --qualified_quality_phred 20 --unqualified_percent_limit 10 --length_required 100 detect_adapter_for_pe --cut_right cut_right_window_size 5 cut_right_mean_quality 20 --html fastp_trial_119.html
```
- [x] **Trial FastP trimming results (Sample 119):**  
reads passed filter: 31470942  
reads failed due to low quality: 1965090  
reads failed due to too many N: 196  
reads failed due to too short: 9425392  
reads with adapter trimmed: 15188276  
bases trimmed due to adapters: 483892914  
*Time used: 434 seconds*   
![trial_trim_read1_sequence_quality.png](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Output/commandtests/trial_trim_read1_sequence_quality.png?raw=true)  
![trial_trim_read2_sequence_quality.png](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Output/commandtests/trial_trim_read2_sequence_quality.png?raw=true)


### Alignment of clean reads to reference genome - HISAT2

**Tested the rest of the pipeline on two of the shortest sequences (133 and 158).**

Test of alignment to the index files:

**HISAT2 Arguments/Options Tested**   
- **-x <hisat2-idx>** - Basename of index files to read  
- **-1 <m1>** - List of forward sequence files  
- **-2 <m1>** - List of reverse sequence files  
- **-S** - Name of output files
- **-q** - Input files are in FASTQ format  
- **-p** - Number processors
- **--dta** - Adds the XS tag to indicate the genomic strand that produced the RNA from which the read was sequenced. As noted by StringTie... "be sure to run HISAT2 with the --dta option for alignment, or your results will suffer."

```
hisat2 -p 8 --dta -q -x Mcap_ref -1 ../cleaned_reads/133_R1_001.clean.fastq.gz -2 ../cleaned_reads/133_R2_001.clean.fastq.gz -S 133_alignment.sam

hisat2 -p 8 --dta -q -x Mcap_ref -1 ../cleaned_reads/158_R1_001.clean.fastq.gz -2 ../cleaned_reads/158_R2_001.clean.fastq.gz -S 158_alignment.dta.sam
```

- [x] **Trial HISAT Alignment Results Sample 133**
14505821 reads; of these:
  14505821 (100.00%) were paired; of these:
    2252903 (15.53%) aligned concordantly 0 times
    8936207 (61.60%) aligned concordantly exactly 1 time
    3316711 (22.86%) aligned concordantly >1 times
    
    2252903 pairs aligned concordantly 0 times; of these:
      45023 (2.00%) aligned discordantly 1 time
    
    2207880 pairs aligned 0 times concordantly or discordantly; of these:
      4415760 mates make up the pairs; of these:
        4009004 (90.79%) aligned 0 times
        342905 (7.77%) aligned exactly 1 time
        63851 (1.45%) aligned >1 times
86.18% overall alignment rate
- [x] **Trial HISAT Alignment Results Sample 158**   
13354481 reads; of these:
  13354481 (100.00%) were paired; of these:
    1761809 (13.19%) aligned concordantly 0 times
    7786555 (58.31%) aligned concordantly exactly 1 time
    3806117 (28.50%) aligned concordantly >1 times
    
    1761809 pairs aligned concordantly 0 times; of these:
      42702 (2.42%) aligned discordantly 1 time
    
    1719107 pairs aligned 0 times concordantly or discordantly; of these:
      3438214 mates make up the pairs; of these:
        3099481 (90.15%) aligned 0 times
        273219 (7.95%) aligned exactly 1 time
        65514 (1.91%) aligned >1 times
88.40% overall alignment rate

### Assembly of clean reads - StringTie

Now we can assemble the reads with StringTie.

We ran StringTie twice. The first time for a reference-guided assembly allows for novel sequences (e.g. sequences not present in the reference) to be included in the output. Then we merged the two GTF files to guide the next round of StringTie. This part required a TXT file providing the path to the GTF files. We called this ```mergelist.txt```. GFFcompare then compared the merged GTF file to reference file to estimate sensitivity and precision statistics and total number of various features (i.e. genes, exons, transcripts). 

**StringTie Arguments/Options Tested**  
- **-p** - Specify number of processers
- **-G** - Specify annotation file
- **-o** - Name of output file

```
stringtie -p 8 -G ../ref/Mcap.GFFannotation.gff -o 158_assembly-e.gtf 158_alignment.bam
stringtie -p 8 -G ../ref/Mcap.GFFannotation.gff -o 133_assembly.gtf 133_alignment.bam
stringtie --merge -p 8 -G Mcap.GFFannotation.gff -o stringtie_merged.gtf mergelist.txt
gffcompare -r Mcap.GFFannotation.gff -G -o merged stringtie_merged.gtf
```

- [x] **Trial Reference-Guided Assembly Output - StringTie**  
*For the full stats see file, [merged.133-158stats](https://github.com/echille/Montipora_OA_Development_Timeseries/blob/master/Output/commandtests/merged.133-158stats).*  
53875 reference transcripts loaded.  
167402 query transfrags loaded.  
++Summary for dataset:++  
Query mRNAs :   71847 in   64882 loci; 42774 multi-exon transcripts; 4492 multi-transcript loci, ~1.1 transcripts per locus  
Reference mRNAs :   53875 in   53875 loci  (32277 multi-exon)  
Super-loci w/ reference transcripts: 53390  
Total union super-loci across all input datasets: 64882   
71847 out of 71847 consensus transcripts written in merged.annotated.gtf (0 discarded as redundant)  


We ran StringTie again, but this time the assembly was guided by the merged GTF file ```stringtie_merged.gtf``` and StringTie skipped over novel sequences by specifying the ```-e``` option. This is okay now because we identified novel transcripts in the previous StringTie run. This option is the important part of this second run because the ```prepDE.py``` script used to compile the output GTFs from this step into CSV files only works if the -e option is included here.

**StringTie Arguments/Options Tested**  
- **-p** - Specify number of processers
- **-G** - Specify annotation file
- **-o** - Name of output file
- **-e** - Skips over novel sequences. 
```
./stringtie -p 8 -e -G ../stringtie_merged.gtf -o ../133_assembly.merged.gtf ../133_alignment.bam
./stringtie -p 8 -e -G ../stringtie_merged.gtf -o ../158_assembly.merged.gtf ../158_alignment.bam
```

Finally, the StringTie script ```prepDE.py``` compiled the assembled files together into a DESeq2-friendly version.

**StringTie prepDE Arguments/Options Tested**
- **-g** - Specifies output of gene count matrix
- **-t** - Specifies output of transcript count matrix
- **-i** - Specifies TXT file listing sample IDs and path to that sample's GTF file
```
./prepDE.py -g -t -i ../sample_list.txt
mv *.csv ../
```

- [x] **Trial Count Matrix - StringTie prepDE**  
transcript_id,133_assembly,158_assembly  
g19583.t1,0,0  
g12808.t1,0,0  
MSTRG.24752.1,198,0  
MSTRG.24752.3,0,350  
g67308.t1,549,144  
g47748.t1,0,0  
g8702.t1,0,0  
g58497.t1,0,27  
g46237.t1,0,0  

This count matrix was used as input into DeSeq2 to perform differential expression analyses. Please refer to [M. capitata Differential Expression]().