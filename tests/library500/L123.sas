/* L123: max boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */
data _null_;
actual=max(.A,2,-3);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L123';
else put 'ERROR: LIB500_FAIL=L123 actual=' actual;
run;
