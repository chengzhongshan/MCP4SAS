/* B3486 failure_rank_character_variable, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3486a; length text $12; do j=1 to 7; text='7'; output; end; run;
proc rank data=b3486a out=b3486b; var text; ranks position; run;

proc datasets library=work nolist; delete b3486:; quit;
