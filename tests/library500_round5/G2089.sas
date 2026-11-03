/* G2089 physical_logical_observations, N=10; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2089a; do x=1 to 2*10; output; end; run;
proc sql; delete from g2089a where mod(x,2)=0; quit;
data g2089o; ds=open('g2089a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2089o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2089 rows=' rows;
else do; set g2089o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND5_PASS=G2089';
else put 'ERROR: ROUND5_FAIL=G2089 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2089:; quit;
