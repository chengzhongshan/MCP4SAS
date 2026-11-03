/* G2008 fetchobs_getvarn, N=9; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/Compile/Exist.sas:26 */

data g2008a; do row=1 to 9; x=row*row; output; end; run;
data g2008o; ds=open('g2008a','i'); rc=fetchobs(ds,9); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2008o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2008 rows=' rows;
else do; set g2008o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND5_PASS=G2008';
else put 'ERROR: ROUND5_FAIL=G2008 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2008:; quit;
