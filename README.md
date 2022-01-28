This repository contains supplementary files - synthetic data, code, and analytically results - 
for the manuscript

> Mo Liu, Yang Wu, Nanhai Jiang, Arnoud Boot, Steven G. Rozen,
> ***mSigHdp: hierarchical Dirichlet process mixture modeling for mutational signature discovery***. 

See https://github.com/steverozen/mSigHdp and https://github.com/steverozen/hdpx for mSigHdp.

### Structure

The files are organized as follows.

At the top level are directories

- `SBS`: SBS (single-base substitution) synthetic input data, SBS-specific code, and SBS results
- `common_code`: Code used for both SBS and indel analysis
- `indel`: Indel (small insertion and deletion) synthetic input data, indel-specific code, and indel results
- `other_analysis`: Several additional analyses


The directories `indel` and `SBS` both have the same structure, as follows:
  - `code` contains code specific to either SBS or indel synthetic data generation and analysis.
      This code should be run with the top-level directory as the working
      directory. RStudio users, please open the .Rproj file in the top-level directory.
    - 1~3: Generate synthetic data
    - 4a~4d: Run 4 programs for signature extraction
    - 5~9: Summarize results. Need to run these scripts sequentially to prevent error.
  - `input` contains one file and 3 directories.
    - The file `{SBS,indel}_syn_data_distribution.pdf`
          provides plots that compare the distributions of mutation counts due
	  to each signature in real data and in the
	  synthetic data
    - The 3 directories are:
      - Noiseless: 
        Synthetic data with no negative binomial noise
      - Moderate:
        Synthetic data with moderate negative binomial noise
      - Realistic:
        Synthetic data with realistic negative binomial noise
      
    - Each directory contains the files:
      - ground.truth.syn.catalog.csv The synthetic tumor spectra in a format used by all programs other than SigProfilerExtractor
      - ground.truth.syn.catalog.tsv The synthetic tumor spectra in a format readable by SigProfilerExtractor
      - ground.truth.syn.exposures.csv The exposures of each synthetic tumor to each signature
      - ground.truth.syn.sigs.csv The ground truth signatures used to generate the synthetic data (identical for all SBS and for indel synthetic data sets)
      - {SBS,indel}\_syn_tumor_spectra\_{no,moderate,realistic}_noise.pdf Plots of the synthetic spectra

  - `raw_results` contains 4 directories, one for each tested program. Each directory contains: 
	- 3 Directories: `None` / `Moderate` / `Realistic` (sometimes indicated as High noise);
	  each of these directories contains 5 sub-directories called seed.Y, Y ∈ {145879, 200437, 310111, 528401, 1076753}
	  
	Each seed.Y directory contains:
	  - summary (summary of one run)
		- extracted.sigs.pdf: plots of extracted signatures
		- full.cossims.ex.to.gt.csv: Full cosine similarity matrix between ground-truth and extracted sigs.
		- match.ex.to.gt.csv: Match between extracted sigs and their
		  most similar ground-truth sigs (function
		  TP_FP_FN_avg_sim in package ICAMSxtra)   
	  - code.profile.Rdata or profiling_info.pickle: 
		CPU profiling info     
	  - extracted.signatures.csv          
	  - diagnostic_plots (only for mSigHdp): diagnostic plots        
	  - best.run (only for SignatureAnalyzer): results generated from the best run (basically
	    a run with the modal number of discovered signatures)  
			  
  - `summary` top-level summary tables and plots  
    - all_profiling_results.csv CPU profiling results
    - all_results.csv signature discovery accuracy  
    - cpu.profiling.pdf plot of CPU time
	- extraction.accuracy.pdf plot of extraction accuracy measures
	- {**SBS**,**indel**}.extracted.signature.to.gt.signature.csv Summary of matches between discovered (extracted) signatures and ground truth signatures
    + stats_by_approach_and_data_set.csv CSV version of main text
	  Table 1 (SBS) or Table 2 (indel)    
 
 ### License
 
 Copyright (C) 2022 Steven G Rozen, Mo Liu, and Yang Wu

 Code and data in this repository are free software: you can redistribute them and/or modify
 them under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This code and data are distributed in the hope that they will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this code and data at 
 https://github.com/Rozen-Lab/Liu_et_al_Sup_Files/blob/main/gpl-3.0.txt.
 If not, see <http://www.gnu.org/licenses/>.
    
