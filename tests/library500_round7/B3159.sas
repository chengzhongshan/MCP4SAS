/* B3159 means_top_two_idgroup, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3159a; do x=1 to 10; output; end; run;
proc means data=b3159a noprint; var x; output out=b3159b idgroup(max(x) out[2](x)=top); run;
data b3159o; set b3159b; actual=top_1+top_2; run;

data _null_; if 0 then set b3159o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3159 rows=' rows;
else do; set b3159o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND7_PASS=B3159';
else put 'ERROR: ROUND7_FAIL=B3159 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3159:; quit;
