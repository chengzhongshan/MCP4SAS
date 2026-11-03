/* G2245 numeric_variable_list, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:50 */

data g2245a; length label $20; label='ignore'; array vals[6] v1-v6; do j=1 to 6; vals[j]=6; end; drop j; run;
data g2245o; set g2245a; actual=sum(of _numeric_); run;

data _null_; if 0 then set g2245o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2245 rows=' rows;
else do; set g2245o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND5_PASS=G2245';
else put 'ERROR: ROUND5_FAIL=G2245 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2245:; quit;
