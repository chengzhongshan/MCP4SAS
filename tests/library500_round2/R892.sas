/* R892 scanover_anchor, N=3; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=3'; run;
data r892o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r892o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R892 rows=' rows;
else do; set r892o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R892';
else put 'ERROR: ROUND2_FAIL=R892 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r892:; quit;
