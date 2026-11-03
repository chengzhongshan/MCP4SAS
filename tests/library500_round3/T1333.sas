/* T1333 sql_column_order, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1333a; x=4; y=5; run;
proc sql; create table t1333b as select y,x from t1333a; quit;
data t1333o; ds=open('t1333b','i'); actual=4+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1333o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1333 rows=' rows;
else do; set t1333o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1333';
else put 'ERROR: ROUND3_FAIL=T1333 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1333:; quit;
