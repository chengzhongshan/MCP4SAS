/* L457: missing boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:29 */
data _null_;
actual=missing(.E);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L457';
else put 'ERROR: LIB500_FAIL=L457 actual=' actual;
run;
