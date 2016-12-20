#!/bin/bash

#########################################################
### Alexander Kanitz, Biozentrum, University of Basel ###
### alexander.kanitz@alumni.ethz.ch                   ###
### 15-NOV-2016                                       ###
#########################################################


#####################
###  DESCRIPTION  ###
#####################

# Downloads raw data in SRA format given a table of study and run IDs.


####################
###  PARAMETERS  ###
####################

# Set root directory
root="$(dirname $(dirname $(dirname $(cd "$(dirname "$0" )" && pwd))))"

# Set other parameters
scriptDir="${root}/scriptsSoftware"
dataDir="${root}/analyzedData/align_and_quantify/sra_data"
outDir="${root}/analyzedData/align_and_quantify/sra_data/merged"
tmpDir="${root}/.tmp/analyzedData/align_and_quantify/sra_data"
logDir="${root}/logFiles/analyzedData/align_and_quantify/sra_data"
sampleTable="${root}/internalResources/sra_data/samples.tsv"
hsaTranscripts="${root}/publicResources/genome_resources/hsa.GRCh38_84/hsa.GRCh38_84.transcripts.filtered.tsv.gz"
mmuTranscripts="${root}/publicResources/genome_resources/mmu.GRCm38_84/mmu.GRCm38_84.transcripts.filtered.tsv.gz"
ptrTranscripts="${root}/publicResources/genome_resources/ptr.CHIMP2.1.4_84/ptr.CHIMP2.1.4_84.transcripts.filtered.tsv.gz"


########################
###  PRE-REQUISITES  ###
########################

# Shell options
set -e
set -u
set -o pipefail

# Create directories
mkdir -p "$outDir"
mkdir -p "$tmpDir"
mkdir -p "$logDir"

# Create log file
logFile="${logDir}/$(basename $0 ".sh").log"
rm -f "$logFile; "touch "$logFile"
>&2 echo "Log written to '$logFile'..."


##############
###  MAIN  ###
##############

# Summarize poly(A) tail removal statistics
in_dir="${dataDir}/processing/polyA_removal/stats"
in_prefix=""
in_suffix=".processing.polyA_removal.stats"
out_dir="${outDir}/processing/polyA_removal/stats"; mkdir -p "$out_dir"
out_file="${out_dir}/processing.polyA_removal.stats"
"${scriptDir}/align_and_quantify/parse_cutadapt_logs.py" "$in_dir" "$in_prefix" "$in_suffix" > "$out_file" 2>> "$logFile"
# TODO: improve 'parse_cutadapt_logs.py' script

# Summarize alignment statistics
in_dir="${dataDir}/alignments/stats"
in_prefix=""
in_suffix=".alignments.stats"
out_dir="${outDir}/alignments/stats"; mkdir -p "$out_dir"
out_file="${out_dir}/alignments.stats"
"${scriptDir}/align_and_quantify/parse_STAR_logs.py" "$in_dir" "$in_prefix" "$in_suffix" > "$out_file" 2>> "$logFile"

# Summarize abundances (TPM)
in_dir="${dataDir}/abundances/tpm"
out_dir="${outDir}/abundances/tpm"; mkdir -p "$out_dir"
out_suffix=".transcripts.tpm"
glob="*.abundances.tpm"
id_suffix=".abundances.tpm"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Inflate transcript tables
hsa_trx="${tmpDir}/$(basename $hsaTranscripts .gz)"
mmu_trx="${tmpDir}/$(basename $mmuTranscripts .gz)"
ptr_trx="${tmpDir}/$(basename $ptrTranscripts .gz)"
gunzip --stdout "$hsaTranscripts" > "$hsa_trx"
gunzip --stdout "$mmuTranscripts" > "$mmu_trx"
gunzip --stdout "$ptrTranscripts" > "$ptr_trx"

