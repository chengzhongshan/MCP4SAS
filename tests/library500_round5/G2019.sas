/* G2019 fetch_sequential, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/defined.sas:53 */

data g2019a; do x=1 to 10; output; end; run;
data g2019o; ds=open('g2019a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2019o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2019 rows=' rows;
else do; set g2019o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND5_PASS=G2019';
else put 'ERROR: ROUND5_FAIL=G2019 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2019:; quit;
