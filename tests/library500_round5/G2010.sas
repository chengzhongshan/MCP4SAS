/* G2010 fetchobs_getvarn, N=11; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2010a; do row=1 to 11; x=row*row; output; end; run;
data g2010o; ds=open('g2010a','i'); rc=fetchobs(ds,11); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2010o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2010 rows=' rows;
else do; set g2010o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND5_PASS=G2010';
else put 'ERROR: ROUND5_FAIL=G2010 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2010:; quit;
