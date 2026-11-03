/* B3483 failure_rank_character_variable, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3483a; length text $12; do j=1 to 4; text='4'; output; end; run;
proc rank data=b3483a out=b3483b; var text; ranks position; run;

proc datasets library=work nolist; delete b3483:; quit;
