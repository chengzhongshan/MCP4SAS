/* G2054 dataset_rewind_fetch, N=5; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2054a; do x=1 to 5; output; end; run;
data g2054o; ds=open('g2054a','i'); rc=fetchobs(ds,5); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;

data _null_; if 0 then set g2054o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2054 rows=' rows;
else do; set g2054o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2054';
else put 'ERROR: ROUND5_FAIL=G2054 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2054:; quit;
