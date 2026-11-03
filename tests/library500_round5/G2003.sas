/* G2003 fetchobs_getvarn, N=4; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2003a; do row=1 to 4; x=row*row; output; end; run;
data g2003o; ds=open('g2003a','i'); rc=fetchobs(ds,4); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2003o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2003 rows=' rows;
else do; set g2003o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND5_PASS=G2003';
else put 'ERROR: ROUND5_FAIL=G2003 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2003:; quit;
