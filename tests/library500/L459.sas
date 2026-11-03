/* L459: missing boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:29 */
data _null_;
actual=missing(.G);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L459';
else put 'ERROR: LIB500_FAIL=L459 actual=' actual;
run;
