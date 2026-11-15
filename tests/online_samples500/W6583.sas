/* New workflow W6583; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6583i;
length grp $80;
grp='g1';eff=-0.3694399277743108;veff=0.24673736658703693;output;
grp='g2';eff=-0.37309377468756016;veff=0.048317088019044184;output;
grp='g3';eff=0.7054322814596519;veff=0.15927696923160678;output;
grp='g1';eff=0.06913129510795979;veff=0.22121386820404007;output;
grp='g2';eff=0.08191855746418386;veff=0.263150067958432;output;
grp='g3';eff=0.8357806398685566;veff=0.1444994084970845;output;
grp='g1';eff=0.7761542970734003;veff=0.20650616468376246;output;
grp='g2';eff=0.7978998726142306;veff=0.059316165222361564;output;
grp='g3';eff=0.23340633071674088;veff=0.11582286544243568;output;
grp='g1';eff=-0.6521368255190813;veff=0.21007612311781249;output;
run;
%let varlist=grp;
%n26_wavgeff(w6583i,w6583o,0.99);run;
data w6583m(keep=metric value);set w6583o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6583m;set w6583m;format value best32.;run;
proc export data=w6583m outfile="%sysfunc(pathname(work))/W6583.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6583;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6583:;quit;
