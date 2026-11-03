/* L205: lengthn boundary 4; source: SAS-Useful-Codes/Macros/METADAS.sas:352 */
data _null_;
actual=lengthn('xxxx');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L205';
else put 'ERROR: LIB500_FAIL=L205 actual=' actual;
run;
