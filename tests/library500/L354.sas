/* L354: index boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxxneedle','needle');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L354';
else put 'ERROR: LIB500_FAIL=L354 actual=' actual;
run;
