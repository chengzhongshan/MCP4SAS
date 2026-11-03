/* G2004 fetchobs_getvarn, N=5; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2004a; do row=1 to 5; x=row*row; output; end; run;
data g2004o; ds=open('g2004a','i'); rc=fetchobs(ds,5); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2004o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2004 rows=' rows;
else do; set g2004o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND5_PASS=G2004';
else put 'ERROR: ROUND5_FAIL=G2004 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2004:; quit;
