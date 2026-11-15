/* New workflow V6404; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6404i;
length gene $80;
gene='v01';pos=24;output;
gene='v02';pos=40;output;
gene='v03';pos=98;output;
gene='v04';pos=140;output;
gene='v05';pos=145;output;
gene='v06';pos=158;output;
gene='v07';pos=204;output;
run;
%n26_adjust_close_positions(indsd=v6404i,outdsd=v6404o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1040);
data v6404m(keep=metric value);set v6404o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6404m;set v6404m;format value best32.;run;
proc export data=v6404m outfile="%sysfunc(pathname(work))/V6404.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6404;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6404:;quit;
