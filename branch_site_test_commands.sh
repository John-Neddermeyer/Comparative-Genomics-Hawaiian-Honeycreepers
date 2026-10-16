TEST_TRE=all_branch_honeycreeper.tre

hyphy absrel --srv Yes --alignment ${line_N}_NT_alignment_cleaned.fasta \
--tree $TEST_TRE --branches Foreground --output absrel_${field_1}_all_branch.jason CPU=16
hyphy relax --srv Yes --alignment ${line_N}_NT_alignment_cleaned.fasta \
--tree $TEST_TRE --reference Background --test Foreground --reference-group Background \
--output relax_${field_1}_all_branch.jason CPU=12
hyphy contrast-FEL --srv Yes --alignment ${line_N}_NT_alignment_cleaned.fasta \
--tree $TEST_TRE --branch-set Foreground --output contrast_fel_${line_N}_all_branches.jason CPU=16
