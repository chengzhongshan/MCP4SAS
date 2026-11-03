/* G2012 fetch_sequential, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2012a; do x=1 to 3; output; end; run;
data g2012o; ds=open('g2012a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2012o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2012 rows=' rows;
else do; set g2012o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2012';
else put 'ERROR: ROUND5_FAIL=G2012 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2012:; quit;
