/* L007: abs boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_remove_scatterplot.sas:78 */
data _null_;
actual=abs(0.75);
if not missing(actual) and abs(actual-(0.75)) <= 1e-11*max(1,abs(0.75)) then put 'LIB500_PASS=L007';
else put 'ERROR: LIB500_FAIL=L007 actual=' actual;
run;
