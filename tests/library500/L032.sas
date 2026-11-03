/* L032: int boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(-4.25);
if not missing(actual) and abs(actual-(-4)) <= 1e-11*max(1,abs(-4)) then put 'LIB500_PASS=L032';
else put 'ERROR: LIB500_FAIL=L032 actual=' actual;
run;
