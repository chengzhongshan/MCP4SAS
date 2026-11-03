/* G2057 dataset_rewind_fetch, N=8; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2057a; do x=1 to 8; output; end; run;
data g2057o; ds=open('g2057a','i'); rc=fetchobs(ds,8); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2057o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2057 rows=' rows;
else do; set g2057o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2057';
else put 'ERROR: ROUND5_FAIL=G2057 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2057:; quit;
