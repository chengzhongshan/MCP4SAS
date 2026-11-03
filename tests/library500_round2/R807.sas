/* R807 freq_counts, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r807a; do k=1 to 8; do j=1 to k; output; end; end; run;
proc freq data=r807a noprint; tables k / out=r807b; run;
proc sql; create table r807o as select sum(count) as actual from r807b; quit;

data _null_; if 0 then set r807o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R807 rows=' rows;
else do; set r807o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R807';
else put 'ERROR: ROUND2_FAIL=R807 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r807:; quit;
