/* H2687 findw_case_insensitive, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2687o; actual=8+findw('gene8 X','GENE8',' ','i'); run;

data _null_; if 0 then set h2687o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2687 rows=' rows;
else do; set h2687o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2687';
else put 'ERROR: ROUND6_FAIL=H2687 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2687:; quit;
