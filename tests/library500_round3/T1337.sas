/* T1337 sql_column_order, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1337a; x=8; y=9; run;
proc sql; create table t1337b as select y,x from t1337a; quit;
data t1337o; ds=open('t1337b','i'); actual=8+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1337o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1337 rows=' rows;
else do; set t1337o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1337';
else put 'ERROR: ROUND3_FAIL=T1337 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1337:; quit;
