/* G2052 dataset_rewind_fetch, N=3; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2052a; do x=1 to 3; output; end; run;
data g2052o; ds=open('g2052a','i'); rc=fetchobs(ds,3); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2052o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2052 rows=' rows;
else do; set g2052o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2052';
else put 'ERROR: ROUND5_FAIL=G2052 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2052:; quit;
