/* G2075 open_where_fetch, N=6; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2075a; do x=1 to 2*6; output; end; run;
data g2075o; ds=open('g2075a(where=(x>6))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2075o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2075 rows=' rows;
else do; set g2075o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2075';
else put 'ERROR: ROUND5_FAIL=G2075 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2075:; quit;
