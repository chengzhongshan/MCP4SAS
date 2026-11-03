/* R896 scanover_anchor, N=7; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=7'; run;
data r896o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r896o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R896 rows=' rows;
else do; set r896o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R896';
else put 'ERROR: ROUND2_FAIL=R896 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r896:; quit;
