/* L094: log boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(4);
if not missing(actual) and abs(actual-(1.386294361119891)) <= 1e-11*max(1,abs(1.386294361119891)) then put 'LIB500_PASS=L094';
else put 'ERROR: LIB500_FAIL=L094 actual=' actual;
run;
