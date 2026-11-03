/* B3487 failure_rank_character_variable, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3487a; length text $12; do j=1 to 8; text='8'; output; end; run;
proc rank data=b3487a out=b3487b; var text; ranks position; run;

proc datasets library=work nolist; delete b3487:; quit;
