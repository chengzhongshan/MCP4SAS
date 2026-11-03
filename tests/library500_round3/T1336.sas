/* T1336 sql_column_order, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1336a; x=7; y=8; run;
proc sql; create table t1336b as select y,x from t1336a; quit;
data t1336o; ds=open('t1336b','i'); actual=7+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1336o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1336 rows=' rows;
else do; set t1336o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1336';
else put 'ERROR: ROUND3_FAIL=T1336 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1336:; quit;
