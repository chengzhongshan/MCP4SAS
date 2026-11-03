/* L099: log boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/hpgenselect_hpgenselect_and_other_hp_procedures_demo.sas:155 */
data _null_;
actual=log(9);
if not missing(actual) and abs(actual-(2.19722457733622)) <= 1e-11*max(1,abs(2.19722457733622)) then put 'LIB500_PASS=L099';
else put 'ERROR: LIB500_FAIL=L099 actual=' actual;
run;
