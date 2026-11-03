/* H2904 call_execute_double_quoted_include, N=5; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2904a; value=5; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2904o; set h2904a; actual=value; run;

data _null_; if 0 then set h2904o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2904 rows=' rows;
else do; set h2904o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2904';
else put 'ERROR: ROUND6_FAIL=H2904 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2904:; quit;
