#!/bin/bash

#GDC Breast Cancer RNAseq GEM
#IMPORTANT: Launch script in same directory as manifest file was downloaded

#Matt Harrington, Clemson University
#2025-03-09

#Install GDC client into bin and put in PATH

#Download data from GDC manifest for a given RNAseq set

OUTPUT_DIR="./GEM_output"
GEM_OUTPUT="GDC_RNAseq_GEM.tsv"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Find all TSV files in subdirectories (one level down)
FILES=$(find . -maxdepth 2 -name "*.tsv")

# Create a temporary file with sample IDs and file paths
# Format: sample_id:file_path
for file in $FILES; do
# Extract the directory name as the sample ID
    SAMPLE_ID=$(dirname $file | sed 's|^\./||')
    echo "$SAMPLE_ID:$file"
done > $OUTPUT_DIR/sample_list.txt

# Use AWK to process all files and create the gene expression matrix in one pass
awk -v output_file="$OUTPUT_DIR/$GEM_OUTPUT" '
BEGIN {
# Set field separator for input and output
    FS = "\t"
    OFS = "\t"
    
# Read sample list into arrays
    while ((getline < "'$OUTPUT_DIR'/sample_list.txt") > 0) {
        # Split each line by colon to get sample ID and file path
        split($0, parts, ":")
        sample_id = parts[1]
        file_path = parts[2]

# Store sample IDs in order
        samples[++num_samples] = sample_id
# Map file paths to sample indices for quick lookup
        sample_files[sample_id] = file_path
    }
    close("'$OUTPUT_DIR'/sample_list.txt")
    
# Create header row with gene_name and all sample IDs
    printf "gene_name" > output_file
    for (i = 1; i <= num_samples; i++) {
        printf "%s%s", OFS, samples[i] >> output_file
    }
    printf "\n" >> output_file
    
# Process each sample file to collect gene expression data
    for (s = 1; s <= num_samples; s++) {
        sample = samples[s]
        file = sample_files[sample]

# Process each file, skipping first 6 lines (headers)
        cmd = "tail -n +7 \"" file "\""
        while ((cmd | getline) > 0) {
# Store gene name (column 2) and expression value (column 6)
            gene = $2
            expr = $6

# Store expression value for this gene and sample
# If multiple entries for same gene, use the last one
            gene_expr[gene, sample] = expr

# Keep track of all unique genes
            if (!(gene in all_genes)) {
                all_genes[gene] = 1
                gene_list[++num_genes] = gene
            }
        }
        close(cmd)
    }

# Sort gene list alphabetically for consistent output
    asort(gene_list)
    
# Output the expression matrix
    for (g = 1; g <= num_genes; g++) {
        gene = gene_list[g]
        printf "%s", gene >> output_file

        for (s = 1; s <= num_samples; s++) {
            sample = samples[s]
# Use expression value if available, otherwise use NaN
            value = (gene, sample) in gene_expr ? gene_expr[gene, sample] : "NaN"
            printf "%s%s", OFS, value >> output_file
        }
        printf "\n" >> output_file
    }
}' < /dev/null

echo "Process complete."
