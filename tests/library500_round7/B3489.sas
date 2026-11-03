/* B3489 failure_rank_character_variable, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3489a; length text $12; do j=1 to 10; text='10'; output; end; run;
proc rank data=b3489a out=b3489b; var text; ranks position; run;

proc datasets library=work nolist; delete b3489:; quit;
