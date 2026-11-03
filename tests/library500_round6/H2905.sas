/* H2905 call_execute_double_quoted_include, N=6; source: SAS-Useful-Codes/Macros/InstallGitHubZipPackage.sas:291 */

filename rtemp temp;
data _null_; file rtemp; put 'data h2905a; value=6; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data h2905o; set h2905a; actual=value; run;

data _null_; if 0 then set h2905o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2905 rows=' rows;
else do; set h2905o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2905';
else put 'ERROR: ROUND6_FAIL=H2905 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2905:; quit;
