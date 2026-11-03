/* G2073 open_where_fetch, N=4; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2073a; do x=1 to 2*4; output; end; run;
data g2073o; ds=open('g2073a(where=(x>4))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2073o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2073 rows=' rows;
else do; set g2073o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2073';
else put 'ERROR: ROUND5_FAIL=G2073 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2073:; quit;
