/* R806 freq_counts, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r806a; do k=1 to 7; do j=1 to k; output; end; end; run;
proc freq data=r806a noprint; tables k / out=r806b; run;
proc sql; create table r806o as select sum(count) as actual from r806b; quit;

data _null_; if 0 then set r806o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R806 rows=' rows;
else do; set r806o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R806';
else put 'ERROR: ROUND2_FAIL=R806 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r806:; quit;
