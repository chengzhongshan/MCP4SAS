/* L033: int boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(-3.25);
if not missing(actual) and abs(actual-(-3)) <= 1e-11*max(1,abs(-3)) then put 'LIB500_PASS=L033';
else put 'ERROR: LIB500_FAIL=L033 actual=' actual;
run;
