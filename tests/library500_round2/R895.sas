/* R895 scanover_anchor, N=6; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=6'; run;
data r895o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r895o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R895 rows=' rows;
else do; set r895o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R895';
else put 'ERROR: ROUND2_FAIL=R895 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r895:; quit;
