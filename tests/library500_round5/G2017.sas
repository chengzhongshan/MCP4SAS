/* G2017 fetch_sequential, N=8; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2017a; do x=1 to 8; output; end; run;
data g2017o; ds=open('g2017a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2017o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2017 rows=' rows;
else do; set g2017o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND5_PASS=G2017';
else put 'ERROR: ROUND5_FAIL=G2017 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2017:; quit;
