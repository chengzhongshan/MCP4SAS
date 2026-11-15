/* New workflow W6997; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6997i;
length gene $80;
gene='v01';x=0.0;y=-0.3967551710179116;output;
gene='v02';x=0.3333333333333333;y=-0.2966446574071692;output;
gene='v03';x=0.6666666666666666;y=2.6797144621405136;output;
gene='v04';x=1.0;y=-0.6838587437158373;output;
gene='v05';x=1.3333333333333333;y=1.2613445075312233;output;
gene='v06';x=1.6666666666666667;y=4.857008834181672;output;
gene='v07';x=2.0;y=2.2924497695839694;output;
gene='v08';x=2.3333333333333335;y=5.2871893074203875;output;
gene='v09';x=2.6666666666666665;y=2.844642922747401;output;
gene='v10';x=3.0;y=3.4480204753843395;output;
gene='v11';x=3.3333333333333335;y=4.851339932457793;output;
gene='v12';x=3.6666666666666665;y=4.760009106574652;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6997" outputfmt=svg width=540px height=410px;title "W6997: synthetic SAS regression fixture";proc sgplot data=w6997i;scatter x=x y=y/markerattrs=(size=6);run;title;ods listing close;
data w6997m(keep=metric value);set w6997i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6997m;set w6997m;format value best32.;run;
proc export data=w6997m outfile="%sysfunc(pathname(work))/W6997.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6997;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6997:;quit;
