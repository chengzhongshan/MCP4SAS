/* R900 scanover_anchor, N=11; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=11'; run;
data r900o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r900o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R900 rows=' rows;
else do; set r900o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R900';
else put 'ERROR: ROUND2_FAIL=R900 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r900:; quit;
