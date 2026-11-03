/* T1334 sql_column_order, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/infile_with_array_function2randomly_select_variables_by_step_in_data_step4large_dataset.sas:68 */

data t1334a; x=5; y=6; run;
proc sql; create table t1334b as select y,x from t1334a; quit;
data t1334o; ds=open('t1334b','i'); actual=5+varnum(ds,'x'); rc=close(ds); run;

data _null_; if 0 then set t1334o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1334 rows=' rows;
else do; set t1334o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1334';
else put 'ERROR: ROUND3_FAIL=T1334 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1334:; quit;
