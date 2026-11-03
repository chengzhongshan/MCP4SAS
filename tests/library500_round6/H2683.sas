/* H2683 findw_case_insensitive, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2683o; actual=4+findw('gene4 X','GENE4',' ','i'); run;

data _null_; if 0 then set h2683o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2683 rows=' rows;
else do; set h2683o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2683';
else put 'ERROR: ROUND6_FAIL=H2683 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2683:; quit;
