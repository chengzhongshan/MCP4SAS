/* B3153 means_top_two_idgroup, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3153a; do x=1 to 4; output; end; run;
proc means data=b3153a noprint; var x; output out=b3153b idgroup(max(x) out[2](x)=top); run;
data b3153o; set b3153b; actual=top_1+top_2; run;

data _null_; if 0 then set b3153o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3153 rows=' rows;
else do; set b3153o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3153';
else put 'ERROR: ROUND7_FAIL=B3153 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3153:; quit;
