/* G2013 fetch_sequential, N=4; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2013a; do x=1 to 4; output; end; run;
data g2013o; ds=open('g2013a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2013o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2013 rows=' rows;
else do; set g2013o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2013';
else put 'ERROR: ROUND5_FAIL=G2013 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2013:; quit;
