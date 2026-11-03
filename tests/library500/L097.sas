/* L097: log boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(7);
if not missing(actual) and abs(actual-(1.945910149055313)) <= 1e-11*max(1,abs(1.945910149055313)) then put 'LIB500_PASS=L097';
else put 'ERROR: LIB500_FAIL=L097 actual=' actual;
run;
