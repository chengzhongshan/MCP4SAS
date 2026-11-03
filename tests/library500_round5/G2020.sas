/* G2020 fetch_sequential, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2020a; do x=1 to 11; output; end; run;
data g2020o; ds=open('g2020a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2020o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2020 rows=' rows;
else do; set g2020o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND5_PASS=G2020';
else put 'ERROR: ROUND5_FAIL=G2020 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2020:; quit;
