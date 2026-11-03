/* G2078 open_where_fetch, N=9; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2078a; do x=1 to 2*9; output; end; run;
data g2078o; ds=open('g2078a(where=(x>9))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2078o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2078 rows=' rows;
else do; set g2078o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2078';
else put 'ERROR: ROUND5_FAIL=G2078 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2078:; quit;
