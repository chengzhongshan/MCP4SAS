/* G2007 fetchobs_getvarn, N=8; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2007a; do row=1 to 8; x=row*row; output; end; run;
data g2007o; ds=open('g2007a','i'); rc=fetchobs(ds,8); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2007o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2007 rows=' rows;
else do; set g2007o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND5_PASS=G2007';
else put 'ERROR: ROUND5_FAIL=G2007 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2007:; quit;
