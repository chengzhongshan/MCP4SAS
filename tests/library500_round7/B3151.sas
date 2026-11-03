/* B3151 means_top_two_idgroup, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3151a; do x=1 to 2; output; end; run;
proc means data=b3151a noprint; var x; output out=b3151b idgroup(max(x) out[2](x)=top); run;
data b3151o; set b3151b; actual=top_1+top_2; run;

data _null_; if 0 then set b3151o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3151 rows=' rows;
else do; set b3151o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3151';
else put 'ERROR: ROUND7_FAIL=B3151 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3151:; quit;
