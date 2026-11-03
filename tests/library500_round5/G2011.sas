/* G2011 fetch_sequential, N=2; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2011a; do x=1 to 2; output; end; run;
data g2011o; ds=open('g2011a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2011o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2011 rows=' rows;
else do; set g2011o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2011';
else put 'ERROR: ROUND5_FAIL=G2011 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2011:; quit;
