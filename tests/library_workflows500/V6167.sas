/* New workflow V6167; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6167i;
length gene $80;
gene='gene01';raw_c1=19.13;raw_c2=34.2;raw_c3=-20.73;raw_c4=-4.66;output;
gene='gene02';raw_c1=-18.74;raw_c2=4.33;raw_c3=-27.599999999999998;raw_c4=21.470000000000002;output;
gene='gene03';raw_c1=67.39;raw_c2=-13.54;raw_c3=50.53;raw_c4=-9.399999999999999;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6167i,Rgx=raw_);
data v6167m(keep=metric value);set v6167i;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6167i out=v6167s(keep=name type) noprint;run;data v6167s(keep=metric value);set v6167s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6167m data=v6167s;run;

data v6167m;set v6167m;format value best32.;run;
proc export data=v6167m outfile="%sysfunc(pathname(work))/V6167.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6167;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6167:;quit;
