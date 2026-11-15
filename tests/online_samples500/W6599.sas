/* New workflow W6599; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6599i;
length grp $80;
grp='g1';eff=0.6319610955540453;veff=0.33262731255445777;output;
grp='g2';eff=-0.02914404144592142;veff=0.25649318335397114;output;
grp='g3';eff=-0.7298449712866999;veff=0.2240211863297926;output;
grp='g1';eff=0.052101031694688604;veff=0.1937082695813832;output;
grp='g2';eff=0.30395934685531945;veff=0.2847277512249205;output;
grp='g3';eff=0.46328259385275383;veff=0.25243293394670835;output;
grp='g1';eff=0.37009510482869823;veff=0.3632516862067314;output;
grp='g2';eff=0.8557968052569713;veff=0.02333877168593025;output;
grp='g3';eff=-0.5747257719467949;veff=0.18184323815570977;output;
grp='g1';eff=0.12258548976043604;veff=0.36568049135007985;output;
grp='g2';eff=-0.5518198982321781;veff=0.17698340666131232;output;
grp='g3';eff=-0.4017272725055897;veff=0.3682834486364876;output;
run;
%let varlist=grp;
%n26_wavgeff(w6599i,w6599o,0.99);run;
data w6599m(keep=metric value);set w6599o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6599m;set w6599m;format value best32.;run;
proc export data=w6599m outfile="%sysfunc(pathname(work))/W6599.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6599;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6599:;quit;
