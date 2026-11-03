/* G2059 dataset_rewind_fetch, N=10; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2059a; do x=1 to 10; output; end; run;
data g2059o; ds=open('g2059a','i'); rc=fetchobs(ds,10); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2059o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2059 rows=' rows;
else do; set g2059o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2059';
else put 'ERROR: ROUND5_FAIL=G2059 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2059:; quit;
