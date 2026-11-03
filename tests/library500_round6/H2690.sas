/* H2690 findw_case_insensitive, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2690o; actual=11+findw('gene11 X','GENE11',' ','i'); run;

data _null_; if 0 then set h2690o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2690 rows=' rows;
else do; set h2690o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2690';
else put 'ERROR: ROUND6_FAIL=H2690 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2690:; quit;
