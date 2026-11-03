/* H2686 findw_case_insensitive, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2686o; actual=7+findw('gene7 X','GENE7',' ','i'); run;

data _null_; if 0 then set h2686o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2686 rows=' rows;
else do; set h2686o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2686';
else put 'ERROR: ROUND6_FAIL=H2686 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2686:; quit;
