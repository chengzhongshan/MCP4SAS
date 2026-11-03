/* H2689 findw_case_insensitive, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2689o; actual=10+findw('gene10 X','GENE10',' ','i'); run;

data _null_; if 0 then set h2689o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2689 rows=' rows;
else do; set h2689o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2689';
else put 'ERROR: ROUND6_FAIL=H2689 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2689:; quit;
