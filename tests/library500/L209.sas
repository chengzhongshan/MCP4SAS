/* L209: lengthn boundary 8; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxxxxxx');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L209';
else put 'ERROR: LIB500_FAIL=L209 actual=' actual;
run;
