/* G2015 fetch_sequential, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2015a; do x=1 to 6; output; end; run;
data g2015o; ds=open('g2015a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2015o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2015 rows=' rows;
else do; set g2015o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND5_PASS=G2015';
else put 'ERROR: ROUND5_FAIL=G2015 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2015:; quit;
