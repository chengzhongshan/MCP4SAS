/* L039: int boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:11 */
data _null_;
actual=int(2.75);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L039';
else put 'ERROR: LIB500_FAIL=L039 actual=' actual;
run;
