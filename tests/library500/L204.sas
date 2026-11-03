/* L204: lengthn boundary 3; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxx');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L204';
else put 'ERROR: LIB500_FAIL=L204 actual=' actual;
run;
