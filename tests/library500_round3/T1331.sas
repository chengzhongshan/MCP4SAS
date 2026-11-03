/* T1331 sql_column_order, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1331a; x=2; y=3; run;
proc sql; create table t1331b as select y,x from t1331a; quit;
data t1331o; ds=open('t1331b','i'); actual=2+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1331o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1331 rows=' rows;
else do; set t1331o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1331';
else put 'ERROR: ROUND3_FAIL=T1331 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1331:; quit;
