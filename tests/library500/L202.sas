/* L202: lengthn boundary 1; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('x');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L202';
else put 'ERROR: LIB500_FAIL=L202 actual=' actual;
run;
