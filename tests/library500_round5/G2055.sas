/* G2055 dataset_rewind_fetch, N=6; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2055a; do x=1 to 6; output; end; run;
data g2055o; ds=open('g2055a','i'); rc=fetchobs(ds,6); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2055o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2055 rows=' rows;
else do; set g2055o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2055';
else put 'ERROR: ROUND5_FAIL=G2055 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2055:; quit;
