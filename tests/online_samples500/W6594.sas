/* New workflow W6594; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6594i;
length grp $80;
grp='g1';eff=0.07902897486688965;veff=0.3309638252355098;output;
grp='g2';eff=-0.336355672899339;veff=0.2047200309815536;output;
grp='g3';eff=0.15201784496645188;veff=0.30814320779008914;output;
grp='g1';eff=0.8254050650991382;veff=0.10773984495548469;output;
grp='g2';eff=0.39276197440273153;veff=0.225413741069583;output;
grp='g3';eff=-0.22824205559697575;veff=0.3996578436781372;output;
grp='g1';eff=0.7383754250324879;veff=0.12125299250036085;output;
run;
%let varlist=grp;
%n26_wavgeff(w6594i,w6594o,0.95);run;
data w6594m(keep=metric value);set w6594o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6594m;set w6594m;format value best32.;run;
proc export data=w6594m outfile="%sysfunc(pathname(work))/W6594.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6594;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6594:;quit;
