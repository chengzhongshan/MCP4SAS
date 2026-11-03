/* G2340 datalines4_apostrophe, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data g2340o; infile datalines4 truncover; input text $char80.; actual=lengthn(text); datalines4;
O'Brien;11
;;;;
run;

data _null_; if 0 then set g2340o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2340 rows=' rows;
else do; set g2340o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2340';
else put 'ERROR: ROUND5_FAIL=G2340 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2340:; quit;
