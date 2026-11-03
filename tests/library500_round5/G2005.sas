/* G2005 fetchobs_getvarn, N=6; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2005a; do row=1 to 6; x=row*row; output; end; run;
data g2005o; ds=open('g2005a','i'); rc=fetchobs(ds,6); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2005o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2005 rows=' rows;
else do; set g2005o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND5_PASS=G2005';
else put 'ERROR: ROUND5_FAIL=G2005 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2005:; quit;
