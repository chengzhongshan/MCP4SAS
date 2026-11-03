/* B3158 means_top_two_idgroup, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3158a; do x=1 to 9; output; end; run;
proc means data=b3158a noprint; var x; output out=b3158b idgroup(max(x) out[2](x)=top); run;
data b3158o; set b3158b; actual=top_1+top_2; run;

data _null_; if 0 then set b3158o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3158 rows=' rows;
else do; set b3158o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND7_PASS=B3158';
else put 'ERROR: ROUND7_FAIL=B3158 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3158:; quit;
