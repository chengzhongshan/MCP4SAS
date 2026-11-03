/* L001: abs boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_remove_scatterplot.sas:78 */
data _null_;
actual=abs(-5.25);
if not missing(actual) and abs(actual-(5.25)) <= 1e-11*max(1,abs(5.25)) then put 'LIB500_PASS=L001';
else put 'ERROR: LIB500_FAIL=L001 actual=' actual;
run;
