/* G2088 physical_logical_observations, N=9; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2088a; do x=1 to 2*9; output; end; run;
proc sql; delete from g2088a where mod(x,2)=0; quit;
data g2088o; ds=open('g2088a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2088o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2088 rows=' rows;
else do; set g2088o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2088';
else put 'ERROR: ROUND5_FAIL=G2088 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2088:; quit;
