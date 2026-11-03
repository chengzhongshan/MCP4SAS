/* B3087 delete_and_explicit_outputs, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3087a; do x=1 to 2*8; output; end; run;
data b3087b; set b3087a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3087o as select sum(x) as actual from b3087b; quit;

data _null_; if 0 then set b3087o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3087 rows=' rows;
else do; set b3087o; if not missing(actual) and abs(actual-(144))<=1e-9*max(1,abs(144)) then put 'ROUND7_PASS=B3087';
else put 'ERROR: ROUND7_FAIL=B3087 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3087:; quit;
