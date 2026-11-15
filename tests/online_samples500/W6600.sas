/* New workflow W6600; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6600i;
length grp $80;
grp='g1';eff=0.3468048507677588;veff=0.18898254888094254;output;
grp='g2';eff=0.8363742338487135;veff=0.23548012427943266;output;
grp='g3';eff=0.6238494798143728;veff=0.27052721577083133;output;
grp='g1';eff=-0.5807304755125491;veff=0.20406148576719654;output;
grp='g2';eff=0.7736714470590993;veff=0.30527020857781273;output;
grp='g3';eff=-0.7478351178898525;veff=0.2281953497297582;output;
grp='g1';eff=-0.2186594943350234;veff=0.32113945420119244;output;
grp='g2';eff=0.21401017827829638;veff=0.0796610440378706;output;
grp='g3';eff=-0.4047177959975954;veff=0.3585556945538869;output;
grp='g1';eff=0.2972578425736616;veff=0.2042200290984441;output;
grp='g2';eff=0.7477385392284923;veff=0.2960730745899612;output;
grp='g3';eff=0.1629045534376452;veff=0.0552566059817111;output;
grp='g1';eff=0.3583352921423566;veff=0.07757107369003913;output;
run;
%let varlist=grp;
%n26_wavgeff(w6600i,w6600o,0.8);run;
data w6600m(keep=metric value);set w6600o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6600m;set w6600m;format value best32.;run;
proc export data=w6600m outfile="%sysfunc(pathname(work))/W6600.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6600;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6600:;quit;
