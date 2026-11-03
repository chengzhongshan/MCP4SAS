/* B3481 failure_rank_character_variable, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3481a; length text $12; do j=1 to 2; text='2'; output; end; run;
proc rank data=b3481a out=b3481b; var text; ranks position; run;

proc datasets library=work nolist; delete b3481:; quit;
