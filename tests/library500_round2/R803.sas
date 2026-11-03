/* R803 freq_counts, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r803a; do k=1 to 4; do j=1 to k; output; end; end; run;
proc freq data=r803a noprint; tables k / out=r803b; run;
proc sql; create table r803o as select sum(count) as actual from r803b; quit;

data _null_; if 0 then set r803o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R803 rows=' rows;
else do; set r803o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R803';
else put 'ERROR: ROUND2_FAIL=R803 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r803:; quit;
