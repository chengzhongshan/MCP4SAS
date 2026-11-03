/* B3485 failure_rank_character_variable, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3485a; length text $12; do j=1 to 6; text='6'; output; end; run;
proc rank data=b3485a out=b3485b; var text; ranks position; run;

proc datasets library=work nolist; delete b3485:; quit;
