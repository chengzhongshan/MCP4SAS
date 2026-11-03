/* L129: max boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */
data _null_;
actual=max(.A,8,-9);
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L129';
else put 'ERROR: LIB500_FAIL=L129 actual=' actual;
run;
