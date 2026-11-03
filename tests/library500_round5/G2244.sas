/* G2244 numeric_variable_list, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2244a; length label $20; label='ignore'; array vals[5] v1-v5; do j=1 to 5; vals[j]=5; end; drop j; run;
data g2244o; set g2244a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2244o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2244 rows=' rows;
else do; set g2244o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND5_PASS=G2244';
else put 'ERROR: ROUND5_FAIL=G2244 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2244:; quit;
