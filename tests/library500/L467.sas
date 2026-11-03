/* L467: input boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('023',3.);
if not missing(actual) and abs(actual-(23)) <= 1e-11*max(1,abs(23)) then put 'LIB500_PASS=L467';
else put 'ERROR: LIB500_FAIL=L467 actual=' actual;
run;
