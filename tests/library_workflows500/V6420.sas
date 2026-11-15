/* New workflow V6420; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6420i;
length gene $80;
gene='v01';pos=24;output;
gene='v02';pos=124;output;
gene='v03';pos=181;output;
gene='v04';pos=186;output;
gene='v05';pos=192;output;
gene='v06';pos=206;output;
gene='v07';pos=214;output;
gene='v08';pos=243;output;
gene='v09';pos=257;output;
run;
%n26_adjust_close_positions(indsd=v6420i,outdsd=v6420o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1200);
data v6420m(keep=metric value);set v6420o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6420m;set v6420m;format value best32.;run;
proc export data=v6420m outfile="%sysfunc(pathname(work))/V6420.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6420;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6420:;quit;
