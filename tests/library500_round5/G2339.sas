/* G2339 datalines4_apostrophe, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data g2339o; infile datalines4 truncover; input text $char80.; actual=lengthn(text); datalines4;
O'Brien;10
;;;;
run;

data _null_; if 0 then set g2339o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2339 rows=' rows;
else do; set g2339o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2339';
else put 'ERROR: ROUND5_FAIL=G2339 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2339:; quit;
