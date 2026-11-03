/* B3156 means_top_two_idgroup, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3156a; do x=1 to 7; output; end; run;
proc means data=b3156a noprint; var x; output out=b3156b idgroup(max(x) out[2](x)=top); run;
data b3156o; set b3156b; actual=top_1+top_2; run;

data _null_; if 0 then set b3156o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3156 rows=' rows;
else do; set b3156o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND7_PASS=B3156';
else put 'ERROR: ROUND7_FAIL=B3156 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3156:; quit;
