/* New workflow V6401; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6401i;
length gene $80;
gene='v01';pos=93;output;
gene='v02';pos=97;output;
gene='v03';pos=98;output;
gene='v04';pos=111;output;
run;
%n26_adjust_close_positions(indsd=v6401i,outdsd=v6401o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1010);
data v6401m(keep=metric value);set v6401o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6401m;set v6401m;format value best32.;run;
proc export data=v6401m outfile="%sysfunc(pathname(work))/V6401.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6401;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6401:;quit;
