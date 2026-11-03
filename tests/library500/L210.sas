/* L210: lengthn boundary 9; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxxxxxxx');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L210';
else put 'ERROR: LIB500_FAIL=L210 actual=' actual;
run;
