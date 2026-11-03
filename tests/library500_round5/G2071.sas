/* G2071 open_where_fetch, N=2; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2071a; do x=1 to 2*2; output; end; run;
data g2071o; ds=open('g2071a(where=(x>2))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2071o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2071 rows=' rows;
else do; set g2071o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2071';
else put 'ERROR: ROUND5_FAIL=G2071 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2071:; quit;
