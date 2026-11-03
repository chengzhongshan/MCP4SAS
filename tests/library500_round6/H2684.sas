/* H2684 findw_case_insensitive, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2684o; actual=5+findw('gene5 X','GENE5',' ','i'); run;

data _null_; if 0 then set h2684o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2684 rows=' rows;
else do; set h2684o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2684';
else put 'ERROR: ROUND6_FAIL=H2684 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2684:; quit;
