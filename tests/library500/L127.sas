/* L127: max boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */
data _null_;
actual=max(.A,6,-7);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L127';
else put 'ERROR: LIB500_FAIL=L127 actual=' actual;
run;
