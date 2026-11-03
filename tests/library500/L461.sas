/* L461: input boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/_infile_and_lrecl_can_not_compbine_for_long_line_gt_32767.sas:29 */
data _null_;
actual=input('017',3.);
if not missing(actual) and abs(actual-(17)) <= 1e-11*max(1,abs(17)) then put 'LIB500_PASS=L461';
else put 'ERROR: LIB500_FAIL=L461 actual=' actual;
run;
