/* B3157 means_top_two_idgroup, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3157a; do x=1 to 8; output; end; run;
proc means data=b3157a noprint; var x; output out=b3157b idgroup(max(x) out[2](x)=top); run;
data b3157o; set b3157b; actual=top_1+top_2; run;

data _null_; if 0 then set b3157o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3157 rows=' rows;
else do; set b3157o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3157';
else put 'ERROR: ROUND7_FAIL=B3157 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3157:; quit;
