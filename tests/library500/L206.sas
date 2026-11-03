/* L206: lengthn boundary 5; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxxx');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L206';
else put 'ERROR: LIB500_FAIL=L206 actual=' actual;
run;
