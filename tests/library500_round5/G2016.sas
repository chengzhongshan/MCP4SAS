/* G2016 fetch_sequential, N=7; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2016a; do x=1 to 7; output; end; run;
data g2016o; ds=open('g2016a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2016o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2016 rows=' rows;
else do; set g2016o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND5_PASS=G2016';
else put 'ERROR: ROUND5_FAIL=G2016 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2016:; quit;
