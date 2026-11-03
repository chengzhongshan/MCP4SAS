/* G2018 fetch_sequential, N=9; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2018a; do x=1 to 9; output; end; run;
data g2018o; ds=open('g2018a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2018o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2018 rows=' rows;
else do; set g2018o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND5_PASS=G2018';
else put 'ERROR: ROUND5_FAIL=G2018 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2018:; quit;
