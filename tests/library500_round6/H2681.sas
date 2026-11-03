/* H2681 findw_case_insensitive, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2681o; actual=2+findw('gene2 X','GENE2',' ','i'); run;

data _null_; if 0 then set h2681o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2681 rows=' rows;
else do; set h2681o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2681';
else put 'ERROR: ROUND6_FAIL=H2681 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2681:; quit;
