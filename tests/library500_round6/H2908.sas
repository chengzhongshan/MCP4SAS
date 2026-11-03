/* H2908 call_execute_double_quoted_include, N=9; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2908a; value=9; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2908o; set h2908a; actual=value; run;

data _null_; if 0 then set h2908o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2908 rows=' rows;
else do; set h2908o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2908';
else put 'ERROR: ROUND6_FAIL=H2908 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2908:; quit;
