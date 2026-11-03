/* B3160 means_top_two_idgroup, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3160a; do x=1 to 11; output; end; run;
proc means data=b3160a noprint; var x; output out=b3160b idgroup(max(x) out[2](x)=top); run;
data b3160o; set b3160b; actual=top_1+top_2; run;

data _null_; if 0 then set b3160o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3160 rows=' rows;
else do; set b3160o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3160';
else put 'ERROR: ROUND7_FAIL=B3160 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3160:; quit;
