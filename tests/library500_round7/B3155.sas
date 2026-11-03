/* B3155 means_top_two_idgroup, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3155a; do x=1 to 6; output; end; run;
proc means data=b3155a noprint; var x; output out=b3155b idgroup(max(x) out[2](x)=top); run;
data b3155o; set b3155b; actual=top_1+top_2; run;

data _null_; if 0 then set b3155o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3155 rows=' rows;
else do; set b3155o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3155';
else put 'ERROR: ROUND7_FAIL=B3155 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3155:; quit;
