/* G2081 physical_logical_observations, N=2; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2081a; do x=1 to 2*2; output; end; run;
proc sql; delete from g2081a where mod(x,2)=0; quit;
data g2081o; ds=open('g2081a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2081o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2081 rows=' rows;
else do; set g2081o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2081';
else put 'ERROR: ROUND5_FAIL=G2081 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2081:; quit;
