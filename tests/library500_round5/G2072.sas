/* G2072 open_where_fetch, N=3; source: SAS-Useful-Codes/Macros/GetVarAttrib.sas:46 */

data g2072a; do x=1 to 2*3; output; end; run;
data g2072o; ds=open('g2072a(where=(x>3))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;

data _null_; if 0 then set g2072o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2072 rows=' rows;
else do; set g2072o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2072';
else put 'ERROR: ROUND5_FAIL=G2072 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2072:; quit;
