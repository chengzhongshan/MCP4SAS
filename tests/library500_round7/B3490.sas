/* B3490 failure_rank_character_variable, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3490a; length text $12; do j=1 to 11; text='11'; output; end; run;
proc rank data=b3490a out=b3490b; var text; ranks position; run;

proc datasets library=work nolist; delete b3490:; quit;
