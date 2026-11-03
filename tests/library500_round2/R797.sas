/* R797 rank_ties, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r797a; do x=1 to 8; output; output; end; run;
proc rank data=r797a out=r797b ties=mean; var x; ranks position; run;
proc sql; create table r797o as select sum(position) as actual from r797b; quit;

data _null_; if 0 then set r797o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R797 rows=' rows;
else do; set r797o; if not missing(actual) and abs(actual-(136))<=1e-10*max(1,abs(136)) then put 'ROUND2_PASS=R797';
else put 'ERROR: ROUND2_FAIL=R797 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r797:; quit;
