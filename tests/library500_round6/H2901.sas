/* H2901 call_execute_double_quoted_include, N=2; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2901a; value=2; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2901o; set h2901a; actual=value; run;

data _null_; if 0 then set h2901o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2901 rows=' rows;
else do; set h2901o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2901';
else put 'ERROR: ROUND6_FAIL=H2901 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2901:; quit;
