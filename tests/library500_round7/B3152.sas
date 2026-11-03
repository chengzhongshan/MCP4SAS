/* B3152 means_top_two_idgroup, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3152a; do x=1 to 3; output; end; run;
proc means data=b3152a noprint; var x; output out=b3152b idgroup(max(x) out[2](x)=top); run;
data b3152o; set b3152b; actual=top_1+top_2; run;

data _null_; if 0 then set b3152o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3152 rows=' rows;
else do; set b3152o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3152';
else put 'ERROR: ROUND7_FAIL=B3152 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3152:; quit;
