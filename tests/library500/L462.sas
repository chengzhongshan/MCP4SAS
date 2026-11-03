/* L462: input boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('018',3.);
if not missing(actual) and abs(actual-(18)) <= 1e-11*max(1,abs(18)) then put 'LIB500_PASS=L462';
else put 'ERROR: LIB500_FAIL=L462 actual=' actual;
run;
