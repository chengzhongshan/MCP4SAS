/* New workflow W6984; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6984i;
length gene $80;
gene='v01';x=0.0;y=-1.2348112143261587;output;
gene='v02';x=0.3333333333333333;y=1.642466441223086;output;
gene='v03';x=0.6666666666666666;y=1.7767962946285487;output;
gene='v04';x=1.0;y=2.950459149531803;output;
gene='v05';x=1.3333333333333333;y=-0.5234209504584659;output;
gene='v06';x=1.6666666666666667;y=-0.8952288172008231;output;
gene='v07';x=2.0;y=0.4271099836139236;output;
gene='v08';x=2.3333333333333335;y=0.6299150324323259;output;
gene='v09';x=2.6666666666666665;y=2.160010726222938;output;
gene='v10';x=3.0;y=3.3932701432184045;output;
gene='v11';x=3.3333333333333335;y=5.2792353508298975;output;
gene='v12';x=3.6666666666666665;y=5.2299668193949005;output;
gene='v13';x=4.0;y=4.160923504216415;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6984" outputfmt=svg width=500px height=380px;title "W6984: synthetic SAS regression fixture";proc sgplot data=w6984i;scatter x=x y=y/markerattrs=(size=8);run;title;ods listing close;
data w6984m(keep=metric value);set w6984i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6984m;set w6984m;format value best32.;run;
proc export data=w6984m outfile="%sysfunc(pathname(work))/W6984.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6984;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6984:;quit;
