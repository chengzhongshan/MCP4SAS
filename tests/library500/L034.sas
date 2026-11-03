/* L034: int boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(-2.25);
if not missing(actual) and abs(actual-(-2)) <= 1e-11*max(1,abs(-2)) then put 'LIB500_PASS=L034';
else put 'ERROR: LIB500_FAIL=L034 actual=' actual;
run;
