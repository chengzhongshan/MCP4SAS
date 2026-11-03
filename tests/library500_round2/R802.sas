/* R802 freq_counts, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r802a; do k=1 to 3; do j=1 to k; output; end; end; run;
proc freq data=r802a noprint; tables k / out=r802b; run;
proc sql; create table r802o as select sum(count) as actual from r802b; quit;

data _null_; if 0 then set r802o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R802 rows=' rows;
else do; set r802o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R802';
else put 'ERROR: ROUND2_FAIL=R802 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r802:; quit;
