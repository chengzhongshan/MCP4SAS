/* G2247 numeric_variable_list, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2247a; length label $20; label='ignore'; array vals[8] v1-v8; do j=1 to 8; vals[j]=8; end; drop j; run;
data g2247o; set g2247a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2247o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2247 rows=' rows;
else do; set g2247o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND5_PASS=G2247';
else put 'ERROR: ROUND5_FAIL=G2247 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2247:; quit;
