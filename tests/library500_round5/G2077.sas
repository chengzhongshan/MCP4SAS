/* G2077 open_where_fetch, N=8; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2077a; do x=1 to 2*8; output; end; run;
data g2077o; ds=open('g2077a(where=(x>8))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2077o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2077 rows=' rows;
else do; set g2077o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2077';
else put 'ERROR: ROUND5_FAIL=G2077 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2077:; quit;
