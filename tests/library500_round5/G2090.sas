/* G2090 physical_logical_observations, N=11; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data g2090a; do x=1 to 2*11; output; end; run;
proc sql; delete from g2090a where mod(x,2)=0; quit;
data g2090o; ds=open('g2090a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;

data _null_; if 0 then set g2090o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2090 rows=' rows;
else do; set g2090o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND5_PASS=G2090';
else put 'ERROR: ROUND5_FAIL=G2090 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2090:; quit;
