/* R801 freq_counts, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r801a; do k=1 to 2; do j=1 to k; output; end; end; run;
proc freq data=r801a noprint; tables k / out=r801b; run;
proc sql; create table r801o as select sum(count) as actual from r801b; quit;

data _null_; if 0 then set r801o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R801 rows=' rows;
else do; set r801o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R801';
else put 'ERROR: ROUND2_FAIL=R801 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r801:; quit;
