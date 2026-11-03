/* G2249 numeric_variable_list, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2249a; length label $20; label='ignore'; array vals[10] v1-v10; do j=1 to 10; vals[j]=10; end; drop j; run;
data g2249o; set g2249a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2249o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2249 rows=' rows;
else do; set g2249o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND5_PASS=G2249';
else put 'ERROR: ROUND5_FAIL=G2249 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2249:; quit;
