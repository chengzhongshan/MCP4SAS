/* L178: n boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:6 */
data _null_;
actual=n(.,.A,7,8);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L178';
else put 'ERROR: LIB500_FAIL=L178 actual=' actual;
run;
