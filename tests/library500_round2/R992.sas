/* R992 fileref_include, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r992o; actual=3*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r992o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R992 rows=' rows;
else do; set r992o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R992';
else put 'ERROR: ROUND2_FAIL=R992 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r992:; quit;
