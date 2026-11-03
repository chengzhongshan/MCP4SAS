/* L096: log boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(6);
if not missing(actual) and abs(actual-(1.791759469228055)) <= 1e-11*max(1,abs(1.791759469228055)) then put 'LIB500_PASS=L096';
else put 'ERROR: LIB500_FAIL=L096 actual=' actual;
run;
