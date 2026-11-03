/* B3488 failure_rank_character_variable, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3488a; length text $12; do j=1 to 9; text='9'; output; end; run;
proc rank data=b3488a out=b3488b; var text; ranks position; run;

proc datasets library=work nolist; delete b3488:; quit;
