/* L207: lengthn boundary 6; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxxxx');
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L207';
else put 'ERROR: LIB500_FAIL=L207 actual=' actual;
run;
