/* G2080 open_where_fetch, N=11; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2080a; do x=1 to 2*11; output; end; run;
data g2080o; ds=open('g2080a(where=(x>11))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2080o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2080 rows=' rows;
else do; set g2080o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2080';
else put 'ERROR: ROUND5_FAIL=G2080 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2080:; quit;
