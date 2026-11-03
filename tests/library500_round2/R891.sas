/* R891 scanover_anchor, N=2; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=2'; run;
data r891o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r891o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R891 rows=' rows;
else do; set r891o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R891';
else put 'ERROR: ROUND2_FAIL=R891 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r891:; quit;
