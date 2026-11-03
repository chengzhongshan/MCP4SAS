/* G2076 open_where_fetch, N=7; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2076a; do x=1 to 2*7; output; end; run;
data g2076o; ds=open('g2076a(where=(x>7))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2076o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2076 rows=' rows;
else do; set g2076o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2076';
else put 'ERROR: ROUND5_FAIL=G2076 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2076:; quit;
