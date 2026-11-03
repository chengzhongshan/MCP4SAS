/* B3482 failure_rank_character_variable, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3482a; length text $12; do j=1 to 3; text='3'; output; end; run;
proc rank data=b3482a out=b3482b; var text; ranks position; run;

proc datasets library=work nolist; delete b3482:; quit;
