/* G2336 datalines4_apostrophe, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data g2336o; infile datalines4 truncover; input text $char80.; actual=lengthn(text); datalines4;
O'Brien;7
;;;;
run;

data _null_; if 0 then set g2336o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2336 rows=' rows;
else do; set g2336o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2336';
else put 'ERROR: ROUND5_FAIL=G2336 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2336:; quit;
