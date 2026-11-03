/* R996 fileref_include, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Test4Lattice_gscatter_over_bed_track_after_modification.sas:2 */

filename rtemp temp;
data _null_; file rtemp; put 'data r996o; actual=7*7; run;'; run;
%include rtemp;
filename rtemp clear;

data _null_; if 0 then set r996o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R996 rows=' rows;
else do; set r996o; if not missing(actual) and abs(actual-(49))<=1e-10*max(1,abs(49)) then put 'ROUND2_PASS=R996';
else put 'ERROR: ROUND2_FAIL=R996 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r996:; quit;
