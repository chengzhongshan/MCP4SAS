/* R999 fileref_include, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r999o; actual=10*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r999o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R999 rows=' rows;
else do; set r999o; if not missing(actual) and abs(actual-(70))<=1e-10*max(1,abs(70)) then put 'ROUND2_PASS=R999';
else put 'ERROR: ROUND2_FAIL=R999 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r999:; quit;
