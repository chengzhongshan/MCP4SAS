/* G2053 dataset_rewind_fetch, N=4; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2053a; do x=1 to 4; output; end; run;
data g2053o; ds=open('g2053a','i'); rc=fetchobs(ds,4); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2053o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2053 rows=' rows;
else do; set g2053o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2053';
else put 'ERROR: ROUND5_FAIL=G2053 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2053:; quit;
