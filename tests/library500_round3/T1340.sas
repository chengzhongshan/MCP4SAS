/* T1340 sql_column_order, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1340a; x=11; y=12; run;
proc sql; create table t1340b as select y,x from t1340a; quit;
data t1340o; ds=open('t1340b','i'); actual=11+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1340o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1340 rows=' rows;
else do; set t1340o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1340';
else put 'ERROR: ROUND3_FAIL=T1340 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1340:; quit;
