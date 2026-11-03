/* R810 freq_counts, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r810a; do k=1 to 11; do j=1 to k; output; end; end; run;
proc freq data=r810a noprint; tables k / out=r810b; run;
proc sql; create table r810o as select sum(count) as actual from r810b; quit;

data _null_; if 0 then set r810o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R810 rows=' rows;
else do; set r810o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R810';
else put 'ERROR: ROUND2_FAIL=R810 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r810:; quit;
