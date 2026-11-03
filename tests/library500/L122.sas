/* L122: max boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */
data _null_;
actual=max(.A,1,-2);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L122';
else put 'ERROR: LIB500_FAIL=L122 actual=' actual;
run;
