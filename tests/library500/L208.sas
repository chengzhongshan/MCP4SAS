/* L208: lengthn boundary 7; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxxxxx');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L208';
else put 'ERROR: LIB500_FAIL=L208 actual=' actual;
run;
