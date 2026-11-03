/* L121: max boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Lattice_gscatter_over_bed_track_debug_and_optimization.sas:40 */
data _null_;
actual=max(.A,0,-1);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L121';
else put 'ERROR: LIB500_FAIL=L121 actual=' actual;
run;
