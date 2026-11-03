/* R809 freq_counts, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r809a; do k=1 to 10; do j=1 to k; output; end; end; run;
proc freq data=r809a noprint; tables k / out=r809b; run;
proc sql; create table r809o as select sum(count) as actual from r809b; quit;

data _null_; if 0 then set r809o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R809 rows=' rows;
else do; set r809o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R809';
else put 'ERROR: ROUND2_FAIL=R809 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r809:; quit;
