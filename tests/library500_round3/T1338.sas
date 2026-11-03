/* T1338 sql_column_order, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1338a; x=9; y=10; run;
proc sql; create table t1338b as select y,x from t1338a; quit;
data t1338o; ds=open('t1338b','i'); actual=9+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1338o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1338 rows=' rows;
else do; set t1338o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1338';
else put 'ERROR: ROUND3_FAIL=T1338 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1338:; quit;
