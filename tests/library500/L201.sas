/* L201: lengthn boundary 0; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('');
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L201';
else put 'ERROR: LIB500_FAIL=L201 actual=' actual;
run;
