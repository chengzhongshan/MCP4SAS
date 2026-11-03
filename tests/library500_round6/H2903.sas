/* H2903 call_execute_double_quoted_include, N=4; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2903a; value=4; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2903o; set h2903a; actual=value; run;

data _null_; if 0 then set h2903o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2903 rows=' rows;
else do; set h2903o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2903';
else put 'ERROR: ROUND6_FAIL=H2903 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2903:; quit;
