/* G2079 open_where_fetch, N=10; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2079a; do x=1 to 2*10; output; end; run;
data g2079o; ds=open('g2079a(where=(x>10))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2079o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2079 rows=' rows;
else do; set g2079o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2079';
else put 'ERROR: ROUND5_FAIL=G2079 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2079:; quit;
