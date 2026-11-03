/* T1335 sql_column_order, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1335a; x=6; y=7; run;
proc sql; create table t1335b as select y,x from t1335a; quit;
data t1335o; ds=open('t1335b','i'); actual=6+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1335o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1335 rows=' rows;
else do; set t1335o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1335';
else put 'ERROR: ROUND3_FAIL=T1335 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1335:; quit;
