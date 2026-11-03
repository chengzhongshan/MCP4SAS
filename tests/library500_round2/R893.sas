/* R893 scanover_anchor, N=4; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=4'; run;
data r893o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r893o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R893 rows=' rows;
else do; set r893o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R893';
else put 'ERROR: ROUND2_FAIL=R893 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r893:; quit;
