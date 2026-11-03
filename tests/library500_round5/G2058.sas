/* G2058 dataset_rewind_fetch, N=9; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2058a; do x=1 to 9; output; end; run;
data g2058o; ds=open('g2058a','i'); rc=fetchobs(ds,9); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2058o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2058 rows=' rows;
else do; set g2058o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2058';
else put 'ERROR: ROUND5_FAIL=G2058 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2058:; quit;
