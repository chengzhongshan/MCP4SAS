/* R894 scanover_anchor, N=5; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=5'; run;
data r894o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r894o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R894 rows=' rows;
else do; set r894o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R894';
else put 'ERROR: ROUND2_FAIL=R894 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r894:; quit;
