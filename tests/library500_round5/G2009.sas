/* G2009 fetchobs_getvarn, N=10; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2009a; do row=1 to 10; x=row*row; output; end; run;
data g2009o; ds=open('g2009a','i'); rc=fetchobs(ds,10); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2009o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2009 rows=' rows;
else do; set g2009o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND5_PASS=G2009';
else put 'ERROR: ROUND5_FAIL=G2009 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2009:; quit;
