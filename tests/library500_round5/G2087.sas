/* G2087 physical_logical_observations, N=8; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2087a; do x=1 to 2*8; output; end; run;
proc sql; delete from g2087a where mod(x,2)=0; quit;
data g2087o; ds=open('g2087a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2087o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2087 rows=' rows;
else do; set g2087o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND5_PASS=G2087';
else put 'ERROR: ROUND5_FAIL=G2087 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2087:; quit;
