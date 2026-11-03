/* G2056 dataset_rewind_fetch, N=7; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2056a; do x=1 to 7; output; end; run;
data g2056o; ds=open('g2056a','i'); rc=fetchobs(ds,7); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2056o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2056 rows=' rows;
else do; set g2056o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2056';
else put 'ERROR: ROUND5_FAIL=G2056 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2056:; quit;
