/* G2001 fetchobs_getvarn, N=2; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2001a; do row=1 to 2; x=row*row; output; end; run;
data g2001o; ds=open('g2001a','i'); rc=fetchobs(ds,2); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2001o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2001 rows=' rows;
else do; set g2001o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2001';
else put 'ERROR: ROUND5_FAIL=G2001 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2001:; quit;
