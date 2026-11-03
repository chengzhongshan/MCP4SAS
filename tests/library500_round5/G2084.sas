/* G2084 physical_logical_observations, N=5; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2084a; do x=1 to 2*5; output; end; run;
proc sql; delete from g2084a where mod(x,2)=0; quit;
data g2084o; ds=open('g2084a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2084o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2084 rows=' rows;
else do; set g2084o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND5_PASS=G2084';
else put 'ERROR: ROUND5_FAIL=G2084 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2084:; quit;
