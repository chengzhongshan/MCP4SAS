/* New workflow W6590; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6590i;
length grp $80;
grp='g1';eff=-0.3182869167365579;veff=0.043430613167888654;output;
grp='g2';eff=-0.14828381817221903;veff=0.07177179407703885;output;
grp='g3';eff=-0.7633231735669337;veff=0.08020989189204983;output;
grp='g1';eff=0.7574361582123241;veff=0.1926193141072003;output;
grp='g2';eff=-0.2857206541502285;veff=0.0834712785332808;output;
grp='g3';eff=-0.45055388976952493;veff=0.10524498456592771;output;
grp='g1';eff=0.13057265630197534;veff=0.03523292536274355;output;
grp='g2';eff=-0.4877808421771965;veff=0.18176258710078813;output;
grp='g3';eff=-0.04962716917491816;veff=0.07843778701452105;output;
grp='g1';eff=0.89932529662093;veff=0.3056905450225221;output;
run;
%let varlist=grp;
%n26_wavgeff(w6590i,w6590o,0.95);run;
data w6590m(keep=metric value);set w6590o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6590m;set w6590m;format value best32.;run;
proc export data=w6590m outfile="%sysfunc(pathname(work))/W6590.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6590;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6590:;quit;
