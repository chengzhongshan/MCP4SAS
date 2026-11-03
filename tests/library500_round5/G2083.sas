/* G2083 physical_logical_observations, N=4; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2083a; do x=1 to 2*4; output; end; run;
proc sql; delete from g2083a where mod(x,2)=0; quit;
data g2083o; ds=open('g2083a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2083o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2083 rows=' rows;
else do; set g2083o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND5_PASS=G2083';
else put 'ERROR: ROUND5_FAIL=G2083 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2083:; quit;
