/* L355: index boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
actual=index('xxxxneedle','needle');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L355';
else put 'ERROR: LIB500_FAIL=L355 actual=' actual;
run;
