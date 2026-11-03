/* B3484 failure_rank_character_variable, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3484a; length text $12; do j=1 to 5; text='5'; output; end; run;
proc rank data=b3484a out=b3484b; var text; ranks position; run;

proc datasets library=work nolist; delete b3484:; quit;
