/* G2074 open_where_fetch, N=5; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2074a; do x=1 to 2*5; output; end; run;
data g2074o; ds=open('g2074a(where=(x>5))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2074o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2074 rows=' rows;
else do; set g2074o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2074';
else put 'ERROR: ROUND5_FAIL=G2074 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2074:; quit;
