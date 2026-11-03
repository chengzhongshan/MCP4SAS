/* G2006 fetchobs_getvarn, N=7; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2006a; do row=1 to 7; x=row*row; output; end; run;
data g2006o; ds=open('g2006a','i'); rc=fetchobs(ds,7); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2006o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2006 rows=' rows;
else do; set g2006o; if not missing(actual) and abs(actual-(49))<=1e-9*max(1,abs(49)) then put 'ROUND5_PASS=G2006';
else put 'ERROR: ROUND5_FAIL=G2006 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2006:; quit;
