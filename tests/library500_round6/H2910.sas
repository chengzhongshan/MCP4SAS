/* H2910 call_execute_double_quoted_include, N=11; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2910a; value=11; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2910o; set h2910a; actual=value; run;

data _null_; if 0 then set h2910o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2910 rows=' rows;
else do; set h2910o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2910';
else put 'ERROR: ROUND6_FAIL=H2910 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2910:; quit;
