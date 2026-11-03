/* R897 scanover_anchor, N=8; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=8'; run;
data r897o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r897o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R897 rows=' rows;
else do; set r897o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R897';
else put 'ERROR: ROUND2_FAIL=R897 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r897:; quit;
