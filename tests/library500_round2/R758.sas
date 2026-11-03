/* R758 nobs_metadata, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:34 */

data r758a; do x=1 to 9; output; end; run;
data r758o; if 0 then set r758a nobs=number; actual=number; output; stop; run;

data _null_; if 0 then set r758o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R758 rows=' rows;
else do; set r758o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R758';
else put 'ERROR: ROUND2_FAIL=R758 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r758:; quit;
