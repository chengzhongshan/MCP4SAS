/* R899 scanover_anchor, N=10; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=10'; run;
data r899o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r899o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R899 rows=' rows;
else do; set r899o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R899';
else put 'ERROR: ROUND2_FAIL=R899 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r899:; quit;
