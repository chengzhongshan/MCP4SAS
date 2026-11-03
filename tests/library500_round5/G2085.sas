/* G2085 physical_logical_observations, N=6; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2085a; do x=1 to 2*6; output; end; run;
proc sql; delete from g2085a where mod(x,2)=0; quit;
data g2085o; ds=open('g2085a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2085o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2085 rows=' rows;
else do; set g2085o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND5_PASS=G2085';
else put 'ERROR: ROUND5_FAIL=G2085 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2085:; quit;
