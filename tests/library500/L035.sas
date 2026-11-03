/* L035: int boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(-1.25);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L035';
else put 'ERROR: LIB500_FAIL=L035 actual=' actual;
run;
