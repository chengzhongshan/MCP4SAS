/* L458: missing boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:29 */
data _null_;
actual=missing(.F);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L458';
else put 'ERROR: LIB500_FAIL=L458 actual=' actual;
run;
