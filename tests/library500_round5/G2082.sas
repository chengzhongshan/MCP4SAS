/* G2082 physical_logical_observations, N=3; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2082a; do x=1 to 2*3; output; end; run;
proc sql; delete from g2082a where mod(x,2)=0; quit;
data g2082o; ds=open('g2082a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2082o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2082 rows=' rows;
else do; set g2082o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2082';
else put 'ERROR: ROUND5_FAIL=G2082 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2082:; quit;
