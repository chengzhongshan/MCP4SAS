/* R993 fileref_include, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r993o; actual=4*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r993o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R993 rows=' rows;
else do; set r993o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R993';
else put 'ERROR: ROUND2_FAIL=R993 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r993:; quit;
