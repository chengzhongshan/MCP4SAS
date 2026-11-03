/* B3154 means_top_two_idgroup, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3154a; do x=1 to 5; output; end; run;
proc means data=b3154a noprint; var x; output out=b3154b idgroup(max(x) out[2](x)=top); run;
data b3154o; set b3154b; actual=top_1+top_2; run;

data _null_; if 0 then set b3154o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3154 rows=' rows;
else do; set b3154o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3154';
else put 'ERROR: ROUND7_FAIL=B3154 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3154:; quit;
