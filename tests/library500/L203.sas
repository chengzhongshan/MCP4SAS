/* L203: lengthn boundary 2; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xx');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L203';
else put 'ERROR: LIB500_FAIL=L203 actual=' actual;
run;
