.PHONY: all clean

all: paper/paper.pdf

# -----------------------------------------------------------------------------
# Step 1: Preprocessing
# Reads from hdm package (no input/ files needed)
# Writes: temp/eminent_domain.rds
# -----------------------------------------------------------------------------
temp/eminent_domain.rds: code/preprocess.R
	Rscript code/preprocess.R

# -----------------------------------------------------------------------------
# Step 2: Analysis
# Reads: temp/eminent_domain.rds, code/helper.R
# Writes: output/tables/table2.tex
# -----------------------------------------------------------------------------
output/tables/table2.tex: \
	temp/eminent_domain.rds \
	code/analysis.R \
	code/helper.R
	Rscript code/analysis.R

# -----------------------------------------------------------------------------
# Step 3: Paper compilation
# Reads: paper/paper.tex, paper/references.bib, output/tables/table2.tex
# Writes: paper/paper.pdf
# -----------------------------------------------------------------------------
paper/paper.pdf: \
	paper/paper.tex \
	paper/references.bib \
	output/tables/table2.tex
	cd paper && pdflatex paper.tex && bibtex paper && pdflatex paper.tex && pdflatex paper.tex

# -----------------------------------------------------------------------------
# Clean: remove all regenerable outputs
# -----------------------------------------------------------------------------
clean:
	rm -f temp/eminent_domain.rds
	rm -f output/tables/table2.tex
	rm -f paper/paper.pdf paper/paper.aux paper/paper.log \
	      paper/paper.bbl paper/paper.blg paper/paper.out \
	      paper/paper.toc
