/* G2060 dataset_rewind_fetch, N=11; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2060a; do x=1 to 11; output; end; run;
data g2060o; ds=open('g2060a','i'); rc=fetchobs(ds,11); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2060o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2060 rows=' rows;
else do; set g2060o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2060';
else put 'ERROR: ROUND5_FAIL=G2060 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2060:; quit;
