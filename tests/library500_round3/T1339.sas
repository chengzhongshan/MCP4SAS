/* T1339 sql_column_order, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1339a; x=10; y=11; run;
proc sql; create table t1339b as select y,x from t1339a; quit;
data t1339o; ds=open('t1339b','i'); actual=10+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1339o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1339 rows=' rows;
else do; set t1339o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1339';
else put 'ERROR: ROUND3_FAIL=T1339 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1339:; quit;
