/* New workflow W6581; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6581i;
length grp $80;
grp='g1';eff=0.11621869327461343;veff=0.1903964305151413;output;
grp='g2';eff=-0.22600313902687164;veff=0.08020630552111106;output;
grp='g3';eff=0.4513899680987772;veff=0.05754450096645693;output;
grp='g1';eff=0.6050014163621673;veff=0.2491341027302065;output;
grp='g2';eff=0.4349444261825466;veff=0.3822235095234764;output;
grp='g3';eff=0.7146165281240018;veff=0.06963792402957784;output;
grp='g1';eff=0.6964747687950961;veff=0.22451021971566318;output;
grp='g2';eff=0.6583392520523379;veff=0.342363377048017;output;
run;
%let varlist=grp;
%n26_wavgeff(w6581i,w6581o,0.9);run;
data w6581m(keep=metric value);set w6581o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6581m;set w6581m;format value best32.;run;
proc export data=w6581m outfile="%sysfunc(pathname(work))/W6581.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6581;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6581:;quit;
