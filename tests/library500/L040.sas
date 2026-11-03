/* L040: int boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(3.75);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L040';
else put 'ERROR: LIB500_FAIL=L040 actual=' actual;
run;
