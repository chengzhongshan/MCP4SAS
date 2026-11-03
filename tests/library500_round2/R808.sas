/* R808 freq_counts, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r808a; do k=1 to 9; do j=1 to k; output; end; end; run;
proc freq data=r808a noprint; tables k / out=r808b; run;
proc sql; create table r808o as select sum(count) as actual from r808b; quit;

data _null_; if 0 then set r808o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R808 rows=' rows;
else do; set r808o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R808';
else put 'ERROR: ROUND2_FAIL=R808 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r808:; quit;
