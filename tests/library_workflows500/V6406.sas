/* New workflow V6406; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6406i;
length gene $80;
gene='v01';pos=17;output;
gene='v02';pos=33;output;
gene='v03';pos=53;output;
gene='v04';pos=66;output;
gene='v05';pos=72;output;
gene='v06';pos=97;output;
gene='v07';pos=101;output;
gene='v08';pos=153;output;
gene='v09';pos=216;output;
run;
%n26_adjust_close_positions(indsd=v6406i,outdsd=v6406o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1060);
data v6406m(keep=metric value);set v6406o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6406m;set v6406m;format value best32.;run;
proc export data=v6406m outfile="%sysfunc(pathname(work))/V6406.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6406;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6406:;quit;
