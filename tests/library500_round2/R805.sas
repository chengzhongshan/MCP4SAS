/* R805 freq_counts, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r805a; do k=1 to 6; do j=1 to k; output; end; end; run;
proc freq data=r805a noprint; tables k / out=r805b; run;
proc sql; create table r805o as select sum(count) as actual from r805b; quit;

data _null_; if 0 then set r805o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R805 rows=' rows;
else do; set r805o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R805';
else put 'ERROR: ROUND2_FAIL=R805 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r805:; quit;
