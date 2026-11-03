/* H2907 call_execute_double_quoted_include, N=8; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2907a; value=8; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2907o; set h2907a; actual=value; run;

data _null_; if 0 then set h2907o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2907 rows=' rows;
else do; set h2907o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2907';
else put 'ERROR: ROUND6_FAIL=H2907 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2907:; quit;