# Aggregate transcript abundances per gene (human)
in_file="${outDir}/abundances/tpm/Homo_sapiens.transcripts.tpm"
out_file="${outDir}/abundances/tpm/Homo_sapiens.genes.tpm"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$hsa_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Aggregate transcript abundances per gene (mouse)
in_file="${outDir}/abundances/tpm/Mus_musculus.transcripts.tpm"
out_file="${outDir}/abundances/tpm/Mus_musculus.genes.tpm"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$mmu_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Aggregate transcript abundances per gene (chimp)
in_file="${outDir}/abundances/tpm/Pan_troglodytes.transcripts.tpm"
out_file="${outDir}/abundances/tpm/Pan_troglodytes.genes.tpm"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$ptr_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Summarize abundances (counts)
in_dir="${dataDir}/abundances/counts"
out_dir="${outDir}/abundances/counts"; mkdir -p "$out_dir"
out_suffix=".transcripts.counts"
glob="*.abundances.counts"
id_suffix=".abundances.counts"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Aggregate transcript counts per gene (human)
in_file="${outDir}/abundances/counts/Homo_sapiens.transcripts.counts"
out_file="${outDir}/abundances/counts/Homo_sapiens.genes.counts"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$hsa_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Aggregate transcript counts per gene (mouse)
in_file="${outDir}/abundances/counts/Mus_musculus.transcripts.counts"
out_file="${outDir}/abundances/counts/Mus_musculus.genes.counts"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$mmu_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Aggregate transcript counts per gene (chimp)
in_file="${outDir}/abundances/counts/Pan_troglodytes.transcripts.counts"
out_file="${outDir}/abundances/counts/Pan_troglodytes.genes.counts"
"${scriptDir}/generic/aggregate_data_matrix_by_grouping_table.R" --input-table "$in_file" --output-table "$out_file" --grouping-table "$ptr_trx" --group-id-column 6 --has-header-input-table --verbose &>> "$logFile"

# Summarize isoform usages
in_dir="${dataDir}/alternative_splicing/isoforms/psi"
out_dir="${outDir}/alternative_splicing/isoforms/psi"; mkdir -p "$out_dir"
out_suffix=".transcripts.psi"
glob="*.alternative_splicing.isoforms.psi"
id_suffix=".alternative_splicing.isoforms.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (A3)
in_dir="${dataDir}/alternative_splicing/events/A3/psi"
out_dir="${outDir}/alternative_splicing/events/A3/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.A3.psi"
glob="*.alternative_splicing.events.A3.psi"
id_suffix=".alternative_splicing.events.A3.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (A5)
in_dir="${dataDir}/alternative_splicing/events/A5/psi"
out_dir="${outDir}/alternative_splicing/events/A5/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.A5.psi"
glob="*.alternative_splicing.events.A5.psi"
id_suffix=".alternative_splicing.events.A5.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (AF)
in_dir="${dataDir}/alternative_splicing/events/AF/psi"
out_dir="${outDir}/alternative_splicing/events/AF/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.AF.psi"
glob="*.alternative_splicing.events.AF.psi"
id_suffix=".alternative_splicing.events.AF.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (AL)
in_dir="${dataDir}/alternative_splicing/events/AL/psi"
out_dir="${outDir}/alternative_splicing/events/AL/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.AL.psi"
glob="*.alternative_splicing.events.AL.psi"
id_suffix=".alternative_splicing.events.AL.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (MX)
in_dir="${dataDir}/alternative_splicing/events/MX/psi"
out_dir="${outDir}/alternative_splicing/events/MX/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.MX.psi"
glob="*.alternative_splicing.events.MX.psi"
id_suffix=".alternative_splicing.events.MX.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (RI)
in_dir="${dataDir}/alternative_splicing/events/RI/psi"
out_dir="${outDir}/alternative_splicing/events/RI/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.RI.psi"
glob="*.alternative_splicing.events.RI.psi"
id_suffix=".alternative_splicing.events.RI.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# Summarize alternative splicing events (SE)
in_dir="${dataDir}/alternative_splicing/events/SE/psi"
out_dir="${outDir}/alternative_splicing/events/SE/psi"; mkdir -p "$out_dir"
out_suffix=".alternative_splicing_events.SE.psi"
glob="*.alternative_splicing.events.SE.psi"
id_suffix=".alternative_splicing.events.SE.psi"
"${scriptDir}/generic/merge_common_field_from_multiple_tables_by_id.R" --input-directory "$in_dir" --output-directory "$out_dir" --out-file-suffix "$out_suffix" --glob "$glob" --id-suffix "$id_suffix" --has-header --annotation-table "$sampleTable" --anno-id-columns "1,2" --category-columns "3" --anno-has-header --include-ungrouped --verbose &>> "$logFile"

# TODO: Write 'merge_STAR_splice_junctions.py' and run
# TODO: Write scripts for plotting stats & results...


#############
###  END  ###
#############

echo "Processed data directory: $dataDir" >> "$logFile"
echo "Poly(A) tail removal statistics written to: $polyA_removal_stats" >> "$logFile"
echo "Alignment statistics written to: $alignment_stats" >> "$logFile"
#TODO: Write list of output files
echo "Done. No errors." >> "$logFile"
>&2 echo "Done. No errors."
