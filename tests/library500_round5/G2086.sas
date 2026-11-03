/* G2086 physical_logical_observations, N=7; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2086a; do x=1 to 2*7; output; end; run;
proc sql; delete from g2086a where mod(x,2)=0; quit;
data g2086o; ds=open('g2086a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2086o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2086 rows=' rows;
else do; set g2086o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND5_PASS=G2086';
else put 'ERROR: ROUND5_FAIL=G2086 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2086:; quit;
