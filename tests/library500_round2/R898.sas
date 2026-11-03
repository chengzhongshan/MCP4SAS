/* R898 scanover_anchor, N=9; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2375 */

filename rtemp temp;
data _null_; file rtemp; put 'junk'; put 'score=9'; run;
data r898o; infile rtemp scanover; input @'score=' n; actual=n; run;
filename rtemp clear;

data _null_; if 0 then set r898o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R898 rows=' rows;
else do; set r898o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R898';
else put 'ERROR: ROUND2_FAIL=R898 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r898:; quit;
