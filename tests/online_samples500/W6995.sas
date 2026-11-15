/* New workflow W6995; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6995i;
length gene $80;
gene='v01';x=0.0;y=3.0220949802409747;output;
gene='v02';x=0.3333333333333333;y=1.8095630890014325;output;
gene='v03';x=0.6666666666666666;y=0.9250522948466756;output;
gene='v04';x=1.0;y=-0.7547514047554694;output;
gene='v05';x=1.3333333333333333;y=4.338149554006772;output;
gene='v06';x=1.6666666666666667;y=1.5882887372208248;output;
gene='v07';x=2.0;y=0.17862219293609294;output;
gene='v08';x=2.3333333333333335;y=1.801717417838605;output;
gene='v09';x=2.6666666666666665;y=4.105594364643235;output;
gene='v10';x=3.0;y=2.5089724551988084;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6995" outputfmt=svg width=620px height=350px;title "W6995: synthetic SAS regression fixture";proc sgplot data=w6995i;scatter x=x y=y/markerattrs=(size=4);run;title;ods listing close;
data w6995m(keep=metric value);set w6995i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6995m;set w6995m;format value best32.;run;
proc export data=w6995m outfile="%sysfunc(pathname(work))/W6995.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6995;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6995:;quit;
