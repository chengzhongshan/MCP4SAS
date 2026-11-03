/* G2242 numeric_variable_list, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2242a; length label $20; label='ignore'; array vals[3] v1-v3; do j=1 to 3; vals[j]=3; end; drop j; run;
data g2242o; set g2242a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2242o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2242 rows=' rows;
else do; set g2242o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND5_PASS=G2242';
else put 'ERROR: ROUND5_FAIL=G2242 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2242:; quit;
