/* G2051 dataset_rewind_fetch, N=2; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2051a; do x=1 to 2; output; end; run;
data g2051o; ds=open('g2051a','i'); rc=fetchobs(ds,2); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2051o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2051 rows=' rows;
else do; set g2051o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2051';
else put 'ERROR: ROUND5_FAIL=G2051 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2051:; quit;
