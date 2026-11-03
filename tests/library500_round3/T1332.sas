/* T1332 sql_column_order, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1332a; x=3; y=4; run;
proc sql; create table t1332b as select y,x from t1332a; quit;
data t1332o; ds=open('t1332b','i'); actual=3+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1332o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1332 rows=' rows;
else do; set t1332o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1332';
else put 'ERROR: ROUND3_FAIL=T1332 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1332:; quit;
