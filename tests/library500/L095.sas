/* L095: log boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(5);
if not missing(actual) and abs(actual-(1.6094379124341)) <= 1e-11*max(1,abs(1.6094379124341)) then put 'LIB500_PASS=L095';
else put 'ERROR: LIB500_FAIL=L095 actual=' actual;
run;
