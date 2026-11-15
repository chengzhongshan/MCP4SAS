/* New workflow V6275; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6275i;
length gene $80;
gene='allele01';ref=36;alt=17;output;
gene='allele02';ref=16;alt=10;output;
gene='allele03';ref=20;alt=32;output;
gene='allele04';ref=31;alt=13;output;
run;
%n26_calculate_binomial_P(dsdin=v6275i,dsdout=v6275o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=8);
data v6275m(keep=metric value);set v6275o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6275m;set v6275m;format value best32.;run;
proc export data=v6275m outfile="%sysfunc(pathname(work))/V6275.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6275;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6275:;quit;
