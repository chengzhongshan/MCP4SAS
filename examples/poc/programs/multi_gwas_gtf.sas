/* Same frozen multi-GWAS figure program for both routes. */
options notes source nodate nonumber fullstimer dlcreatedir;
ods _all_ close;
%let BOOK_OUT=%sysfunc(pathname(work));
%let AF_OUT=&BOOK_OUT;
data _null_;rc=dlgcdir(pathname('work'));run;
%put POC_OUT=&BOOK_OUT;
%global chr_var dotsize var_type;

/* Source companion/research/advanced_figures/sources/definitions/ApplyFunc_rowwide.sas */
%macro ApplyFunc_rowwide(
/*The macro is a handy tool to calculate common summary statistics, such as mean, median, sum, n, std, and others that allowed
in proc sql when conducting analysis on groups on ROW-WIDE. Additionally, the macro can generate summary statistics by 
including data from both rows and columns, with special case to generate summary statistics on all columns without providing row_keys or 
on all data in a table from all columns and rows!*/
dsdin,
row_keys,
KeyVar4dsdout,
Regex4col_vars2apply,
SQL_Fun4apply,
dsdout,
KeyVar4dsdout_length=200,
AlsoAppFun4Cols=0
);
%let n=%numargs(&row_keys);
%put macro var row_keys are &row_keys;

%if %eval(&n=0) %then %do;
data &dsdout;
set &dsdin;
&KeyVar4dsdout="AllRows";
run;
%end;
%else %do;
data &dsdout;
length &KeyVar4dsdout $ &KeyVar4dsdout_length;
set &dsdin;
&KeyVar4dsdout=catx(":",
%let i=1;
%do %while (&i<&n);
   %scan(&row_keys,&i,%str( )),
   %let i=%eval(&i+1);
%end;
   %scan(&row_keys,&n,%str( ))
);
run;
%end;


proc contents data=&dsdin out=_vars_ noprint;
run;
proc sql noprint;
select Name into: vars4apply separated by ' '
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);

select count(Name) into: nvars4apply
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);


%if %eval(&AlsoAppFun4Cols=0) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %do %while (&ii<&nvars4apply);
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var,)
   %let ii=%eval(&ii+1);
  %end;
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;
%end;

%else %if %eval(&AlsoAppFun4Cols=1) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %let Var=&SQL_Fun4apply(;
  %do %while (&ii<&nvars4apply);
   %let Var=&Var%scan(&vars4apply,&ii,%str( )),;
   %let ii=%eval(&ii+1);
  %end;
   %let Var=&Var%scan(&vars4apply,&ii,%str( ));
   %str(&Var%) as ALL_Matched_Cols)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;

/*Assemble all dup &KeyVar4dsdout for &SQL_Fun4apply*/
proc sql;
create table &dsdout as
select &KeyVar4dsdout,&SQL_Fun4apply(All_Matched_Cols) as &SQL_Fun4apply
from &dsdout
group by &KeyVar4dsdout;

%end;

*Only remove 'New_' within varnames;
%Rename_Del_Rgx4All_Vars(indsd=work.&dsdout,Rgx=New_);

%mend;


/* Source companion/research/advanced_figures/sources/definitions/Check_VarnamesInDsd.sas */
%macro Check_VarnamesInDsd(indsd=,Rgx=.,exist_tag=,abort_on_missing=1);

%global &exist_tag;
%let &exist_tag=;
%put Your input sas dsd is &indsd;

*Add quit here to quit process that may prevent the script from running proc contents;
quit;
%put Going to run proc contents to obtain variable list!;
proc contents data=&indsd out=_tmp_(keep=name type) noprint;
run;

%if not %sysfunc(exist(_tmp_)) %then %do;
  %put The proc contents failed to generate variable table!;
  %abort 255;
%end;

data _tmp_1;
set _tmp_;
if prxmatch("/&Rgx/i",name);
run;
proc sql noprint;
select name into: &exist_tag separated by ' '
from _tmp_1;
%put Your rgx (&Rgx) matchs the following vars:;
%put &&&exist_tag;
%put A global macro var &exist_tag is created to have the varnames;

%if %length(&&&exist_tag)=0 %then %do;
  %put No varnames matching with your Rgx (&Rgx);
  %if %sysevalf(&abort_on_missing=1) %then %do;
    %abort 255;
  %end;
%end;
%else %do;
	 proc datasets lib=work nolist;
   delete _tmp_:;
   run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/FileOrDirExist.sas */
%macro FileOrDirExist(dir) ; 
   %LOCAL rc fileref return; 

   %*arbitrarily assign value 0 to output if dir is empty;
   %*This will avoid of error message issued by fexist later;
   %if %length(&dir)=0 %then %do;
          0
    %end;
	%*It is necessary to add else do macro statement here, otherwise, even if the above is true, later codes will still run by sas;
    %else %do;

   %let rc = %sysfunc(filename(fileref,&dir)) ; 
/*    %if &rc=0 and %sysfunc(fexist(&fileref))  %then %let return=1;     */
/*    %else %let return=0; */
/*    &return */
%*The above failed in SAS OnDemand but works in Windows;
%*The reason is because the sas funciton will return these sas comments if not escaped by %;
%*Note: it is necessary to assign &fileref but not fileref to fexist here!;
   %if %sysevalf(&rc=0 and %symexist(fileref) and %sysfunc(fexist(&fileref)))  %then %do;
       1
   %end;
   %else %do;
       0
   %end;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/GetVarAttrib.sas */
%MACRO GetVarAttrib(data, var, fun);
%local data_name dsid rc varnum attrib;

%let data_name = %scan(&data, 1, '(');

%* Initialize &attrib to empty in case there is an error;
%let attrib = ;
%* Open input dataset;
%let dsid = %sysfunc(open(&data_name));
	%** Note that data options are accepted in the open statement but I still use &data_name
	%** because I need it for the %PUT below in case there is an error;
%if &dsid = 0 %then
	%put GETVARATTRIB: ERROR - Dataset %upcase(&data_name) does not exist.;
%else %do;
	%let varnum = %sysfunc(varnum(&dsid,&var));
	%if &varnum = 0 %then
		%put GETVARATTRIB: ERROR - Variable %upcase(&var) does not exist in dataset %upcase(&data_name).;
	%else
		%let attrib = %sysfunc(&fun(&dsid,&varnum));
	%* Close input dataset;
	%let rc = %sysfunc(close(&dsid));
%end;

&attrib
%MEND GetVarAttrib;


/* Source companion/research/advanced_figures/sources/definitions/GetVarType.sas */
%MACRO GetVarType(data, var);
%local vartype;
%let vartype = %GetVarAttrib(&data, &var, vartype);
&vartype
%MEND GetVarType;


/* Source companion/research/advanced_figures/sources/definitions/Lattice_gscatter_over_bed_track.sas */
%macro Lattice_gscatter_over_bed_track(
/*
Note: when makedotheatmap=1, in default, the scatterplot will use lattice_subgrp_var to color dots 
across different scatter groups; User can supply an independent variable represented by the macro variable
color_resp_var to color scatter plot dots but different scattergroups will be applied in a union style!
This macro can also draw mixed CNV and scatter plots upper the gene tracks; 
*/
bed_dsd,/*at least contains 7 variables, including chr_var, st_var, end_var, grp_var, and yval_var;
Too many bed regions (>1000) for the gene track will slow down the macro dramatically;
Note: the macro will change the input bed_dsd when supplying xaxis_viewmin and xaxis_viewmax*/
chr_var,/*chromosome name for bed regions*/
st_var,	/*start positions for bed regions*/
end_var,/*end positions for bed regions*/
Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!*/
grp_var,/*it is specifically designed for genes used by the lower gene track, such as genesymbols for all its bed regions,
and the upper scatterplot tracks do not use it, thus values for data points in the scatterplots can be missing*/
scatter_grp_var,/*it is used to separate scatterplot data points into different scatter groups, and its values for 
scatterplot data points and gene bed regions in lower gene track should be positve and negative, respectively;
when only draw gene tracks, ensure the the negative value, such as -1, provided for all bed regions, and 
the macro will automatically separate these genes if they are too close to each other!*/
lattice_subgrp_var,/*specifically designed for scatterplots, its values are used to separate dots in scatterplots 
into different groups and color them based on its yval_var value; when only draw gene tracks, just assign the same
value for all bed regions, which can be 0 or any other numeric or character values, as it will be only enable the 
macro to run successful but will not be used for drawing the final figure!*/
yval_var, /*this variable is used to draw y-axis for dots of scatterplots and bed regions of genes*/
yaxis_label=Group,/*The value will be used to label the y-axis*/
linethickness=20, /*line thinkness for gene bed regions*/
track_width=800, /*Final figure width*/
track_height=400,/*Final figure height*/
image_dpi=300,/*Raster output DPI. Lower values reduce SAS ODA Java memory use without changing the layout.*/
dist2st_and_end=0,/*Extend the start and end position for the x-axis*/
dotsize=10,/*Scatter plot marker symbol size, and the default marker is circlefilled dot; when making heatmap, it is
possible to restrict the dotsize as the same for the highlow line size, such as 10pt, which would be different from the 
default value 10 without the pt unit!*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
debug=0,/*keep intermediate data sets for debugging if its value is 1*/
add_grp_anno=1, /*This will add group names, such as gene labels, to each member of grp_var*/
grp_font_size=8, /*font size for gene labels in the lower gene track*/
grp_anno_font_type=italic, /*other type: normal; specifically designed for the gene label font type*/
shift_text_yval=-0.25, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
to liftup or lower text labels on the y axis; the default value is -0.25 to put gene lable under gene tracks;
Change it with the macro var pct4neg_y! Provide very large or small values, such as 9999 or -9999 to remove test labels for genes!*/
amplify_scatterheader_pos=1, /*Provide value 1 to the macro var when the max value for each scatter plot is too large, 
the header position for it should be amplified automatically by the macro*/
yaxis_offset4min=0.05, /*provide 0-1 value or auto to offset the min of the yaxis*/
yaxis_offset4max=0.05, /*provide 0-1 value or auto or to offset the max of the yaxis*/
yoffset4max_drawmarkersontop=0.15,/*Important parameter for controling the height of headroom for labeling top snps on the top;
If draw scatterplot marker labels on the top of track, this fixed value will be used instead of yaxis_offset4max! 
This is very important for customizing the height of top headroom that will be put with the snp labels within it.
the input value for the macro var will be further adjusted internally based on the number of scatter plots and the max value between 
fixed values and adjust value, and finally assigns a value to the parameter offsetmax for y-axis. The macro will print out the following to show the 
value assigned for the offsetmax: offsetmax for y-axis is set as num! please check log for debug!*/
yaxis_auto_ticks=0,/*Provide value 1 to let SAS automatically reduce the number of ticks, which may be useful when non-integer ticks are required for y-axis;
otherwise, only integer ticks will be used to label ticks! However, sometimes this will lead to abnomal yaxis ticks generated!*/
draw_grid4y=0, /*Assign value 1 to draw grid for y axis; default value is 0 for not drawing y grid*/
xaxis_offset4min=0.01, /*provide 0-1 value or auto  to offset the min of the xaxis*/
xaxis_offset4max=0.005, /*provide 0-1 value or auto to offset the max of the xaxis*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
refline_thickness=5,/*Use thick refline to separate different tracks*/
refline_color=lightgray,/*Color for reflines*/
pct4neg_y=2, /*the most often used value is 1, and if the value is too large, it will affect the 
 y-axis tick labels by leading to very few y-axis ticks in the final figure!
 So if the above occurs, it is feasible to reduce the value of pct4neg_y or increase
 the value of macro variable track_height inaccordingly.
 compacting the bed track y values by increasing the scatterplot scale, 
 which can reduce the bed trace spaces; It seems that two-fold increasement
 leads to better ticks for different tracks!
 Use value >1 will increase the gene tract, while value < 1 will reduce it!
 Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
 Modify this parameter with the parameter shift_text_yval to adjust gene label!
 Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
 If there are only <4 scatterplots, the value would be usually set as 1 or 2;*/
NotDrawScatterPlot=0,/*This filter will be useful when it is only wanted to draw the bottom bed track
without of the scatterplot; this is the idea solution to draw gene track only!*/ 
offsety=0.05,/*If NotDrowScatterPlot=1, this value will be subtracted from negative gene group value;
This enables the upper and lower part have enough blank space for gene track*/

makedotheatmap=0,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot
Note: if makedotheatmap=1, autolegend will be canceled internally!*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/
heatmap_legend_title=%str(Z score),/*Visible title for the heatmap colorbar legend; update this when the scatter colors
are driven by a different effect metric such as beta or odds ratio*/
plot_title=,/*Optional visible title identifying the plotted color metric.*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=,/*Note: this only works when makedotheatmap=0!
Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!*/
dot_yvalue4heatmap_at_oneline=1.5,/*When drawing dot in one line for heatmap, sometimes the arbitrary y value assigned to each dot
may not be optimum, it is advicible to evaluate the initially generated plot and update the value of this macro variable*/
drawdotintooneline_if_totsc_gt=0,/*0 disables automatic flattening and preserves makeheatmapdotintooneline=0. A positive threshold explicitly enables compact tracks.*/
var4label_scatterplot_dots=,/*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the scatterplots;*/
var4mark_ld_scatterplot_dots=,/*Optional character variable containing the selected marker for LD-linked variants and blank otherwise.*/
ld_marker_color=black,/*SAS color name or CXrrggbb value for LD marker text.*/
ld_marker_legend_symbol=*,/*Text shown before LD-linked SNP in the legend.*/
ld_heatmap_var=,/*Optional numeric 0-1 LD r2 variable. Blank keeps LD coloring disabled.*/
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,/*Separate sequential palette for LD, distinct from the association Z-score palette.*/
ld_heatmap_legend_title=%str(LD r2),/*Title for the opt-in LD inset legend.*/
label_dots_once_on_top=1,/*Put value 1 to label each unique label once on top of scatterplot;
provide 0 for labeling selected dots inside scatterplots;
The script will enlarge the macro var yaxis_offset4max to be 0.1!*/
dist_pct_to_cluster_pos=0.02,/*In terms of labels for top SNPs, use the input pct to calcuate dist based on the distance 
betweent the first label to the last label and define labels into cluster if they are too close to each other if their distance is less than pct_of_total_dist*/
fc2distant_close_labels=3,/*In terms of labels for top SNPs, increase the distance among close labels by input fold change
default value 3 would be good for most situations! Note: this parameter is also used to amplify the space for separating
adjacent SNP labels when adjusting spaces using adj_spaces_among_top_snps=1 with the default setting:
sep4tgt_pos=&fc2distant_close_labels*0.1*(&max_x-&min_x+1)/total_SNPs
Whent the above default distance does not work well, it is suggested to increase or reduce the value of fc2distant_close_labels*/
pct2adj4dencluster=2,/*Input value can be ranging from 0.0001 to 10 or even higher value!
For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!*/
reflinecolor4selecteddots=gray,/*asign color for the vertical reference lines for userselected dots*/
snp_line_split_ratio=0.99,/*split the vertical reference lines into two parts based on the ratio, with the 
smaller part drawn from the end of point of the larger part to the adjusted position of each snp!*/
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=, /*Optional space-delimited SNP=BP labels placed by the local Perl planner.*/
label_headroom_frac=, /*Planned y-axis top offset for the actual label height.*/
label_center_offset=, /*GTL POSITIONOFFSETY in units of the text height.*/
auto_rotate2zero=0, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
adj_spaces_among_top_snps=1,/*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/
Yoffset4textlabels=2.5, /*Important parameter to adjust the position of snp label in line with the headroom to the top;
Move up the text labels for target SNPs in specific fold; the default value 2.5 fold works for most cases;
Note: the value of this variable will be automatically changed to enable the target SNP are labeled properly on the top of the figure;
So you may notice that when there is only one SNP for labeling on the top, adjust this value may not efficient, and you may go to 
the line ~1150 of this macro to reduce or increase the ratio of 1000/&track_height to adjust the SNP label manually!*/
font_size4textlabels=10,/*Font size for these text labels*/
move_right_genetxt_pct=0.08,/*When the right most genes are too close to the right boudary, it is necessary to reduce its x-axis position
using the designated pct based on the whole window size that will be automatically calcuated by the macro*/
mk_fake_axis_with_updated_func=1, /*The new func make the xaxis more compacted between gene tracks and scatter plots;*/
sameyaxis4scatter=1,/*Make the same y-axis for scatterplots*/ 
maxyvalue4truncat=30,/*Asign yaxis_value >maxyvalue4trancat as the designated value of maxyvalue4trancat*/ 
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
ordered_sc_grpnames= ,/*Labels for each scatter plot from down to up in order; Use _ to replace blank space within each name and all
_ will be changed into black space by the macro at the end*/
xaxis_label=%nrstr(Position (bp) on chromosome &chr_name), /*The macro var &chr_name will be unquoted after resolved*/        
xaxis_viewmin=,/*arbitrary xaxis min value to show the figure, and it requires to work with thresholdmin=0*/
xaxis_viewmax=,/*arbitrary xaxis max vale to show the figure, and it requires to go along with thresholdmax=0*/
rm_gene_legend=1,/*Remove redundant colorful gene legend*/
scatterdotcols=green orange, /*set colors for the beta directions green orange
(negative and positve values) in scatterplots*/            
dataContrastCols=%str(),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control;
%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000)*/
/*Note: default is to use %str(), which will apply system colors automatically;
add the following colors separated by blank space if desired,
CXADD8E6 CX98FB98 CXF08080 CX0000FF CXFFF00 CX9F5F9F CXA62A2A CX5F9F9F CX871F78
lightblue lightgreen lightcoral and others for the above!
https://support.sas.com/rnd/base/ods/templateFAQ/Template_colors.html
BLACK #FFFFFF
BLUE #0000FF
YELLOW #FFF000
BLUE VIOLET #9F5F9F
BROWN #A62A2A
CADET BLUE #5F9F9F
DARK BROWN #5C4033
DARK PURPLE #871F78
DUSTY ROSE #856363
GOLD #CD7F32
KHAKI #9F9F5F
NAVY BLUE #23238E
PINK #BC8F8F
SILVER #E6E8FA
TURQUOISE #ADEAEA
RED #FF0000
MAGENTA #FF00FF
BLACK #000000
BRASS #B5A642
BRONZE #8C7853
COPPER #B87333
DARK GREEN #2F4F2F
DARK TAN #97694F
FIREBRICK #8E2323
GREY #C0C0C0
LIME GREEN 32CD32
ORANGE #FF7F00
PLUM #EAADEA
STEEL BLUE #236B8E
VIOLET #4F2F4F
GREEN #00FF00
CYAN #00FFFF
AQUAMARINE #70DB93
BRIGHT GOLD #D9D919
BRONZE II #A67D3D
CORAL #FF7F00
DARK WOOD #855E42
DIM GREY #545454
FOREST GREEN #238E23
INDIAN RED #4E2F2F
MAROON #8E236B
ORCHARD #DB70DB
SCARLET #8C1717
TAN #DB9370
WHEAT #D8D8BF*/

/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
highlow_line_cmd=%str(thickness=8 color=darkorange pattern=solid)

);
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0i3rles1y5mvsn1hrq3i2271rmi.htm;
*SAS marker symbols;

%if %symexist(force_lattice_xaxis_viewmin) and %length(%superq(force_lattice_xaxis_viewmin))>0 %then %do;
%let xaxis_viewmin=%superq(force_lattice_xaxis_viewmin);
%put NOTE: Overriding xaxis_viewmin with force_lattice_xaxis_viewmin=&xaxis_viewmin.;
%end;
%if %symexist(force_lattice_xaxis_viewmax) and %length(%superq(force_lattice_xaxis_viewmax))>0 %then %do;
%let xaxis_viewmax=%superq(force_lattice_xaxis_viewmax);
%put NOTE: Overriding xaxis_viewmax with force_lattice_xaxis_viewmax=&xaxis_viewmax.;
%end;

*If not draw scatter plot on top tracks, reassign the value of yaxis_label as Annotation;
%if &NotDrawScatterPlot=1 %then %let yaxis_label=Annotation;

*Keep a copy of original data set &bed_dsd;
data &bed_dsd._org;
set &bed_dsd;
run;
*Adjust start and end positions based on &Variant_Length_Var if it is not empty;
*This is specifically designed to handle CNVs;
%if %length(&Variant_Length_Var)>0 %then %do;
data &bed_dsd;
set &bed_dsd;
if &Variant_Length_Var>1 then do;
   &end_var=&st_var+0.5*&Variant_Length_Var;
   &st_var=&st_var-0.5*&Variant_Length_Var;
end;
run;
%end;
%else %do;
%let Variant_Length_Var=var_length;
data &bed_dsd;
set &bed_dsd;
Variant_Length_Var=&end_var-&st_var;
run;
%end;
/*%abort 255;*/

%if "&var4label_scatterplot_dots"="&color_resp_var" and "&var4label_scatterplot_dots"^="" %then %do;
*Note: var4label_scatterplot_dots and color_resp_var can not use the same variable;
*To avoid of the crash, let create a temporary variable for color_resp_var;
data &bed_dsd;
set &bed_dsd;
_color_resp_var_=&var4label_scatterplot_dots;
run;
%let color_resp_var=_color_resp_var_;
%end;

%if "&color_resp_var"^="" and  "&dataContrastCols"="" %then %let
dataContrastCols=%str(lightblue lightgreen
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
);

%Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&color_resp_var,exist_tag=HasVar);
%if %length(&HasVar)=0 %then %do;
 %put The color_resp_var: &color_resp_var does not exist in the sas dsd &bed_dsd;
 %abort 255;
%end;

%let color_resp_vartype=;
%let Other_num_grpval=;

%if %length(&color_resp_var)>0 %then %do;

/*Also check the color_resp_var type; if it is char var, it is necessary to make numberic
var to link each char var for making format and using them as legend in the final figure*/
%let color_resp_vartype=%GetVarType(&bed_dsd,&color_resp_var);

%if %length(&color_resp_grpdsd)=0 %then %do;    
   proc sql noprint;
   create table _color_resp_dsd_ as
   select unique(&color_resp_var) as &color_resp_var
   from &bed_dsd
   order by &color_resp_var;
   create table _color_resp_dsd_ as
   select &color_resp_var,monotonic() as numgrp4color_resp
   from _color_resp_dsd_;
   %let color_resp_grpdsd=_color_resp_dsd_;
%end;
%else %do;

  *Check the fixed numeric variable numgrp4color_resp in the input dataset &color_resp_grpdsd;
  %Check_VarnamesInDsd(indsd=&color_resp_grpdsd,Rgx=&color_resp_var,exist_tag=HasVar);
  %if %length(&HasVar)=0 %then %do;
   %put The color_resp_var: &color_resp_var does not exist in the sas dsd &bed_dsd;
   %abort 255;
  %end;
  %Check_VarnamesInDsd(indsd=&color_resp_grpdsd,Rgx=numgrp4color_resp,exist_tag=HasVar);
  %if %length(&HasVar)=0 %then %do;
    %put the fixed variable numgrp4color_resp does not exist in the input dataset &color_resp_grpdsd;
    %abort 255;
  %end;

%end;

%if "&color_resp_vartype"="C" %then %do;
    %rank4grps(grps=Others,dsdout=_other_dsd_);
    data _other_dsd_(keep=&color_resp_var numgrp4color_resp);
	set _other_dsd_;
/*	&color_resp_var=grps;*/
	&color_resp_var="";
	numgrp4color_resp=0;
	run;
	*The above dataset will add the "Other" group into the &color_resp_grpdsd if the latter does not have the "Other" group;
    data &color_resp_grpdsd;
	set &color_resp_grpdsd _other_dsd_;
	*This is combine majority missing groups as Others;
	if &color_resp_var="." or &color_resp_var="NaN" or &color_resp_var="" then do;
             &color_resp_var="Other"; numgrp4color_resp=0;
    end;
	run;
/*	%abort 255;*/
	*remove duplicate "Other" group if it is true;
	proc sort data=&color_resp_grpdsd nodupkeys;by &color_resp_var;run;
	*Create numeric and char format for the variable &color_resp_var;
	%mkfmt4grps_by_var(
	grpdsd=&color_resp_grpdsd,
	grp_var=&color_resp_var,
	by_var=numgrp4color_resp,
	outfmt4numgrps=x2y4colresp,
	outfmt4chargrps=y2x4colresp,
	dsd4fmt=dsd4fmt
	);
	*Get the numeric group value for the "Other" group;
	proc sql noprint;
	select start into: Other_num_grpval
	from dsd4fmt
	where Label="Other";
/*	%abort 255;*/

	data &bed_dsd;
	set &bed_dsd;
	*format char &color_resp_var to numeric grps;
	num_&color_resp_var=input(&color_resp_var,x2y4colresp.);
	data &bed_dsd(rename=(num_&color_resp_var=&color_resp_var));
	set &bed_dsd(drop=&color_resp_var);
	run;
%end;

%end;

/*%abort 255;*/

%Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&var4label_scatterplot_dots,exist_tag=HasVar1);
%if %length(&HasVar1)=0 %then %do;
 %put The color_resp_var: &var4label_scatterplot_dots does not exist in the sas dsd &bed_dsd;
 %abort 255;
%end;

%if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
 %Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&var4mark_ld_scatterplot_dots,exist_tag=HasLDMarkerVar);
 %if %length(&HasLDMarkerVar)=0 %then %do;
  %put ERROR: LD marker variable &var4mark_ld_scatterplot_dots does not exist in &bed_dsd.;
  %abort 255;
 %end;
%end;

%if %length(&ld_heatmap_var)>0 %then %do;
 %Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&ld_heatmap_var,exist_tag=HasLDHeatmapVar);
 %if %length(&HasLDHeatmapVar)=0 %then %do;
  %put ERROR: LD heatmap variable &ld_heatmap_var does not exist in &bed_dsd.;
  %abort 255;
 %end;
%end;

/*%abort 255; */

*Restrict the min and max positions based on the customized viewmin and viewmax;
%put Going to reset the bed positions between xaxis_viewmin and xaxis_viewmax;
data &bed_dsd;
set &bed_dsd;
%if %length(&xaxis_viewmin)>0 %then %do;
if &st_var <= &xaxis_viewmin and &end_var >= &xaxis_viewmin and &yval_var<0 
then &st_var=&xaxis_viewmin;
if &end_var < &xaxis_viewmin 
then delete;
%end;
%if %length(&xaxis_viewmax)>0 %then %do;
if &end_var >= &xaxis_viewmax and &st_var <= &xaxis_viewmax and &yval_var<0 
then &end_var=&xaxis_viewmax;
if &end_var > &xaxis_viewmax 
then delete;
%end;
run;
/*%abort 255;*/
%if %sysevalf(%length(&xaxis_viewmin)>0 or %length(&xaxis_viewmax)>0) %then %do;
  *Also need to adjust the negative y values;
  *for the genes after exclusion of bed regions by customized axis range;
  proc sql noprint;
  select max(&&yval_var) into: min_neg
  from &bed_dsd
  where &yval_var<0;
  data &bed_dsd;
  set &bed_dsd;
  if &yval_var<0 then &yval_var=&yval_var-&min_neg-1;
  run;
%end;

/* %abort 255; */


*Get the total number of distinct elements of scatter_grp_var;
*if n>5, the macro will not draw dashed reference lines for y-axis;
proc sql noprint;
select count(&scatter_grp_var) into: totsc
from (
select distinct &scatter_grp_var
    from &bed_dsd
);
%if &drawdotintooneline_if_totsc_gt>0 and &totsc>&drawdotintooneline_if_totsc_gt %then %let makeheatmapdotintooneline=1;

%if %eval(&NotDrawScatterPlot=1) %then %do;
   %put The macro will only draw the bottom bed track will will keep negative y values only;
   data &bed_dsd;
   set &bed_dsd;
   where &yval_var<0;
   run;
%end;

*Set default colors for negative and positive beta values in the scatterplot;
%if %length(&scatterdotcols)=0 %then %let scatterdotcols=green yellow;

%if &scatter_grp_var eq %then %do;
  %put Please provide the variable for scatter_grp_var, as it is empty!;
  %abort 255;
%end;
*A new numberic group, ord, is created in descending order;
*Note: it is important to sort the group by yval_var ascendingly;
*as the group order will be used to selected genes or non-gene groups for making scatter plot or gene track;

/* %number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=&yval_var,descending_or_not=0,dsdout=x1); */

*Use bed region distance to sort the dsd in descending order, and the bed region with the largest distance;
*would be the gene body, which will be subjected to draw with tranparent color;
data &bed_dsd;
set &bed_dsd;
dist=&end_var-&st_var+1;
*truncate large values with the threshold maxyvalue4truncat;
if &yval_var>=&maxyvalue4truncat then &yval_var=&maxyvalue4truncat;

%if &NotDrawScatterPlot=1 %then %do;
 *half the negative values to reduce spaces between different rows of genes in the final track;
 if &yval_var<0 then &yval_var=0.5*&yval_var-&offsety;
%end;

run;

/*%debug_macro;*/
*Also asign all heatmap grp with y-axis value as 0.75;
*keep the original y value as colorvalue;  
data &bed_dsd;
set &bed_dsd;

%if %length(&color_resp_var)=0 %then %do;
/*old_y=&yval_var;*/
*Hack this to use lattice_subgrp_var to color scatter plot dots!;
old_y=&lattice_subgrp_var;
%end;
%else %do;
old_y=&color_resp_var;
%end;

%if &makeheatmapdotintooneline=1 %then %do;
%*Change all positive y values into 0.75;
if &yval_var>=0 then &yval_var=&dot_yvalue4heatmap_at_oneline;
%end;

run;

/*%abort 255;*/

%if &sameyaxis4scatter=1 %then %do;
*Add the maximum y values for each scatter group;
*This will enable the scatter plots have the same y axis;
*Enlarge the maxy4scatter by 1 will separate scatterplots better and have the right yaxis for these scatterplots;
   proc sql noprint;select ceil(max(&yval_var))+1 into: maxy4scatter from &bed_dsd;
   proc sort data=&bed_dsd;by &scatter_grp_var;
   data &bed_dsd;
   set &bed_dsd;
   if last.&scatter_grp_var and &yval_var>0 then do;
    output;
    &st_var=.;&end_var=.;&yval_var=&maxy4scatter;
    output;
   end;
   else do;
    output;
   end;
   by &scatter_grp_var;
%end;

%number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=dist,descending_or_not=1,dsdout=x1);

*The final x1 dataset is sorted by grp and yval_var, and a new var ord is created to label;
*each row with number in ascending order by grp;
*The x1 dataset will be splitted into subset dataset by ord;
*The 1st subset dsd will contain all grps with ord=1;
*However, other subset dsds may only contain one of these grps;
*It is important to rescue this by filling the missing grp with values from the 1st subset dsd;

proc sql noprint;
select unique(&chr_var) into: chr_name
from x1;
*remove leading spaces of &chr_name;
%let chr_name=%sysfunc(trim(&chr_name));
%put You chromsome var chr_name has value &chr_name;

*Make fake y axis values by the scatter grp;
*Make sure the &scatter_grp_var have missing values for gene grps;
/*data x1;
set x1;
*Only integer negative values are allowed;
if &yval_var<0 then &yval_var=floor(&pct4neg_y*&yval_var);
run;
*/


*Determine whether there are both positive and negative grp values in the dsd x1;
*If there are no postive grp values, i.e., no grps for scatter plots;
*reasigne mk_fake_axis_with_updated_func=0;
proc sql noprint;
select count(*) into: tot_pos_grps
from x1
where &yval_var>0;

%let crowded_scatter_yaxis_compat=0;
%if &tot_pos_grps=0 %then %do;
 %put There are no positive grp values for the scatter plots;
 %put We will not make fake axis using the updated function;
 %put Instead, default macro make_fake_axis_values4grps will be used to make fake axis values;
 %let mk_fake_axis_with_updated_func=0;
%end;
%else %if &tot_pos_grps>6 %then %do;
 %put NOTE: There are &tot_pos_grps positive scatter groups, so we will keep the richer Neg/Pos fake-axis builder in crowded-axis compatibility mode.;
 %put NOTE: This preserves the older local-GTF behavior that tends to produce more interpretable y-axis labels for many scatter tracks.;
 %let crowded_scatter_yaxis_compat=1;
%end;


*Set scale based on the input value > 1 or < 1;
%if (&pct4neg_y<1) %then %do;
  %let yscale=%sysevalf(1/&pct4neg_y,ceil);
%end;
%else %do;
  %let yscale=%sysevalf(1/%sysevalf(&pct4neg_y,ceil));
%end;


%if %eval(&mk_fake_axis_with_updated_func=1 and &NotDrawScatterPlot=0) %then %do;

%let use_custom_y_ticks=1;
%if %sysevalf(%superq(crowded_scatter_yaxis_compat)=,boolean) %then %let crowded_scatter_yaxis_compat=0;

*This will decide the step value used to draw the final y-axis for the scatter plot;
proc sql noprint;
select max(&yval_var) into: _max_pos_y
from x1;

%let mod_num2keep=2;
%if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(1*&adjval4header);

*When y max value is small, use all integer ticks;
%if &_max_pos_y<7 %then %do;
		 %let mod_num2keep=1;
		 %if &track_height<400 %then %let mod_num2keep=2;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(0.5*&adjval4header);
%end;

*The following contains bugs that would lead to unmatched ticks in the final y-axis;
*If there are too many tick labels genrated from 1 to largest y value, SAS might crash;
*Also when the max value for each scatter plot is too large, the header position for it should be amplified;

%if &_max_pos_y>12 %then %do;
		 %let mod_num2keep=4;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(1.5*&adjval4header);
%end;
%if &_max_pos_y>24 %then %do;
		 %let mod_num2keep=6;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(2*&adjval4header);
%end;
%put _max_pos_y is &_max_pos_y and the mod_num2keep is set as &mod_num2keep!;

*Note that when the scatter max y value is too large, the step value is increased from 2 to 6;
*When the largest value of y-axis is too large, let set yaxis_auto_ticks=1;

/*A workaround method in case of largest y-axis value >10, which does not address the problem;
   To completely solve the issue, enlarge the height for the final output figure!*/
/*%if &_max_pos_y>20 %then %do;*/
/*  %let mod_num2keep=2;*/
/*  %let yaxis_auto_ticks=1;*/
/*%end;*/

%make_fake_axis4NegPosVal_by_grps(
dsdin=x1,
axis_var=&yval_var, 
/*Both negative and positive values of axis var are allowed to use this macro,
but in each group, only positve (>0) or negative (<0) values are allowed,
and all 0 axis var values will be excluded from the dsdin, 
the above of which are the limitations of the macro!*/
axis_grp=&scatter_grp_var, /*although using the same input, this para is different from make_fake_axis_values4grps*/
new_fake_axis_var=&yval_var._new,
dsdout=x1,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=&yscale,
/*Use this fc to enlarge the proportion of positive values in the plots
It seems that fc=2 is the best for the final ticks of different tracks;*/
mod_num2keep=&mod_num2keep /*For the final yaxis_macro_labels, default value for the current var  is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0; 
Note that this will only be applied on numbers that are positve!*/
);
%if %length(&ylabelsmacro_var)=0 %then %do;
	 %put WARNING: The y-axis label macro variable is empty after fake-axis generation.;
   %put WARNING: Falling back to automatic y-axis ticks for this panel.;
   %let use_custom_y_ticks=0;
   %let yaxis_auto_ticks=1;
%end;

%if %length(&ylabelsmacro_var)>256 %then %do;
    *Prevent SAS from crash due to the truncated macro var containing single quote;
	 %put WARNING: The y-axis label macro variable is too long, and SAS might crash!;
   %if &crowded_scatter_yaxis_compat=1 %then %do;
   %put NOTE: Crowded-axis compatibility mode will keep the custom y-axis labels despite their length, matching the older local-GTF macro behavior.;
   %end;
   %else %do;
   %put WARNING: Falling back to automatic y-axis ticks for this panel to avoid unsafe macro expansion.;
   %let use_custom_y_ticks=0;
   %let yaxis_auto_ticks=1;
   %end;
%end;

%put Generated y-axis ticks are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;
%end;
%else %do;

%let use_custom_y_ticks=1;

%make_fake_axis_values4grps(
dsdin=x1,
axis_var=&yval_var,
axis_grp=&scatter_grp_var,
new_fake_axis_var=&yval_var._new,
dsdout=x1,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=&yscale
);

%end;

*The above will expand the y axis positive values by the fc=1/&pct4neg_y;

data x1;
set x1(drop=&yval_var);
rename &yval_var._new=&yval_var;
run;

/***HERE, it was wrong, need to figure out the reason!*/
/*data x1(rename=(&yval_var._new=&yval_var));*/
/*set x1;*/
/**Keep one copy of unchanged yval_var;*/
/*&yval_var._old=&yval_var;*/
/*run;*/
/*%abort 255;*/

*create macro vars for the fake y axis;
*This is just for evaluation, and the macro var fake_y_axis_vals is not used later;
proc sql noprint;
select &yval_var-1 into: fake_y_axis_vals separated by " "
from x1
where &yval_var>0 and grp_end_tag=1;
%put fake y axis values are &fake_y_axis_vals;

*Note: if these added macro vars are empty, it will not affect the data step;
data x1(keep=old_y &Variant_Length_Var &chr_var pos &yval_var &grp_var ord &st_var &end_var &scatter_grp_var &lattice_subgrp_var &var4label_scatterplot_dots &var4mark_ld_scatterplot_dots &ld_heatmap_var);
set x1;
array X{2} &st_var &end_var;
do i=1 to 2;
   pos=X{i};
   *Exclude these CNVs with length >1 in the scatter plot;
   *CNVs will be drawn by highlow plot;
   *if &Variant_Length_Var>1 then pos=.;

   *Failed, as if excluding them, these CNVs can not be labeled on the top of the figure;
   *So just use the middle position of these CNV for labeling purpose;
	if &Variant_Length_Var>1 then pos=0.5*(&st_var+&end_var);
   output;
end;
run;


/*Get max grp number for split data into different dsd*/;
proc sql noprint;
select put(max(ord),best32.),
           put(floor(min(&yval_var)),best32.),
           put(ceil(max(&yval_var)),best32.),
           put(min(&st_var)-&dist2st_and_end,best32.),
           put(max(&end_var)+&dist2st_and_end,best32.) 
       into: max_ord,: min_y,: max_y,: min_x,: max_x
from x1;
%if %eval(&min_x<0) %then %do;
    %let min_x=0;
%end;

*When the makeheatmapdotintooneline=1,the width of the top track would be shorter of 1 unit;
*To rescue this, add the value 1 to the max_y;
%if &makeheatmapdotintooneline=1 or (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0) %then %do; 
  %let max_y=%sysevalf(&max_y+1); 
%end;

*Only keep records with yval_var <0 and the max y value;
*Exlude other data will prevent them from drawing in the bed track;
*These excluded data will be plotted with scatterplot;
data x2;
/* set x1(where=(&yval_var<0 or &yval_var=&max_y)); */
set x1(where=(&yval_var<0));
run;

*Get these unique negative values of y;
proc sql noprint;
select unique(abs(&yval_var)) into: yvals4reflines separated by ' '
from x2;

data tmp;
do i=&min_y to &max_y ;
output;
end;
run;
/*proc print;run;*/
proc sql noprint;
select i into: y_axis_values separated by " "
from tmp;
drop table tmp;
/*%abort 255;*/

*Can not replace negative values with empty, as these axis values are for genes;
*The following codes should be deleted;
/*%let y_axis_values=%sysfunc(prxchange(s/-\d+/ /,-1,&y_axis_values));*/
*Also replace -1.0 and other similar negative values;
*This will remove negative and numbers containing ".5" in the final y-axis ticks;

%put Before modification, the contents of ylabelsmacro_var are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;

%if &yaxis_auto_ticks=0 %then %do;
*Remove all negative nums as well as these positive numbers with decimal;
%let ylabelsmacro_var=%sysfunc(prxchange(s/(\-[\d\.]+|\d+\.\d+|\-.*)/ /,-1,&ylabelsmacro_var));
%let ylabelsmacro_var=%sysfunc(prxchange(s/\.d+/ /,-1,&ylabelsmacro_var));
%end;
%else %do;
*This will only remove negative values that are specific to the bottom gene tracks, and the y-axis of scatter plot will kept as it is;
%let ylabelsmacro_var=%sysfunc(prxchange(s/-[\d\.]+/ /,-1,&ylabelsmacro_var));
%end;

%put Final modified yaxis_auto_ticks are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;


/***********************No need this, as it generates missing group that will be put into the legend
in in the final figure*/
/*data x2;*/
/*set x2;*/
/*%do i=1 %to &max_ord;*/
/*if ord=&i then do;*/
/*  &grp_var.&i=&grp_var;*/
/*  pos&i=pos;*/
/*  &yval_var.&i=&yval_var;*/
/*  output;*/
/*end;*/
/*%end;*/
/*run;*/
/************************************************************************************************/

*Get the grp ord of gene grps;
%put NOTE: LATTICE_STAGE gene_group_ord_query_begin;
proc sql noprint;
select unique(ord) into: genegrp_ords separated by " "
from X2;
select count(unique(&grp_var)) into:tot_genegrps
from X2;
%put NOTE: LATTICE_STAGE gene_group_ord_query_complete genegrp_ords=&genegrp_ords tot_genegrps=&tot_genegrps max_ord=&max_ord;

/*
proc print data=x2;
run;
%abort 255;
*/

******************************************Prepare data for making series and scatter plots************************************************************;
/*Need to fill these missing values with pair of non-missing values,
otherwise, the missing values will be a group that will be included 
in the legend in the final figure*/
*Can not simplify the above process by using &tot_genegrps!;
*Do not use the following loop;
/* %do gi=1 %to &tot_genegrps; */
/* %do gi=1 %to &max_ord; */

%do gi=1 %to %ntokens(&genegrp_ords);
%let _gi_=%scan(&genegrp_ords,&gi,%str( ));
%put NOTE: LATTICE_STAGE gene_track_subset_begin gi=&gi ord=&_gi_;
data _y&gi(keep=ord &grp_var&_gi_ pos&_gi_ &yval_var&_gi_);
*Only keep these y values <0 and the max y value for drawing bed track;
*Excluded data will be plotted via scatter plot;
set x2;
*Important to asign enough length for these grps, which are typical for gene names;
length  &grp_var&_gi_ $30.;
if ord=&_gi_ then do;
  &grp_var&_gi_=&grp_var;
  pos&_gi_=pos;
		label pos&_gi_="%unquote(&xaxis_label)";
  &yval_var&_gi_=&yval_var;
		label &yval_var&_gi_="&yaxis_label";
  output;
end;
*No need this, which only add missing values and makes the dataset too big;
/*else do;*/
   *Missing values will be generated for ord not equal to &_gi_;
  /*grp_var may be numeric or char, 
   just use its original value here,
   will remove it later*/
/*  &grp_var&_gi_=&grp_var;*/
/*  pos&_gi_=.;*/
/*		label pos&_gi_="Position (bp) on chromosome &chr_name";*/
/*  &yval_var&_gi_=.;*/
/*		label &yval_var&_gi_="&yaxis_label";*/
/*  output;*/
/*end;*/
run;
%put NOTE: LATTICE_STAGE gene_track_subset_built gi=&gi ord=&_gi_ ds=_y&gi;


/*proc sort data=_y&_gi_;by &grp_var&_gi_ ord pos&_gi_;*/
/*run;*/

/*get the 1st two records without missing values,
which will be used for fill these missing values later*/
%if %sas_dsd_exist(_y&gi)=0 %then %do;
     %put WARNING: The temporary gene-track dataset _y&gi does not exist, so this subgroup will be skipped.;
%end;
%else %do;
data _y&_gi_._ _y&_gi_._missing;
/*set _y&_gi_;*/
set _y&gi;
if pos&_gi_^=. then output _y&_gi_._;
else output _y&_gi_._missing;
/*create the common var n with values of 1 or 2
for matching with non-missing values from y1_*/
run;
/*%if &_gi_=4 %then %abort 255;*/

*Directly count whether the temporary subgroup keeps any non-missing positions;
*instead of relying on helper macros that may abort on empty inputs.;
%let _ygi_nonmissing=0;
proc sql noprint;
select count(*) into: _ygi_nonmissing trimmed
from _y&_gi_._
where pos&_gi_^=.
;
quit;
%if %sysevalf(%superq(_ygi_nonmissing)=,boolean) %then %let _ygi_nonmissing=0;
%put NOTE: LATTICE_STAGE gene_track_subset_nonmissing_count gi=&gi ord=&_gi_ count=&_ygi_nonmissing;
%let tot_missing=1;
%if %sysevalf(&_ygi_nonmissing>0) %then %do;
%let tot_missing=0;
%end;
%else %do;
%put WARNING: The temporary gene-track dataset _y&_gi_._ has no non-missing positions, so it will be skipped.;
proc datasets lib=work nolist;
delete _y&_gi_._;
quit;
%end;
/*%put &tot_missing;*/
/* %if %sysfunc(exist(work._y&_gi_._)) %then %do; */
%if "&tot_missing" eq "0" and %sysfunc(exist(work._y&_gi_._)) %then %do;
data _y&_gi_._missing;
set _y&_gi_._missing;
if mod(_n_,2)=0 then n=2;
else n=1;
/*Also get the 1st two non-missing values and 
label them with 1 and 2 for matching*/
data _y&_gi_._1;
set _y&_gi_._;
n=_n_;
if _n_<=2;
run;
proc sql;
create table _y&_gi_._filled as
select a.n as n&_gi_, b.*
from _y&_gi_._missing as a,
     _y&_gi_._1 as b
where a.n=b.n;
/*merge y1_filled with y1_*/
data _y&_gi_._final(drop=ord n);
set _y&_gi_._filled(drop=n&_gi_) _y&_gi_._;
run;
%put NOTE: LATTICE_STAGE gene_track_subset_finalized gi=&gi ord=&_gi_;

*better to add the &grp_var1 into other subset dsd, as these subset dsd may missing some genes;
%if 	%eval(&gi>1) %then %do;
proc sql;
create table y1fory&gi as
 select * from _y1_final
  where &grp_var.1 NOT in (select &grp_var.&_gi_ from _y&_gi_._final);

*Manually make all pos1 as _n_ (out of the xaix range);
*leading to no drawing of the y1 region but inclusion of y1 legend in the final series plot;
data y1fory&gi;
set y1fory&gi;
pos1=_n_;
run;
  
proc sql;
create table _y&_gi_._final_ as 
select * from _y&_gi_._final 
union all
select * from y1fory&gi;

*Rename _y&gi._final_ back as _y&gi._final_;
*This is because the _y&gi._final is used by union and can not be replace within the same proc sql;
data _y&_gi_._final;
set _y&_gi_._final_;
*Make values < &min_x as .;
if pos&_gi_ < &min_x then pos&_gi_=.;
run;
%end;

/*The sorting of dataset by gene is important for the coloring in the seriesplot*/
proc sort data=_y&_gi_._final;
by grp&_gi_;
run;
%put NOTE: LATTICE_STAGE gene_track_subset_sorted gi=&gi ord=&_gi_;
%end;
%end;
%end;

%put NOTE: LATTICE_STAGE gene_track_final_merge_begin;
data final;
set
%do ti=1 %to %sysfunc(countw(&genegrp_ords));
%let i=%scan(&genegrp_ords,&ti);
 %if %sysfunc(exist(work._y&i._final)) %then %do;
    _y&i._final
 %end;
%end;
;
%put NOTE: LATTICE_STAGE final_gene_track_merge_complete;

/*
*change the Y6 as other group for debugging;
proc print data=WORK._Y6_FINAL;
run;
%abort 255;
*/

/*
proc print data=final(obs=50);run;
%abort 255;
*/

*Need to keep var4label_scatterplot_dots when  makeheatmapdotintooneline=1;

data final;
*Keep &st_var &end_var for CNV highlowplot if necessary;
merge final x1(where=(&yval_var>=0) keep=old_y &Variant_Length_Var &st_var &end_var pos &yval_var &grp_var &scatter_grp_var &lattice_subgrp_var &var4label_scatterplot_dots &var4mark_ld_scatterplot_dots &ld_heatmap_var);
*Add back these excluded data;
run;
%if %length(&ld_heatmap_var)>0 %then %do;
data final;
set final;
_LD_PLOT_Y_=.;
if not missing(&ld_heatmap_var) then _LD_PLOT_Y_=&yval_var;
run;
%end;
%put NOTE: LATTICE_STAGE positive_signal_merge_complete;
*Asign a specific values for gene with missing value;
proc sql noprint;
select grp1 into: genenames separated by " "
from 
(select unique(grp1)
from final
where grp1^="" and &yval_var.1<0);
%let onegenename=%scan(&genenames,1,%str( ));
%put selected genename for missing value is &onegenename;

*Asign a specific values for non-gene grp with missing value;
proc sql noprint;
select &grp_var into: grpnames separated by " "
from 
(select unique(&grp_var)
from x1
where &yval_var>=0);
%let onegrpname=%scan(&grpnames,1,%str( ));
%put selected grpname for missing value of non-gene group is &onegrpname;
/* %abort 255; */
data final;
set final;
array C{*} _character_;
*The above array may include the var &var4label_scatterplot_dots for labeling users selected dots in scatterplot;
*We need to exclude the var &var4label_scatterplot_dots;
*Need to pay attention to other variables that were character but not included in the gene group variables!;
do ci=1 to dim(C);
   grpname=vname(C{ci});
/*    if grpname^="&var4label_scatterplot_dots" then do; */
/*    The following is better; */
      if prxmatch('/^grp\d+$/',grpname) then do;
			*The &grp_var.1 to &grp_var.&tot_genegrps are for genes, thus they are only needed to be replaced for missing values with genename!;
		       if ci<=&tot_genegrps then do;
                 if C{ci}="" then C{ci}="&onegenename";
				end;
				*For non-gene grps, use non-gene grp name to fill missing grp value;
				*This is not right, need to use gene name to fill all missing subgrps;
				*Because all sub grps &grp_var&i only contain gene or exon bed regions;
				else do;
/* 					if C{ci}="" then C{ci}="&onegrpname"; */
					if C{ci}="" then C{ci}="&onegenename";
				end;
	 end;
end;
/*array N{*} _numeric_;*/
/*Can not asign values to numeric variable with missing values;*/
/* do ni=1 to dim(N); */
/*    if N{ni}=. then N{ni}=.; */
/* end; */
drop ci;
run;
/* %abort 255; */
*prevent missing data draw in the final scatterplot legend;
*Here would be a potential bug if the var lattice_subgrp_var is character;
*Address it by checking var type;
%check_var_type(
dsdin=final,
var_rgx=&lattice_subgrp_var
);
%put lattice_subgrp_var &lattice_subgrp_var variable type is &var_type;
%put NOTE: LATTICE_STAGE lattice_subgrp_type_checked;

%if %length(&lattice_subgrp_var)=0 %then %do;
  %put WARNING: The lattice_subgrp_var is empty. Falling back to scatter_grp_var=&scatter_grp_var.;
  %let lattice_subgrp_var=&scatter_grp_var;
  %check_var_type(
  dsdin=final,
  var_rgx=&lattice_subgrp_var
  );
  %put lattice_subgrp_var fallback variable type is &var_type;
%end;

*For numeric lattice_subgrp_var;
%if %eval(&var_type=1) %then %do;
data _null_;
set final(keep=&lattice_subgrp_var where=(&lattice_subgrp_var^=.));
if _n_=1 then do;
  call symputx('lattice_grp1',&lattice_subgrp_var);
end;
else do;
		stop;
end;
run;

*To rescue the above when not drawing scatterplot, the macro var lattice_grp1 would be missing;
%if (&NotDrawScatterPlot=1) %then %let lattice_grp1=0;

data final;
set final;
if &lattice_subgrp_var=. then &lattice_subgrp_var=&lattice_grp1;
run;
%end;
%else %do;
*For character lattice_subgrp_var;
data _null_;
set final(keep=&lattice_subgrp_var where=(&lattice_subgrp_var^=""));
if _n_=1 then do;
  call symputx('lattice_grp1',&lattice_subgrp_var);
end;
else do;
		stop;
end;
run;
data final;
set final;
if &lattice_subgrp_var="" then &lattice_subgrp_var=&lattice_grp1;
run;

%end;
/*%abort 255;*/

/*
proc print data=final(obs=50);run;
%abort 255;
*/

%if &add_grp_anno=1 %then %do;

***********************************Add grp label for making text identification*******************************;
/*proc print data=final;run;*/

data final(drop=A);
*Ensure the lower gene track name have enough length;
length grp_label $50.;
set final;
*Also need to add grp labels for the first grp, which usually represent genes for all grps;
*It is important to get the lag value of &grp_var.1 here;
*if use the lag function within the if else condition,;
*du to the _n_=1 was passed without of determine the 1st lag value,;
*the output is not as expected.;
A=lag(&grp_var.1);
if _n_=1 then do;
  grp_label=&grp_var.1;
end;
else do;
  if trim(&grp_var.1)^=trim(A) then grp_label=&grp_var.1;
  if pos1=. then grp_label=""; 
end;
*Adjust the y value to make the label about the left a little bit in the gene track;
*shift_text_yval can be negative or positve value;
if &yval_var.1^=. then _y_=&yval_var.1 + (&shift_text_yval*&pct4neg_y);

*adjust pos1 value if the xaxi_viewmin is set up;
%if %length(&xaxis_viewmin)>0 %then %do;
  if pos1<&xaxis_viewmin then pos1=&xaxis_viewmin;
%end;
run;

/*
proc print data=final(obs=50);run;
%abort 255;
*/

%end;


%if %length(&ordered_sc_grpnames)>0 and &NotDrawScatterPlot=0 %then %do;
    *Add a dataset containing scatterplot headers;
    *Note: scatter_grp_var should be in numeric;
    *Also adjust the x-axis position for the group headers;
    proc sql;
    create table header_dsd as
    select distinct 
    &scatter_grp_var as sc_grp, 
    &yval_var+(&adjval4header) as header_yval,avgpos
    from (select *, 
          0.5*(&max_x+&min_x) as avgpos 
          from x1)
    where &scatter_grp_var >0
    group by &scatter_grp_var
    having &yval_var=max(&yval_var);
    *Now get the scatter plot group names;
    %rank4grps(
    grps=&ordered_sc_grpnames,
    dsdout=scgrpnames
    );
    *Note: here all _ included in the name of scatter plot are changed into blank space;
    proc sql;
    create table header_dsd as
    select a.*,prxchange('s/_/ /',-1,b.grps) as header_grp
    from header_dsd as a,
         scgrpnames as b
    where a.sc_grp=b.num_grps;
    quit;

    *Add the header dsd into the final dsd;
    *No need to adjust the avgpos by header length for each header grp;
    *SAS will adjust it automatically with the markercharacterposition=top in proc template;
    *But the code may be useful in adjusting gene labels;
/*     data header_dsd; */
/*     set header_dsd; */
/*     avgpos=avgpos*(1-0.005*(countc(header_grp))); */
/*     run; */
    data final;
    merge final header_dsd;
    run;
    *Get the minimum value of header_yval and the avgpos to fill these missing value after merge with final dsd;
    proc sql noprint;
    select header_yval, avgpos, header_grp 
     into: hd_min,:mid_pos,:hgrp
    from header_dsd
    group by sc_grp
    having sc_grp=min(sc_grp);
    quit;
    data final;
    set final;
    if sc_grp=. then do;
     avgpos=&mid_pos;
     header_yval=&hd_min;
     header_grp="";
    end;
    run;
    /* proc print;run; */
%end;

*Get min and max postive old y value for heatmap;
proc sql noprint;
select floor(min(old_y)),ceil(max(old_y)) into: min_old_y,: max_old_y
from final;
quit;
*To exclude negative old_y in the range of min and max, use the following code;
/*(where=(old_y>=0));*/

*Adjust avgpos for scatter track labels if the xaxis_viewmin and xaxis_viewmax are provided with values;
%let _avg_pos=%sysevalf(0.5*(&max_x+&min_x));
%if (%length(&xaxis_viewmin)>0 and %length(&xaxis_viewmax)>0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&xaxis_viewmin+&xaxis_viewmax));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
%if (%length(&xaxis_viewmin)=0 and %length(&xaxis_viewmax)>0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&min_x+&xaxis_viewmax));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
%if (%length(&xaxis_viewmin)>0 and %length(&xaxis_viewmax)=0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&xaxis_viewmin+&max_x));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
data final;
set final;
avg_pos=&_avg_pos + 0;
*Preallocate label plotting columns during an existing rewrite so the later
 hash update can modify only matching target rows in place.;
newpos=pos;
top_y4label=&max_y;

run;

*De-duplicate repeated labels without dropping a singleton label by row parity.;
*Key only by label text: x1 expands each variant to start/end plotting positions,;
*so a label+position key incorrectly retains the same rsID twice.;
%if %length(&var4label_scatterplot_dots)>0 %then %do;
data final;
  if _n_=1 then do;
    declare hash _seen_target_labels();
    _seen_target_labels.defineKey("&var4label_scatterplot_dots");
    _seen_target_labels.defineData("&var4label_scatterplot_dots");
    _seen_target_labels.defineDone();
  end;
  modify final;
  if &var4label_scatterplot_dots^="" and pos^=. then do;
    if _seen_target_labels.check()=0 then &var4label_scatterplot_dots="";
    else _seen_target_labels.add();
  end;
  replace;
run;
%end;


*Transform data to label selected dots only once if multiple satterplots containing the same label;
%if (%length(&var4label_scatterplot_dots)>0 and &label_dots_once_on_top=1 and &NotDrawScatterPlot=0) %then %do;
    %put NOTE: LATTICE_STAGE top_label_transform_begin;
    data _xtag_;
    set final;
    xtag=_n_;
    _tmp_=_n_;
    where &var4label_scatterplot_dots^="" and pos^=.;
    keep &var4label_scatterplot_dots xtag _tmp_ pos;
    run;

    *Collapse repeated label rows before any spacing adjustment so a SNP that;
    *appears in multiple tracks is treated as one top label with one position.;
    proc sort data=_xtag_;
    by &var4label_scatterplot_dots pos _tmp_;
    run;

    data _xtag_;
    set _xtag_;
    by &var4label_scatterplot_dots;
    if first.&var4label_scatterplot_dots;
    run;
    proc sql noprint;
	select count(*) into: total_target_labels
	from (
	select distinct &var4label_scatterplot_dots 
    from _xtag_
    ); 
  %let effective_font_size4textlabels=&font_size4textlabels;
  %let effective_yoffset4textlabels=&Yoffset4textlabels;

  *When there is less then 4 SNPs for labeling at the top of the local Manhattan plot, reset the following rotation angle macro var to 0;
  *and increase 4 fold for the the dist_pct_to_cluster_pos;
  *First decide the cutoff of total_target_labels based on the width of figure;
 %if &track_width <= 500 %then %do;
     %let label_n_cutoff=3;
%end;
%else %if (&track_width>500 and  &track_width<800) %then %do;
     %let label_n_cutoff=4;
%end;
%else %if (&track_width>=800) %then %do;
    %let label_n_cutoff=5;
%end;
%else %do;
    %let label_n_cutoff=0;
%end;

  %if &total_target_labels=0 %then %do;
      %put WARNING: No requested SNP labels remain in the local GWAS plot data.;
      %let make_even_pos=0;
  %end;
  %else %if &total_target_labels<=&label_n_cutoff %then %do;
/*	   %let dist_pct_to_cluster_pos=%sysevalf(4*&dist_pct_to_cluster_pos);*/
/*       %let dist_pct_to_cluster_pos=%sysevalf(1/&total_target_labels);*/
         %let dist_pct_to_cluster_pos=%sysevalf(0.5/&total_target_labels);
/*	   %let  fc2distant_close_labels=%sysevalf(4*&fc2distant_close_labels);*/
	   %let make_even_pos=0;
  %end;
  %else %do;
	  %let make_even_pos=1;
	  *No need to make even positions when rotation angle is set as 90;
	  %if &text_rotate_angle=90 %then %let make_even_pos=0;
  %end;

  *Horizontal top labels need more aggressive spacing control than vertical labels.;
  %if (&text_rotate_angle=0) %then %do;
      %if &total_target_labels>=3 %then %let make_even_pos=1;
      %if &total_target_labels>=3 %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,3.0));
      %if &total_target_labels>=4 %then %do;
          %let fc2distant_close_labels=%sysfunc(max(&fc2distant_close_labels,5));
          %let pct2adj4dencluster=%sysfunc(max(&pct2adj4dencluster,3));
          %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,9));
          %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,3.6));
      %end;
      %if &total_target_labels>=5 %then %do;
          %let fc2distant_close_labels=%sysfunc(max(&fc2distant_close_labels,6));
          %let pct2adj4dencluster=%sysfunc(max(&pct2adj4dencluster,4));
          %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
          %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.2));
      %end;
      %if &track_width<700 and &total_target_labels>=4 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
      %if &track_width<500 and &total_target_labels>=3 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,7));
  %end;
  %else %if (&text_rotate_angle>=60) %then %do;
      %if &total_target_labels>=5 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,9));
      %if &total_target_labels>=7 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
      %if &total_target_labels>=5 %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,2.0));
  %end;

   *Also need to adjust labels with too close positions;
  %if &track_width<700 %then %let Pct4OnlyTwoPos=0.25;
  %else %let Pct4OnlyTwoPos=0.1;

  %if (&adj_spaces_among_top_snps=1 and &total_target_labels>=2) %then %do;
   %adjust_close_positions(
   indsd=_xtag_,
   outdsd=_xtag_,
   pos_var=pos,
   new_pos_var=newpos,
   dist_pct_to_cluster_pos=&dist_pct_to_cluster_pos,
   amplification_fc=&fc2distant_close_labels,
   make_even_pos=&make_even_pos,
   Pct4OnlyTwoPos=&Pct4OnlyTwoPos,/*In case of only two positions, it is necessary to use arbitrary proportion of dist_step to separate them,
   i.e., minus and add Pct4OnlyTwoPos*dist_step and for the first and second positions, respectively*/
   pct2adj4dencluster=&pct2adj4dencluster,
   fixed_min_pos=&min_x,
   fixed_max_pos=&max_x
   ); 
   %end;
   %else %do;
	 data _xtag_;
	 set _xtag_;
	 newpos=pos;
	 run;
   %end;
   *The above macro is not good in separating these positions into distinguishable positions;
   *However, due to historical compatability, the above codes will be kept;
   *******************************************************************************************************;
   *Use the other macro to improve it, and it can be canceled if it is still not optimum;
   *Only run it when requiring the text to be rotated; 
   %if (&text_rotate_angle>0 and &adj_spaces_among_top_snps=1 and &total_target_labels>=2) %then %do;
   %put We will further optimize the space between each SNP label on the top of the gene track;
   proc sql noprint;
   select pos into: _tgt_pos_ separated by ' '
   from _xtag_ 
   order by pos;
   select &fc2distant_close_labels*0.1*(&max_x-&min_x+1)/count(*) into: sep4tgt_pos
   from _xtag_;
   %spaceAdjust(data=&_tgt_pos_, out=_xtag1_, goal=COL:, sep=&sep4tgt_pos, newvar4adjnum=newpos); 
   /* _xtag1_ follows genomic-position order, so align rows before merging. */
   proc sort data=_xtag_;
   by pos;
   run;
   data _xtag_;
   merge _xtag_(drop=newpos) _xtag1_(keep=newpos);
   run;
   %end;
   /* Preserve the planner's label centers after the legacy SAS spacing pass.
      Only label coordinates change; GWAS marker and LD positions stay intact. */
   %if %length(%superq(label_position_overrides))>0 %then %do;
   data _xtag_;
   set _xtag_;
   length _planned_token $256 _planned_snp $128;
   do _planned_i=1 to countw(symget('label_position_overrides'), ' ');
      _planned_token=scan(symget('label_position_overrides'), _planned_i, ' ');
      _planned_snp=scan(_planned_token, 1, '=');
      if upcase(strip(&var4label_scatterplot_dots))=upcase(_planned_snp) then do;
         _planned_bp=input(scan(_planned_token, 2, '='), best32.);
         if not missing(_planned_bp) then newpos=_planned_bp;
         leave;
      end;
   end;
   drop _planned_token _planned_snp _planned_i _planned_bp;
   run;
   %end;
/*   %abort 255;*/
 
   *******************************************************************************************************;
     proc sort data=_xtag_;
     by &var4label_scatterplot_dots pos;
     run;

     data _xtag_;
     set _xtag_;
     by &var4label_scatterplot_dots;
     if first.&var4label_scatterplot_dots;
     run;

     /*
       _xtag_ contains only the requested label rows.  Update their adjusted
       x positions directly in FINAL with a hash lookup.  The former
       CREATE TABLE FINAL AS SELECT ... FROM FINAL required a second complete
       438-column table plus SQL utility space and could disconnect SAS ODA
       when WORK filled.
     */
     data final;
       if _n_=1 then do;
         declare hash _label_positions(
           dataset:"_xtag_(keep=&var4label_scatterplot_dots pos newpos)",
           duplicate:"r"
         );
         _label_positions.defineKey("&var4label_scatterplot_dots", "pos");
         _label_positions.defineData("newpos");
         _label_positions.defineDone();
       end;
       modify final;
       if &var4label_scatterplot_dots^="" and pos^=. then do;
         if _label_positions.find()=0 then &lattice_subgrp_var=0;
       end;
       label top_y4label="&yaxis_label";
       replace;
     run;
   *Need to enlarge the macro var yaxis_offset4max to be 0.1;
   %let yaxis_offset4max=&yoffset4max_drawmarkersontop;
   *Get the positions of these selected markers for making vertical reflines later;
   *Note: it is important to use put to change larger number into str frist;
   *otherwise, sas will automatically round the large number to nearest number;
   *resulting into the wrong number for the newly created macro var markers_pos;
   %let markers_pos=;
   %let new_markers_pos=;
   proc sql noprint;
   select put(pos,best32.),put(newpos,best32.) into: markers_pos separated by ' ',:new_markers_pos separated by ' '
   from _xtag_;
   select count(*) into: n_marker_labels trimmed
   from _xtag_;
   select max(lengthn(strip(&var4label_scatterplot_dots)))
     into: _max_marker_label_chars trimmed
   from _xtag_;
   
   %put Your marker positions are as follows:;
   %put &markers_pos;
   %put Total marker labels requested on the top are: &n_marker_labels;

%if %sysevalf(%superq(n_marker_labels)=,boolean) %then %let n_marker_labels=0;
%if %sysevalf(%superq(_max_marker_label_chars)=,boolean) %then %let _max_marker_label_chars=0;
   %let _scatter_track_count=&totsc;
   %if %sysevalf(%superq(_scatter_track_count)=,boolean) %then %let _scatter_track_count=1;
   %if %sysevalf(&_scatter_track_count<1) %then %let _scatter_track_count=1;
   %let _scatter_y_span=%sysevalf(&max_y-&min_y+0.2);
   %if %sysevalf(&_scatter_y_span<=0) %then %let _scatter_y_span=%sysevalf(&max_y+0.2);
   %if %sysevalf(&_scatter_y_span<=0) %then %let _scatter_y_span=1;
   %let _avg_signal_span_per_track=%sysevalf(&_scatter_y_span/&_scatter_track_count);
   %let _yoffset_scale_fc=1;
   %if %sysevalf(&_avg_signal_span_per_track>4.5) %then %let _yoffset_scale_fc=%sysevalf(1+(&_avg_signal_span_per_track-4.5)*0.08);
   %else %if %sysevalf(&_avg_signal_span_per_track<3.0) %then %let _yoffset_scale_fc=%sysevalf(1-(3.0-&_avg_signal_span_per_track)*0.06);
   %if %sysevalf(&_yoffset_scale_fc<0.85) %then %let _yoffset_scale_fc=0.85;
   %if %sysevalf(&_yoffset_scale_fc>1.35) %then %let _yoffset_scale_fc=1.35;
   %let _recommended_yaxis_offset4max=&yaxis_offset4max;

   %if %sysevalf(&n_marker_labels>=1) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.08));
   %if (&text_rotate_angle=0 and %sysevalf(&n_marker_labels>=1)) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.09));
   %if %sysevalf(&n_marker_labels>=2) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.1));

/*    %if %sysevalf(&totsc>3) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&totsc>5) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.04); */
/*    %if %sysevalf(&totsc>8) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.05); */

/*    %if %sysevalf(&track_height<700) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&track_height<550) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.05); */
/*    %if %sysevalf(&track_height<420) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.07); */

/*    %if %sysevalf(&track_width<900) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.02); */
/*    %if %sysevalf(&track_width<700) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&track_width<500) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.04); */

   %if %sysevalf(&_recommended_yaxis_offset4max>0.95) %then %let _recommended_yaxis_offset4max=0.95;
   %if %sysevalf(&_recommended_yaxis_offset4max>&yaxis_offset4max) %then %do;
      %put NOTE: Auto-increasing yaxis_offset4max from &yaxis_offset4max to &_recommended_yaxis_offset4max to reserve more top space for SNP labels.;
      %let yaxis_offset4max=&_recommended_yaxis_offset4max;
   %end;

   %if (&text_rotate_angle=0 and &n_marker_labels>=4) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.0));
   %if (&text_rotate_angle=0 and &n_marker_labels>=5) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.6));
   %if (&text_rotate_angle>=60 and &n_marker_labels>=5) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,2.2));

   *Make the top SNP label offset less sensitive to the absolute y-axis range by
   *scaling it with the observed signal span per scatter track. This keeps the
   *visual gap more stable when tracks get taller or the max -log10(P) changes.;
   %if %sysevalf(&n_marker_labels<=3) %then %do;
      %let effective_yoffset4textlabels=%sysevalf(&effective_yoffset4textlabels*&_yoffset_scale_fc);
      %if (&text_rotate_angle=0) %then %do;
         %if %sysevalf(&effective_yoffset4textlabels<0.18) %then %let effective_yoffset4textlabels=0.18;
         %if %sysevalf(&effective_yoffset4textlabels>0.90) %then %let effective_yoffset4textlabels=0.90;
      %end;
      %else %do;
         %if %sysevalf(&effective_yoffset4textlabels<0.80) %then %let effective_yoffset4textlabels=0.80;
         %if %sysevalf(&effective_yoffset4textlabels>2.80) %then %let effective_yoffset4textlabels=2.80;
      %end;
   %end;

   *Convert the needed label headroom into the raw yaxis_offset4max scale used
   *later by GTL so the reserved top region stays close to the label height.;
   *this is the key part to make the top label headroom more adaptive to the signal span and track height, thus more robust to different y-axis ranges and figure sizes.;
   *For running the code with AI, AI should be able to understand the logic of the following code;
   *and adjust the parameters and formula as needed to achieve the desired visible fraction of top labels, which is determined by the effective font size of text labels and the track height, as well as other factors such as text rotation angle, number of marker labels, average signal span per track, and figure size. The goal is to make the top label headroom more adaptive and robust to different scenarios.;
   %let _desired_visible_top_frac=%sysevalf((&effective_font_size4textlabels+1)/&track_height);
   %if (&text_rotate_angle=0) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac*1.15);
   %else %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac*0.95);
   %if %sysevalf(&n_marker_labels>1) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.0025*(&n_marker_labels-1));
   %if %sysevalf(&_avg_signal_span_per_track>5.5) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.002);
   %if %sysevalf(&_avg_signal_span_per_track<3.0) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac-0.0015);
   %if %sysevalf(&track_height<500) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.002);
   %if %sysevalf(&n_marker_labels=1) %then %do;
      %if %sysevalf(&_desired_visible_top_frac<0.02) %then %let _desired_visible_top_frac=0.02;
      %if %sysevalf(&_desired_visible_top_frac>0.02) %then %let _desired_visible_top_frac=0.02;
   %end;
   %else %do;
      %if %sysevalf(&_desired_visible_top_frac<0.02) %then %let _desired_visible_top_frac=0.02;
      %if %sysevalf(&_desired_visible_top_frac>0.040) %then %let _desired_visible_top_frac=0.040;
   %end;

   %let _auto_yaxis_offset4max=&_desired_visible_top_frac;
   %if %sysevalf(&_scatter_track_count>5) %then %let _auto_yaxis_offset4max=%sysevalf(&_desired_visible_top_frac*&_scatter_track_count/5);
   %if %sysevalf(&_auto_yaxis_offset4max<0.02) %then %let _auto_yaxis_offset4max=0.02;
   %if %sysevalf(&_auto_yaxis_offset4max>0.25) %then %let _auto_yaxis_offset4max=0.25;
   %if %sysevalf(&n_marker_labels<=2) %then %do;
      %if %sysevalf(&_auto_yaxis_offset4max^=&yaxis_offset4max) %then %do;
         %put NOTE: Replacing yaxis_offset4max=&yaxis_offset4max with scale-aware top-label offset &_auto_yaxis_offset4max (visible frac=&_desired_visible_top_frac, tracks=&_scatter_track_count, avg_signal_span=&_avg_signal_span_per_track).;
         %let yaxis_offset4max=&_auto_yaxis_offset4max;
      %end;
   %end;
   %else %if %sysevalf(&_auto_yaxis_offset4max>&yaxis_offset4max) %then %do;
      %put NOTE: Auto-increasing yaxis_offset4max from &yaxis_offset4max to &_auto_yaxis_offset4max with scale-aware top-label headroom (visible frac=&_desired_visible_top_frac).;
      %let yaxis_offset4max=&_auto_yaxis_offset4max;
   %end;

   /* Fit vertical labels to the longest requested marker. Font size is in
      points while track_height is a layout dimension; raster DPI must not
      change the fraction of the plot reserved for a label. */
   %if (&text_rotate_angle>=60 and &n_marker_labels>=1) %then %do;
      %let _vertical_label_frac=%sysevalf(((&_max_marker_label_chars*0.62+1)*&effective_font_size4textlabels*96/72+2*&effective_yoffset4textlabels+8)/(&track_height*0.75));
      %if %sysevalf(&_vertical_label_frac<0.04) %then %let _vertical_label_frac=0.04;
      %if %sysevalf(&_vertical_label_frac>0.45) %then %let _vertical_label_frac=0.45;
      %let yaxis_offset4max=&_vertical_label_frac;
      %put NOTE: Vertical SNP-label headroom fitted to &_max_marker_label_chars characters: offsetmax=&yaxis_offset4max.;
   %end;

   %put NOTE: Effective top-label settings: rotate=&text_rotate_angle font_size=&effective_font_size4textlabels yoffset=&effective_yoffset4textlabels yaxis_offset4max=&yaxis_offset4max avg_signal_span_per_track=&_avg_signal_span_per_track fc2distant_close_labels=&fc2distant_close_labels pct2adj4dencluster=&pct2adj4dencluster make_even_pos=&make_even_pos.;
    
%end;
%put NOTE: LATTICE_STAGE top_label_transform_complete;

*For debug;
/*data a;*/
/*set _xtag_;*/
/*run;*/
/*%abort 255;*/


*Select line pattern for highlighting markers labeled on the the top of scatterplots;
*Solid, ShortDash, MediumDash, LongDash,MediumDashShortDash, DashDashDot;
*DashDotDot, Dash, LongDashShortDash, Dot, ThinDot, ShortDashDot, MediumDashDotDot;
*or numbers from 1 (solid) to 46 which are many combinations of dashes,;
*dots, lengths and numbers of dashes, numbers and sizes of dots.;
%let reflinepattern=Dot;

*Also add the marker ids into the output figure name;
%let  vars4figurename=;
%if %length(&var4label_scatterplot_dots)>0 %then %do;
proc sql noprint;
select distinct trim(left(&var4label_scatterplot_dots)) into: vars4figurename separated by '_'
from final
where &var4label_scatterplot_dots^="";

%if %length(&vars4figurename)>100 %then %do;
   %put You var4figurename is too long:;
   %put &var4figurename;
   %put The macro will arbitrarily assign the value of macro var var4label_scatterplot for the macro var;
   %let  vars4figurename=&var4label_scatterplot_dots;
%end;

*When there are three or fewer SNPs for labeling at the top, keep those labels horizontal in the top headroom;
*Also reduce the top cell space represented by the macro var yoffset4max_drawmarkersontop from the default value 0.15 to 0.05;
*Other parameters restrict the upper and lower offset are also resetted;
%if %sysevalf(&n_marker_labels>=1) and %sysevalf(&n_marker_labels<=3) and &auto_rotate2zero=1 %then %do;
    %let text_rotate_angle=0;

/*	%let yoffset4max_drawmarkersontop=0.01;*/
	/*Setting this as 0 does not change the figure, so this parameter is not needed to be reset!*/
	/*Use the simpler horizontal-label scaling for small label sets so <=3 SNPs
      stay readable on one line within the reserved headroom. */
	%let effective_yoffset4textlabels=%sysevalf(0.55*1000/&track_height);
	%if &track_height<400 %then %let effective_yoffset4textlabels=0.55;
	%let yaxis_offset4max=%sysevalf(0.04*500/&track_height);
	%let yaxis_offset4min=%sysevalf(0.02*500/&track_height);/*This will reduce the lower offset of y-axis*/
    %put NOTE: Small top-label horizontal tuning: n_marker_labels=&n_marker_labels yaxis_offset4max=&yaxis_offset4max yaxis_offset4min=&yaxis_offset4min effective_yoffset4textlabels=&effective_yoffset4textlabels track_height=&track_height.;
%end;
%if %length(%superq(label_headroom_frac))>0 and %length(%superq(label_center_offset))>0 %then %do;
    %let yaxis_offset4max=&label_headroom_frac;
    %let effective_yoffset4textlabels=&label_center_offset;
    %put NOTE: Planned top-label headroom=&yaxis_offset4max center_offset=&effective_yoffset4textlabels.;
%end;
%end;

 *In terms of gene labels in the gene track, if a gene is too close to the right most position in the figure;
*It is necessary to move the gene label position to left to prevent the gene label is truncated in the figure;
%if (%length(&xaxis_viewmax)>0 and %length(&xaxis_viewmin)>0) %then %do;
     %let window_dist=%sysevalf(&xaxis_viewmax - &xaxis_viewmin + 1);
	 %let _maxpos_=&xaxis_viewmax;
%end;
%else %do;
     %let window_dist=%sysevalf(&max_x - &min_x + 1);
	 %let _maxpos_=&max_x;
%end;

*********************************************SAS codes to adjust gene label positions, preventing them too close to each other*********************;
/*proc sql noprint;*/
/*select max(pos1), min(pos1)into: max_pos1, :min_pos1*/
/*from final;*/
%if &track_width>=500 %then %let extra_reduce_pct=0.8;
%else %let extra_reduce_pct=1;
*This means for figure with width < 500, it will increase the 1 fold for the amplification facto;
*but for figure with width > 500 and < 750, it will keep around 0.8 fold for the amplification facto;
*in terms of figure with width >750, it will keep around 0.8*0.5 fold for the amplification factor;
data final ;
set final;
pfactor=IFC(length(grp_label)<3,0,length(grp_label))/4;
if pfactor>5 then pfactor=5;
*Further adjust it by figure track_width by comparing it to the optimized figure with width 450;
pfactor=pfactor*500/&track_width;
*If track_width>600, it is necessary to reduce the factor 2 folder;
if &track_width>750 then pfactor=0.5*pfactor;
if grp_label^="" and (&_maxpos_ - pos1+1)/&window_dist<((1+pfactor)*&move_right_genetxt_pct) then do;
      *Also move the gene label by its length;
	   _pos1_=pos1-&extra_reduce_pct*&window_dist*&move_right_genetxt_pct*pfactor;
end;
else do;
	  _pos1_=pos1;
end;
run; 
/*%abort 255;*/

*This only works for making gene bed scatter plots with the yval_var, which is log10P;
%Check_VarnamesInDsd(indsd=final,Rgx=&yval_var.1,exist_tag=Hasvar4y);
%if %length(&Hasvar4y)>0 %then %do;
*Further adjust the gene lable x-axis positions if two gene labels are in the same row and have distance less than designated pct of the whole window;
%put NOTE: LATTICE_STAGE gene_label_adjust_begin;
*Further adjust the gene lable x-axis positions if two gene labels are in the same row and have distance less than designated pct of the whole window;
data final_gene;
set final(keep=grp_label grp1 &yval_var.1 _pos1_ pfactor);
where grp_label^="";
run;
proc sort;by &yval_var.1 _pos1_;run;

data final_gene;
set final_gene;
lag_pos1=lag(_pos1_);
if first.&yval_var.1 then do;
 lag_pos1=.;
end;
else do;
   if  (_pos1_ - lag_pos1+1)/&window_dist<(pfactor*&move_right_genetxt_pct)  then lag_pos1_adj=lag_pos1-&extra_reduce_pct*&window_dist*&move_right_genetxt_pct*pfactor;
end;
by &yval_var.1;
run;
*Update only affected gene-label positions in place.  This avoids recreating
 the full FINAL table through a self-referential PROC SQL join.;
data final_gene_lookup;
  set final_gene(keep=&yval_var.1 lag_pos1 lag_pos1_adj);
  where lag_pos1^=. and lag_pos1_adj^=.;
  _pos1_=lag_pos1;
  *Reuse PFActor, which already exists in FINAL, as the hash return slot.  A
   MODIFY step cannot enlarge an existing observation with a new variable.;
  pfactor=lag_pos1_adj;
  keep &yval_var.1 _pos1_ pfactor;
run;

data final;
  if _n_=1 then do;
    declare hash _gene_positions(dataset:"final_gene_lookup", duplicate:"r");
    _gene_positions.defineKey("&yval_var.1", "_pos1_");
    _gene_positions.defineData("pfactor");
    _gene_positions.defineDone();
  end;
  modify final;
  pfactor=.;
  if _gene_positions.find()=0 and pfactor^=. then _pos1_=pfactor;
  replace;
run;

proc datasets library=work nolist;
  delete final_gene final_gene_lookup;
quit;
%end;
%put NOTE: LATTICE_STAGE gene_label_adjust_complete;

*Need to obtain the minimum and maximum values to decide whether all of values of heatmap_var are postive or negative;
%let min_heatmap_var=-999;
%let max_heatmap_var=999;
%if &makedotheatmap=1 and %length(&heatmap_var)>0 %then %do;
  %put NOTE: LATTICE_STAGE heatmap_normalize_begin;
  proc sql noprint;
  select min(%unquote(&heatmap_var)) into: min_heatmap_var
  from final;
  select max(%unquote(&heatmap_var)) into: max_heatmap_var
  from final;

  data final;
  set final;
  *Reset all values <heatmap_min_neg_val or >heatmap_max_pos_val to be heatmap_min_neg_val or heatmap_max_pos_val, specifically;
 %if %sysevalf(&heatmap_min_neg_val>&min_heatmap_var) and %sysevalf(&min_heatmap_var<0) %then %do;
    %let min_heatmap_var=&heatmap_min_neg_val;
	if &heatmap_var<&heatmap_min_neg_val then &heatmap_var=&heatmap_min_neg_val;
 %end;
  %if %sysevalf(&heatmap_max_pos_val<&max_heatmap_var) and %sysevalf(&max_heatmap_var>0) %then %do;
      %let max_heatmap_var=&heatmap_max_pos_val;
	if &heatmap_var>&heatmap_max_pos_val then &heatmap_var=&heatmap_max_pos_val;
 %end;
  run;
%end;
%put NOTE: LATTICE_STAGE heatmap_normalize_complete;


/* This relabels the variable newpos as Position in the final figure. */
data final;
set final;
*Update the x-axis label, which might be revised if the macro is not used for drawing GWAS local Manhattan plot;
/* label newpos="%trim(%left(%sysfunc(prxchange(s/^chr/Chromosome /,1,&chr_name)))) (hg19)"; */
label newpos="%trim(%left(%sysfunc(prxchange(s/^chr/Chromosome /,1,&chr_name))))";
*This will remove the legend in the figure for dots that are with missing value of old_y;
*The value 1 would be used as group number to match with its corresponding char label in the figure legend;
/*if old_y=. then old_y=&Other_num_grpval;*/
*The above fails to exclude groups with missing numeric group value;
*keeping these old_y as missing would exclude them in the final figure legend; 
*The following code is just for reminding of the above fact;
%if %length(&Other_num_grpval)>0 %then %do;
if old_y=. then old_y=&Other_num_grpval;
*it is necessary to re-assign missing value to these old_y when the &yval_var is missing;
if &yval_var=. then old_y=.;
%end;
run;

*Only draw CNVs in highlow plots based on their length>1;
data final;
set final;
if not (&Variant_Length_Var>1) then do;
 &st_var=.;&end_var=.;
end;
run;
*If end_var are all missing, it means there are no CNVs for running the highlow plot;
%iscolallmissing(dsd=final,colvar=&end_var,outmacrovar=NoCNVs);

****************************************End of SAS codes to adjust gene label positions, preventing them too close to each other***************;

*****************************************************************************************************************;
/*
proc export data=final outfile="final.txt" dbms=tab replace;
run;
*/

*documentation for adjusting axis for layout overlay;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatug/p1pqfzgbuzbpkzn1mrbzhgggvhkz.htm;
*see line dash pattern here:;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0er4dg9tojp05n1sf7maeqdz1d8.htm;
proc template;
define statgraph Bedgraph;
dynamic _chr _pos _value _G;
begingraph / designwidth=&track_width designheight=&track_height
       %*Use customized colors;
       %if %length(&dataContrastCols)>0 %then %do;
             dataContrastColors=( &dataContrastCols )  ATTRPRIORITY=color
        %end;
        ;
 %if %length(%superq(plot_title))>0 %then %do;
   entrytitle "&plot_title";
 %end;
 
 /*Define colors for dots by group in the scatter plot*/
 %if &lattice_subgrp_var ne %then %do;     
      discreteattrmap name="dotgrpname" / ignorecase=true;
        /*If the symbol is used in the scatterplot statment, the following symbol specification will be overwritten!*/
        value "Neg" /
          markerattrs=GraphData1(color=%scan(&scatterdotcols,1,%str( )) symbol=circlefilled)
          lineattrs=GraphData1(color=red pattern=solid);
        value "Pos" /
          markerattrs=GraphData2(color=%scan(&scatterdotcols,2,%str( )) symbol=trianglefilled)
          lineattrs=GraphData2(color=green pattern=shortdash);   
      enddiscreteattrmap;
      /*The attrvar and var have the same variable name here!*/
      discreteattrvar attrvar=&lattice_subgrp_var var=&lattice_subgrp_var
        attrmap="dotgrpname";
   %end;
 
   /*When the following condition is true, the above discreteattrmap "dotgrpname" will be replaced with a new rangeattrmap!*/
   %if &makedotheatmap=1 and %length(&heatmap_var)=0 %then %do;
    /*Define colors for dots by group in the heatmap plot*/
      rangeattrmap name="dotheatmap";
         range &min_old_y - &max_old_y / 
         rangeAltColorModel=(CXFFFFB2 CXFED976 CXFEB24C CXFD8D3C CXFC4E2A CXE31A1C CXB10026);
         range OTHER / rangeAltColor=black;
         range MISSING / rangeAltColor=Lime;
       endrangeattrmap;
      /*The attrvar and var have the same variable name here!*/
      rangeattrvar attrvar=old_y_attrvar var=old_y
        attrmap="dotheatmap";
   
   %end;

    %if &makedotheatmap=1 and %length(&heatmap_var)>0 %then %do;
      /*Define colors for dots by group in the heatmap plot*/
      rangeattrmap name="dotheatmap";
		%if %sysevalf(&min_heatmap_var <=0) and %sysevalf(&max_heatmap_var>0) %then %do;
         range &heatmap_min_neg_val  - 0    / rangealtcolormodel=(&heatmap_Neg_rangealtcolormodel);
         range 0 - &heatmap_max_pos_val / rangealtcolormodel=(&heatmap_Pos_rangealtcolormodel) ;
		%end;
		%else %if (%sysevalf(&min_heatmap_var >= 0) and %sysevalf(&max_heatmap_var>0)) %then %do;
         range 0 - &heatmap_max_pos_val / rangealtcolormodel=(&heatmap_Pos_rangealtcolormodel) ;
		%end;
		%else %if (%sysevalf(&min_heatmap_var <0) and %sysevalf(&max_heatmap_var<=0)) %then %do;
         range &heatmap_min_neg_val  - 0    / rangealtcolormodel=(&heatmap_Neg_rangealtcolormodel);
		%end;
		%else %do;
			%put You minimum color response variable is %left(%trim(&min_heatmap_var)) and maximum value for the variable is %left(%trim(&max_heatmap_var));
			%put They are not both postive and negative or either postive or negative;
			%put WARNING: Falling back to the non-heatmap scatter coloring mode for this panel.;
      %let makedotheatmap=0;
		%end;

         range OTHER / rangeAltColor=black;
         range MISSING / rangeAltColor=Lime;

       endrangeattrmap;
      /*The attrvar and var have the same variable name here!*/
      rangeattrvar attrvar=heatmap_var_attrvar var=%unquote(&heatmap_var)
        attrmap="dotheatmap";

	%end;

    %if %length(&ld_heatmap_var)>0 %then %do;
      rangeattrmap name="ldheatmap";
        range 0 - 1 / rangealtcolormodel=(&ld_heatmap_colormodel);
        range OTHER / rangealtcolor=gray;
        range MISSING / rangealtcolor=white;
      endrangeattrmap;
      rangeattrvar attrvar=ld_r2_attrvar var=&ld_heatmap_var attrmap="ldheatmap";
    %end;

   %if "&color_resp_vartype"="C" and &makedotheatmap=0 %then %do;
	    discreteattrmap name="dotgrpname" / ignorecase=true;
        /*If the symbol is used in the scatterplot statment, the following symbol specification will be overwritten!*/
       enddiscreteattrmap;
      /*The attrvar and var have the same variable name here!*/
       discreteattrvar attrvar=old_y_attr_var var=old_y
        attrmap="dotgrpname";
   %end;
        
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10 ;
         /*the offsetmin and offsetmax affect the offset area for y axis;*/
       *The adding of walldisplay=none will remove yaxis and other borders, but the yaxis should be kept;
/*         layout overlay/WALLDISPLAY=none yaxisopts=(*/
	       *Note: the label option will be the real functional section to update the yaxis label;
	       *Keep the requested y-axis title visible for both standard scatter and heatmap local-GTF panels;
          layout overlay/yaxisopts=(label="&yaxis_label"	
 /*                     only provide tickvalues will prevent other features, such as ticks, in the yaxis            */
/*                      need to add label to display y label; also remove ticks when makeheatmapdotintooneline=1   */
                        display=(%if &makeheatmapdotintooneline=0 %then %do; 
                                   tickvalues
                                 %end;
                                   label)
 /*                     type=linear offsetmin=0.05 offsetmax=0.05     */
                    %if &totsc>20 %then %do;
/*                         type=linear offsetmin=%sysevalf(&yaxis_offset4min*&totsc/200)  */
/*                         offsetmax=%sysevalf(&yaxis_offset4max*&totsc/200) */
/*                      The offset min and max will affect the upper and lower parts of the tracks   */
                        offsetmin=%sysevalf(&yaxis_offset4min*20/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*20/&totsc)
						%put offsetmax for y-axis is set as %sysevalf(&yaxis_offset4max*15/&totsc);
                    %end;
					%else %if &totsc>10 %then %do;
                        offsetmin=%sysevalf(&yaxis_offset4min*13/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*13/&totsc)
                        %put offsetmax for y-axis is set as %sysevalf(&yaxis_offset4max*10/&totsc); 
                    %end;
                    %else %if &totsc>5 %then %do;
                        offsetmin=%sysevalf(&yaxis_offset4min*8/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*8/&totsc)                    
						%put offsetmax for y-axis is set as  %sysevalf(&yaxis_offset4max*5/&totsc) ;
                    %end;
                    %else %do;
                        offsetmin=&yaxis_offset4min 
                        offsetmax=&yaxis_offset4max                    
                        %put offsetmax for y-axis is set as &yaxis_offset4max ; 
                    %end;
/*			linearopts=(minorticks=false tickvaluelist=(&y_axis_values) )      */
                         type=linear
                         linearopts=(
                         %*expand the min and max value with 0.1 when only drawing gene track;
                         %if &NotDrawScatterPlot=1 %then %do;
                         %*it is hard to optimize;
                         viewmax=-&offsety viewmin=%sysevalf(&min_y-&offsety)
                         %end;
                         %else %do;
/*                          viewmax=%sysevalf(&max_y+&offsety*2/&totsc) */
/*                          viewmin=%sysevalf(&min_y-&&offsety*2/&totsc) */
/*                      This part will affect the union of y-axis, with othe optimized value 1 to be added or removed from max and min, respectively               */
                         viewmax=%sysevalf(&max_y+0.1)
                         viewmin=%sysevalf(&min_y-0.1)                         
                         %end;
                         %if &use_custom_y_ticks=1 %then %do;
                         minorticks=false tickvaluelist=(&y_axis_values) tickdisplaylist=(&ylabelsmacro_var)
                         %end;
                         %else %do;
                         minorticks=false
                         %end;
/*This is the key part to make the y-axis as desinged: read https://www.lexjansen.com/nesug/nesug12/bb/bb04.pdf*/
                        %if &yaxis_auto_ticks=0 %then %do;
                         tickvaluefitpolicy=none
                         %end;
                         )
                       )
                        xaxisopts=(
                        linearopts=(
                        
                        %if %length(&xaxis_viewmin)>0 %then %do;
                        viewmin=&xaxis_viewmin
                        THRESHOLDMIN=0 
                        %end;
                        %else %do;
                        viewmin=&min_x
                        %end;
                        
                        %if %length(&xaxis_viewmax)>0 %then %do;
                        viewmax=&xaxis_viewmax
                        THRESHOLDMAX=0
                        %end;
                        %else %do;
                        viewmax=&max_x
                        %end;
                        
                        tickvalueformat=best32.) 
/*                      offsetmin=0.05 offsetmax=0.05       */
                        offsetmin=&xaxis_offset4min offsetmax=&xaxis_offset4max
                        );
 
 %if %length(&var4label_scatterplot_dots)>0 %then %do;
*Add labels for specific dots in scatterplots, but it is impossible to rotate text using the procedure scatterplot;
/*        scatterplot x=pos y=&yval_var/ MARKERCHARACTER=&var4label_scatterplot_dots MARKERCHARACTERPOSITION=topright*/
/*                                   MARKERCHARACTERATTRS=(color=black size=&grp_font_size*/
/*                                   style=normal weight=normal);*/
*textplot gives the more control on the manipulation of text;
      %if (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0 and &NotDrawScatterPlot=0) %then %do;
      
          *Ensure firstly add vertical reference line for these marker positions;
          %do mki=1 %to %ntokens(&markers_pos);
/*            referenceline x=%scan(&markers_pos,&mki) /lineattrs=(color=&reflinecolor4selecteddots*/
/*                                                      pattern=thindot thickness=1);*/
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatgraph/n1jn4duv8s510xn1y2nlbefm0p46.htm;
*https://blogs.sas.com/content/graphicallyspeaking/2018/01/15/advanced-ods-graphics-draw-statements;
*The drawline is better with the drawspace controling the line positions;
/*              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=0 x2=%scan(&markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y-0.5) / drawspace=datavalue*/
/*                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);*/
/*              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=%sysevalf(&max_y-0.5) x2=%scan(&new_markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y) / drawspace=datavalue*/
/*                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);                                       */
		      drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=0 x2=%scan(&markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y*&snp_line_split_ratio) / drawspace=datavalue
                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);
              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=%sysevalf(&max_y*&snp_line_split_ratio) x2=%scan(&new_markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y) / drawspace=datavalue
                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);    
          %end;   
          
          *POSITION=BOTTOM | BOTTOMLEFT | BOTTOMRIGHT | CENTER | LEFT | RIGHT | TOP | TOPLEFT | TOPRIGHT | keyword-column;
          *specifies the position of the text value with respect to the location of the data point.;
          *When text_rotate=90, use position=right;
          *When text_ortate=0, use text=center;
		  %if &text_rotate_angle>0 %then %do;
          textplot x=newpos y=top_y4label text=&var4label_scatterplot_dots/ 
              rotate=&text_rotate_angle position=right textattrs=(size=&effective_font_size4textlabels)
              POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
		  %end;
	      %else %do;
          textplot x=newpos y=top_y4label text=&var4label_scatterplot_dots/ 
              rotate=&text_rotate_angle position=center textattrs=(size=&effective_font_size4textlabels)
              POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
		  %end;
           
       %end;
       %else %do;
          textplot x=pos y=&yval_var text=&var4label_scatterplot_dots/ rotate=&text_rotate_angle position=center textattrs=(size=&effective_font_size4textlabels)
                                                                                                                   POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
        %end;
 %end;
 
	%if (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0) %then %do;
	   referenceline y=&max_y /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
	%end;                        
                        /* Need to add this into linearopts later: tickdisplaylist=(&y_grp_values)*/
		 %do xti=1 %to %sysfunc(countw(&genegrp_ords));
      %let i=%scan(&genegrp_ords,&xti);
	       %if &i=1 %then %do;
                     *Add group labels, but failed due to text statement is not available for proc template;
                     *text x=&pos&i y=&yval_var.&i text=group_label;
                     *If the scatterplot is not wanted, we can exclude the reference line at 0;
                     %if %eval(&NotDrawScatterPlot=0) %then %do;
		              referenceline y=0 /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
		             %end;     
						%if &min_y<0 %then %do;
/* 						  %do _yi_=&min_y %to -1; */
/* 		       referenceline y=&_yi_ /lineattrs=(color=black pattern=thindot thickness=1); */
/* 					          %end; */
                          %let _yneg_n=%eval(%sysfunc(countc(&yvals4reflines,%str( ))) + 1);
                          %do  _yneg_i=1 %to &_yneg_n;
                            *Do not draw reference line when NotDrawScatterPlot=1;
                            *Note: - is added before the number;
                            %if &NotDrawScatterPlot=0 %then %do;
                             %if &totsc<=5 %then %do;
                            		 %if &draw_grid4y=1 %then %do;
                                  referenceline y=-%scan(&yvals4reflines,&_yneg_i,%str( )) /lineattrs=(color=&refline_color pattern=thindot thickness=1);
                                  %end;
                             %end;
                            %end;
                          %end;
						%end;
												
						
						%do yi=1 %to &max_y;
						    %if &totsc<=5 and &totsc>=2 %then %do;
                        %if &draw_grid4y=1 %then %do;
							            referenceline y=&yi /lineattrs=(color=&refline_color pattern=thindot thickness=1);
                         %end;
						    %end; 
						    *fix a bug when mk_fake_axis_with_updated_func=1 by getting rid of the last unwanted refline;
						    *also need to restrict it with %sysfunc(countw(&fake_refline_values))=2;
/* 						    %if (&mk_fake_axis_with_updated_func=1 and %sysfunc(countw(&fake_refline_values,ad))=1) %then  */
/* 						    %let fytot=%sysevalf(%sysfunc(countw(&fake_refline_values,ad)) - 0); */
/* 						    %else %let fytot=%sysfunc(countw(&fake_refline_values,ad)); */
/*                          The above uses countw without the modifiers ad for alphabetic and digital words will results in wrong result*/
                            %let fytot=%ntokens(&fake_refline_values);
/*                             Maybe due to the overwritten value of global variable fake_refline_values, fytot is also as 1 when there are actually 2 scatterplot*/ 
                           *Here it should be &fytot>=1 but not &totsc>=2;
                          %if &totsc>2 %then %do;
                          /*Only when there are more than 1 scatterplot, it will draw additional thick reference line to separate scatterplots*/
						    %do xxi=1 %to &fytot;
                              %if &yi=%scan(&fake_refline_values,&xxi) %then %do;
		                         referenceline y=&yi /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
		                         
							  %end;
						    %end;
						  %end;
						 %end;
		   %end;
					    *If the _y&i dsd dose not exist, skip it;
					    %if %sysfunc(exist(work._y&i._)) %then %do;
									   %if %eval(&i=1) %then %do;
												 *make the 1str grp use group=&grp_var.&i and enable its color more transparent;
										     *Excludeing missing groups from the legend by adding the option: INCLUDEMISSINGGROUP=FALSE;
               seriesplot x=pos&i y=&yval_var.&i / group=&grp_var.&i connectorder=xaxis
			                          /*To use custom color, add color=black or other inside the lineattrs block*/
			                         %if %length(&color_resp_var)>0 %then %do;
									 lineattrs=(pattern=SOLID thickness=&linethickness color=%scan(&fixedcols4tracksunderscatter,1,%str( )))
									 %end;
									 %else %do;
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
									  %end;
                                      name="series&i" datatransparency=0.5	INCLUDEMISSINGGROUP=FALSE
												%end;
												%else %if (%eval(&i>=2)) %then %do;
												 *Make other grps use dark color, but it is not possible, as group is needed;
               seriesplot x=pos&i y=&yval_var.&i /connectorder=xaxis group=&grp_var.&i 
			                           /*To use custom color, add color=black or other inside the lineattrs block*/
			                         %if %length(&color_resp_var)>0 %then %do;
									 lineattrs=(pattern=SOLID thickness=&linethickness color=%scan(&fixedcols4tracksunderscatter,2,%str( )))
									 %end;
									 %else %do;
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
									  %end;
                                      name="series&i" datatransparency=0.2

												%end;

          %end;                            
          ;
         %end;

 /*This highlow plot is specifically designed for drawing CNV*/
/*https://www.lexjansen.com/pharmasug-cn/2019/HW/Pharmasug-China-2019-HW06.pdf*/
*Not draw highlow lines before scatter dots;
/* highlowplot y=&yval_var high=&end_var low=&st_var /*/
/*	     group=&lattice_subgrp_var*/
/*         datatransparency=0.4*/
*        type=line  lineattrs=(thickness=10pt color=darkorange pattern=dash);
/*        type=line  lineattrs=(&highlow_line_cmd)*/
/*        highcap=NONE lowcap=NONE; */
	
*Use &grp_var to color dots in scatterplot;         
/*          scatterplot x=pos y=&yval_var/group=&grp_var name="sc"  */
/*                                        markerattrs=( */
/*                                        symbol=circlefilled size=&dotsize  */
/*                                        ); */
*Use &scatter_grp_var to color dots in scatterplot;
*Failed, use &grp_var, again;
*Need to have a new group var &lattice_subgrp_var to color them;
 %if &makedotheatmap=1 and %length(&heatmap_var)=0 %then %do;
*Note: the lattice_subgrp was used to determine whether to draw colorbar;
*the markercolorgradient will overwrite the symbol feature in markerattrs;
*filledoutlinedmarkers can be changed as true to add black dot outline;
*When choosing to draw dotheatmap;
*The group=&lattice_subgrp_var is not required!;
         scatterplot x=pos y=&yval_var/      
                                       markercolorgradient=old_y_attrvar
                                       filledoutlinedmarkers=false
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize
                                       );
/*        continuouslegend "sc"/title="Dot value"; */
/*        Only draw integer ticks for the colorbar legend */
          continuouslegend "sc"/title="&heatmap_legend_title" integer=true;
 %end;
 %if &makedotheatmap=1 and  %length(&heatmap_var)>0 %then %do;
*Note: the lattice_subgrp was used to determine whether to draw colorbar;
*the markercolorgradient will overwrite the symbol feature in markerattrs;
*filledoutlinedmarkers can be changed as true to add black dot outline;
*When choosing to draw dotheatmap;
*The group=&lattice_subgrp_var is not required!;
         scatterplot x=pos y=&yval_var/      
                                       markercolorgradient=heatmap_var_attrvar
                                       filledoutlinedmarkers=false
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize
                                       );
/*        continuouslegend "sc"/title="Dot value"; */
/*        Only draw integer ticks for the colorbar legend */
          continuouslegend "sc"/title="&heatmap_legend_title" integer=true;
 %end;
 %else %do;
         scatterplot x=pos y=&yval_var/ 
                                %if &lattice_subgrp_var ne and "&color_resp_var"="" %then %do;
                                       group=&lattice_subgrp_var
                                %end;
								%else %if 	"&color_resp_var"^="" and "&color_resp_vartype"="C" %then %do;
									   group=old_y INCLUDEMISSINGGROUP=FALSE
								%end;
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize);
%end;   

 %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
   *Overlay LD-linked points after the ordinary association scatter layer.;
   textplot x=pos y=&yval_var text=&var4mark_ld_scatterplot_dots /
     position=center textattrs=(color=&ld_marker_color size=%sysevalf(&dotsize+2) weight=bold);
 %end;

 %if %length(&ld_heatmap_var)>0 %then %do;
   *Opt-in LocusZoom-like LD layer. Its sequential scale is independent of the association Z-score scale.;
   scatterplot x=pos y=_LD_PLOT_Y_ /
     markercolorgradient=ld_r2_attrvar filledoutlinedmarkers=true name="ldsc"
     markerattrs=(symbol=circlefilled size=%sysevalf(&dotsize+1));
   continuouslegend "ldsc" / title="&ld_heatmap_legend_title" orient=horizontal
     location=inside halign=right valign=top;
 %end;

 /*This highlow plot is specifically designed for drawing CNV*/
/*https://www.lexjansen.com/pharmasug-cn/2019/HW/Pharmasug-China-2019-HW06.pdf*/
*Draw highlow lines before scatter dots, enabling the line cover these scatter data points;
%if &NoCNVs=0 %then %do;
 highlowplot y=&yval_var high=&end_var low=&st_var /
	     group=&lattice_subgrp_var
         datatransparency=0.5
/*        type=line  lineattrs=(thickness=10pt color=darkorange pattern=dash)*/
        type=line  lineattrs=(&highlow_line_cmd)
        highcap=NONE lowcap=NONE;  
%end;
                                       
       %if &add_grp_anno=1 %then %do;                              
         *Make sure to add the test label at the end, otherwise, these labels will be blocked by other layers;
         *MARKERCHARACTERPOSITION=CENTER | TOP | BOTTOM | LEFT | RIGHT | TOPLEFT | TOPRIGHT | BOTTOMLEFT | BOTTOMRIGHT;
/*         scatterplot x=pos1 y=&yval_var.1 / MARKERCHARACTER=grp_label MARKERCHARACTERPOSITION=left */
/*         use text customized y values to label these genes                                         */
         scatterplot x=_pos1_ y=_y_ / MARKERCHARACTER=grp_label MARKERCHARACTERPOSITION=topright
                                    MARKERCHARACTERATTRS=(color=black size=&grp_font_size 
                                    style=&grp_anno_font_type weight=normal);
       %end;
       
 %if %length(&ordered_sc_grpnames)>0 %then %do;      
       *Add scatter group header and adjust header x-axis position by length;
       scatterplot x=avgpos y=header_yval / markercharacter=header_grp 
       markercharacterattrs=(color=black size=%sysevalf(2+&grp_font_size)  weight=normal) 
       markercharacterposition=top;
  %end;    

      endlayout; 
	  sidebar /align=bottom;
			/*Note: only series1 is used to combine with sc in the discretelegend;
			  This is because seriesplot used the group options to draw all grps with
			  different colors in the 1st &grp_var1, which contain all gene grps;
			*/
 %if &makedotheatmap=1 %then %do;
      /*Remove the legend for gene tracks to save space and also keep the figure with the same height as the number of genes will affect the heights of data areas*/
      /*discretelegend "series1" /border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); */
 %end;
 %else %do;
/*	  discretelegend "sc" "series1"*/
 %if %length(&color_resp_var)>0 %then %do;
 *Remove gene legends when &color_resp_var is supplied, as these colors tend to be the same;
 discretelegend "sc" 	/border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
 %end;
 %else %do;
 *Do not need these redudant gene legends;
 %if &rm_gene_legend %then %do;
      discretelegend "sc" /border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
  %end;
  %else %do;
     discretelegend "sc" "series1"	/border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
  %end;
 %end;

 %end;
/*   Only add legends for scatter plot and gene track*	  
/* 	  discretelegend "sc" %do i=1 %to &max_ord; */
/*                           "series&i" */
/*                          %end; */

 %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
      entry "&ld_marker_legend_symbol LD-linked SNP" / textattrs=(color=&ld_marker_color size=&grp_font_size weight=normal);
 %end;

	  endsidebar;
   endlayout;
endgraph;
end;
run;


*Change dir into the termporary work dir for saving svg figure;
%if &sysscp=WIN %then %do;
   %let workdir=%sysfunc(getoption(work));
%end;
%else %do;
   %let workdir=%sysfunc(pathname(HOME));
%end;

data _null_;
rc=dlgcdir("&workdir");
run;

%if %length(&vars4figurename)>0 %then %do;
     %if %length(&vars4figurename)>32 %then %let vars4figurename=%scan(&vars4figurename,1,%str(_))_and_others;
     %let outimagename=&vars4figurename._%trim(%left(&chr_name))_&st_var%trim(%left(&min_x))_&end_var%trim(%left(&max_x));
%end;
%else %do;
     %let outimagename=&yval_var.Chr%trim(%left(&chr_name))_&st_var%trim(%left(&min_x))_&end_var%trim(%left(&max_x));
%end;
%let outimage_rand_suffix=%RandBetween(1,100);

%if not %symexist(local_gtf_ods_html5) %then %do;
  %put The final figure is put here:;
  %put &workdir/&outimagename._f&outimage_rand_suffix..&fig_fmt;
%end;
/* The SAS ODA wrappers already open HTML5 at the requested DPI. Opening HTML
   here would render the same large graph a second time in another destination. */
%if not %symexist(local_gtf_ods_html5) %then %do;
  ods html image_dpi=&image_dpi;
%end;
ods graphics on /
reset=all
outputfmt=&fig_fmt 
imagename="&outimagename._f&outimage_rand_suffix" 
noborder
MAXOBS=100000000
GROUPMAX=50000
;

*Add format for directions of &lattice_subgrp_var;
proc format;
value direction_fmt 
0='Neg' 
/*
-999 - < 0 = 'Neg'
*/
1='Pos'
/*
0< - <1 = 'Pos'
1< - 999 = 'Pos'
*/
;
run;

/*Does not work as expected;
ods graphics on/reset=all;
%ModStyle(
parent=journal,
colors=red blue green
);
*The above will generate the Newstyle;
ods html style=Newstyle;
*/

*Draw the final figure with data set final and the template BedGraph;
proc sgrender data=WORK.final template=BedGraph;
dynamic _chr="&chr_var";

%if %length(&color_resp_var)>0 %then %do;
  %if "&color_resp_vartype"="C" %then %do;
   format old_y y2x4colresp.;
  %end;
%end;
%else %if (%length(&heatmap_var)>0 and &makedotheatmap=1) %then %do;
  *No need to format when makeing heatmap;
%end;
%else %do;
   format &lattice_subgrp_var direction_fmt.;
%end;
run;


*****************************************************************************************************************;
*Clean temporary datasets;
*Need to delete these _y: datasets, as there are used by the above proc template macro scripts;
%if &debug=0 %then %do;
proc datasets nolist;
delete _y: y1for: _xtag_ _single_ _dsdin_ X1_: scgrpnames Header_dsd Final_fmt;
run;
%end;

*Ensure the input &bed_dsd is not changed;
data &bed_dsd;
set &bed_dsd._org;
run;
proc sql noprint;
drop table &bed_dsd._org;
run;

%put Lattice gscatter plot is completed!;
%put ;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/Manhattan4DiffGWASs_png.sas */
%macro Manhattan4DiffGWASs(
dsdin=,/*Input GWAS dataset with multiple GWAS p variables put in columns; it is ideal to have sorted GWAS by numeric chr and position*/
pos_var=,/*Position variable for markers, such as SNPs*/
chr_var=,/*Chromosome variable for markers, such as SNPs; it is better to have numberic chr var as input*/
P_var=,/*The P var for the 1st GWAS that is put at the bottom of the final manhattan plot; can be the only GWAS input*/
Other_P_vars=, /*Leave it empty for a single-GWAS plot, or provide other GWAS P vars in order for making manhattan plots from botton to up*/
logP=1,/*Provide value 1 to indicate the need of performing -log10 caculation for input P_var; Make sure the P_var and Other_P_vars are in the same format!*/
gwas_thrsd=7.3,/*Use it to draw significance reference line in each GWAS track*/
thrsd_line_color=gray,
dotsize=2,/*The dot size for scatter plots*/
_logP_topval=10, /*Top -log10P value to truncate GWAS signals and also restrict the max yaxis value of each GWAS track;
Make sure to input EVEN number for the macro, as the macro separate ticks by step 2!*/
y_axix_step=2,/*Customize the step for all y-axis tikets*/
fig_width=1200,
fig_height=500,
fontsize=3,
y_axis_label_size=, /*Optional y-axis label font size; default uses fontsize*/
y_axis_value_size=, /*Optional y-axis tick-value font size; default uses fontsize*/
gwas_label_names=, /*Optional pipe-delimited labels matching P_var followed by Other_P_vars*/
gwas_label_x_pct=50, /*Graph-percent x position for GWAS track labels*/
gwas_label_y_frac=0.89, /*Within-track y position as fraction of _logP_topval*/
gwas_label_size=1.0, /*Black foreground label size in percent units*/
gwas_label_halo_size=1.0, /*White underlay label size in percent units, ensure it is the same as the gwas_label_size!*/
gwas_label_angle=0, /*Angle for GWAS track labels*/
flip1stGWAS_signal=1, /*When providing value 1, which will draw the 1st GWAS at the bottom in reverse order for the yaxis, 
which means the most significant association will be put close to bottom;
provide value 0 to draw the 1st GWAS in vertical mode!*/
refline_color_4zero=gray, /*Color the manhattan bottom line*/
rm_signals_with_logP_lt=0.5, /*To make the manhattan plot have reference line at association signal of zero,
it is better to remove associaiton signal logP for all GWASs less than the cutoff*/
use_uniq_colors=1, /*Draw scatter plots with different colors for chromosomes;
provide value 0 to use SAS default color scheme;*/
uniq_colors=,/*Provide customized uniq colors, such as cx0072bd and others with the prefix cx;
If left empty, the default unique colors included in the macro will be used!*/
gwas_sortedby_numchrpos=0, /*Ideally the input GWAS dsdin should be sorted by numchr and pos;
if the GWAS dsdin is not, the macro will sort it accordingly but will require more memory and disk space*/
outputfigname=Manhattan, /*a prefix used to label the output figure*/
plot_title=, /*Optional visible title for the plotted statistic and color encoding.*/
angle4xaxis_label=40, /*Adjust the angle of xaxis group labels*/
Use_scaled_pos=1, /*Default is to draw manhattan plot with fake positions by group in even distance;
Provide value 1 to draw the plot in scaled and uneven distance relative to its real position values!
This will be helpful when draw top hits local manhattan plots!
*/
sep_chr_grp=0, /*Default is not to add lines to separate x-axis chromosomal groups;
Provide value 1 to add lines to separate each chromosomal group*/ 
xgrp_y_pos=-1, /*Asign the y-axis value for all x-axis group labels;
It is necessary to adjust the value if the default value is out of range;
Try to use -1 to replace -1.5 if the above issue occurred!*/
yoffset_setting=%str(offset=(0.5,0.5)), /*This macro var is used to extend the bottom and upper y-axis;
which is especially helpful when the position of x-axis group labels assigned by xgrp_y_pos is 
out of the default offset of y-axis */

/*Important parameters for drawing local Manhattan pltos*/
draw_local_Manhattan=0,/*Default is to draw genome-wide Manhattan plot; if supplying value 1, the macro will draw local
Manhattano around target SNPs when the macro var target_SNPs is provided or top hits if the macro var target_SNPs
is empty and the macro var top_hit_thresd is supplied with specific association p threshold, such as p < 1e-6*/
snp_var=rsid,/*It is necessary to have snp_var supplied when drawing local Manhattan plot*/
snp_gene_splitter=:,/*In case the gene name for the snp is also supplied to the snp_var, the macro
will split the snp_var into two string, with the first is snp and the 2nd is genename for it, which will
be plotted at the bottom of the figure as x-axis labels for different snp mahattan plot*/
target_SNPs=,/*Default is empty; please provide rsid that can be matched with the snp macro variable*/
Keep_order_of_target_SNPs=0, /*Draw local Manhattan plot according to the order of target SNPs
Note: need to set this macro with value 1 if drawing local Manhattan plots for target SNPs or top hits, 
which means if either target_SNPs or top_hit_thresd is not empty, please assign value 1 to this macro var!
When draw genome-wide Manhattan plots, it is required to assign value 1 to this macro var.*/
top_hit_thresd=,/*provide a p value threshold to only draw local Manhattan plot for the smallest 
top hit around a specific genomic window,such as p < 1e-6 within a window of 1e7 bp*/
dist4get_smallest_top_hit=1e7, /*Select the smallest top SNP around a genomic window of the supplied distance in bp*/
only_get_top_hit4n_th_gwas=0, /*The parameter enables the macro to focus on top hits from specific gwas represented by
its order starting from 1 to n for the 1st gwas and other gwass inferred by their supplied P variables; the default value 0 means
to query all gwas top hits; if only want to query top hits from the 1 gwas, please supply value 1, and this applicable to 
other gwass if the correct numeric order for the gwas is supplied here!*/
LD_SNPs2mark_scatterplot_dots=, /*Space-delimited high-LD rsIDs overlaid on every GWAS track.*/
LD_marker_symbol=*,
LD_marker_color=black,
LD_display_mode=none,
LD_r2_values=,
LD_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
LD_heatmap_legend_title=%str(LD r2)
);

%local n_other_pvars n_gwas_pvars;
%let n_other_pvars=%sysfunc(countw(%superq(Other_P_vars),%str( )));
%let n_gwas_pvars=%eval(&n_other_pvars+1);

/**fake data;*/
/*data manhattan ;*/
/*Fake_position=1; */
/*do &chr_var=1 to 22;*/
/*do _n_=1 to ( 1e6 - &chr_var * 10000 ) - 1 by 1000 ;*/
/*   Fake_position + _n_ / 1e6 ;*/
/*   logp = -log( ranuni(2)) ;*/
/*   output ;*/
/*end;*/
/*end;*/
/*run;*/

%if %length(&Other_P_vars)=0 %then %do;
    %put NOTE: Other_P_vars is empty, so the macro will draw a single-GWAS Manhattan plot using only &P_var;
%end;

%if %varexist(ds=&dsdin,var=&chr_var) = 0 %then %do;
					 %put Input chr var &chr_var does not exit!;
           %abort 255;
%end;

%if %varexist(ds=&dsdin,var=&pos_var) = 0 %then %do;
					 %put Input position var &pos_var does not exit!;
           %abort 255;
%end;

%if %varexist(ds=&dsdin,var=&P_var) = 0 %then %do;
					 %put Input P value var for the 1st GWAS does not exit!;
           %abort 255;
%end;



*Subset GWAS data for target regions with top association signals passed specific p threshold;
*or just draw the local Manhattan for these target SNPs with specific window size; 
%if &draw_local_Manhattan=1 %then %do;
       *Draw local Manhattan plot for target SNPs;
			 %if 	(%length(&target_SNPs)>0 and %length(&top_hit_thresd)=0) %then %do;
					%put We will extract association signals around these target snps and draw local Manhattan plot;
           %put Your target SNPs are &target_SNPs;
          *Get target SNPs; 
          %get_tgt_hits4Manhattan(
           dsdin=&dsdin,
           snp_var=&snp_var,
           chr_var=&chr_var,
           pos_var=&pos_var,
           p_var=&P_var,
           dsdout=_tgthits_,
           target_snps=&target_snps, 
           keep_target_snps_order=&Keep_order_of_target_SNPs,
           dist4get_uniq_top_hit=&dist4get_smallest_top_hit 
           );
          *Note: the above macro will generate new variable tag_snp and a global macro variable _chr_colors_;
          *which will be used to draw Manhattan plots by chr, and it is necessary to reset these macro var values for making local Manhattan plot;
          %let dsdin=_tgthits_;
           *Draw local Manhattan plots by sorted order of target SNPs;
           %let chr_var=tag_snp;
           %if &Keep_order_of_target_SNPs=1 %then %do;
           *Draw local Manhattan plots by keeping the original order of target SNPs;
           %let chr_var=num_grps;
           %end;

          %let uniq_colors=&_chr_colors_;
       %end;
       %*Draw local Manhattan plot for top hits passed a specific p threshold;
       %else %do;
           %if %length(&top_hit_thresd)=0 %then %let top_hit_thresd=1e-6;
           %let top_snps=;
           %local _mh_;
		   %do _mh_= 1 %to &n_gwas_pvars;
			 %if &only_get_top_hit4n_th_gwas=0 %then %do;
             %get_top_hits4Manhattan(
              dsdin=&dsdin,
              snp_var=&snp_var,
              chr_var=&chr_var,
             pos_var=&pos_var,
             p_var=%scan(&P_var &Other_P_vars,&_mh_,%str( )),
             dsdout=_tophits_&_mh_,
             p_thrsd=&top_hit_thresd, 
            dist4get_uniq_top_hit=&dist4get_smallest_top_hit
             );
/*             *Note: the above macro will create new variable tag_snp and a global macro var _top_snps_ that will be used to capture these top SNPs;*/
/*             %let top_snps=&top_snps &_top_snps_;*/
			%end;
			%else %if (&_mh_=&only_get_top_hit4n_th_gwas) %then %do;

             %get_top_hits4Manhattan(
              dsdin=&dsdin,
              snp_var=&snp_var,
              chr_var=&chr_var,
             pos_var=&pos_var,
             p_var=%scan(&P_var &Other_P_vars,&_mh_,%str( )),
             dsdout=_tophits_&_mh_,
             p_thrsd=&top_hit_thresd, 
            dist4get_uniq_top_hit=&dist4get_smallest_top_hit
             ); 
 
			%end;
           %end;
					 %put We will extract associaiton signals around these top SNPs within a genomic window of &dist4get_smallest_top_hit bp that pass the p value threshold of &top_hit_thresd;
           %put These top SNPs are &top_snps;
            data tophits_all;
            set _tophits_:;
            run;
           *Reset these macro var values for making local Manhattan plot;
            %let dsdin=tophits_all;
            *Draw local Manhattan plots by sorted order of target SNPs;
            %let chr_var=tag_snp;
            proc sql noprint;
            select distinct cls into: uniq_colors separated by ' '
            from tophits_all 
            order by tag_snp;
       %end;
%end;

*Check &chr_var type for preparing of making alternative var _chr_ for plotting;
*Note: will create a global var: var_type, which can be used in other macro;
%check_var_type(
dsdin=&dsdin,
var_rgx=&chr_var
);
%put Created a global var for chr, its type of which is &var_type;
/*%put the macro chr_var is &chr_var;*/
/*%abort 255;*/

*For char &chr_var;
%if "&var_type"="2" %then %do;
/*This step will take a lot of disk space*/
data &dsdin;
set &dsdin;
frq=1;
run;
%if &Keep_order_of_target_SNPs=1 %then %do;
/*For ordered local Manhattan panels, assign a stable numeric group id directly
  instead of depending on a generated format catalog entry.*/
%let ordered_target_label_var=&chr_var;
data _chr_map_;
  length &chr_var $32767;
  if 0 then set &dsdin(keep=&chr_var);
  declare hash seen();
  seen.defineKey("&chr_var");
  seen.defineData("&chr_var","_chr_");
  seen.defineDone();
  do until (eof);
    set &dsdin(keep=&chr_var) end=eof;
    if seen.check() ne 0 then do;
      _chr_+1;
      seen.add();
      output;
    end;
  end;
  stop;
run;

proc sql;
create table &dsdin as
select a.*, b._chr_
from &dsdin as a
left join _chr_map_ as b
  on a.&chr_var=b.&chr_var
;
quit;
%end;
%else %do;
/*use the frq for sorting by total number of data points*/
%format_xaxis_with_numeric_order(
dsdin=&dsdin,
Xaxis_vars=&chr_var,
new_Xaxis_var=_chr_,
Var4sorting_Xaxis=frq,
function4sorting=count,
descending_or_not=0,
dsdout=&dsdin,
createdfmtname=Xaxis_var_label);
%end;

/*Use the following when the above failed*/
/* This will change char chr labels into numeric ones */
/* Used when it is necessary */

/* %chr_format_exchanger( */
/* dsdin=&dsdin, */
/* char2num=1, */
/* chr_var=&chr_var, */
/* dsdout=&dsdin); */

*Just try to reuse the above function, the function4sorint is not useful;
*so asign missing value for it;
%let chr_var=_chr_;
%end;


*real data;
%if %eval("&gwas_thrsd"="") %then %do;
%let gwas_thrsd=7.3;
%end;

*Sorting the gwas will slow down the macro;
/*
proc sort data=&dsdin;
by &chr_var &pos_var;
run;
*/

%if &gwas_sortedby_numchrpos=0 %then %do;
proc sort data=&dsdin;
by &chr_var &pos_var;
run;
%end;

%if %sas_dsd_exist(sasdsd=&dsdin)=0 or %totobsindsd(mydata=&dsdin)=0 %then %do;
    %put Your input dataset &dsdin does not exist or is empty;
    %abort 255;
%end;
 

%let nrows=%rows_in_sas_dsd(test_dsd=&dsdin);
%put There are &nrows in your dataset;

%if &Use_scaled_pos=0 %then %do;
*Here we will use fake positions with an even gap to draw manhattan plot;
/*For EWAS;*/
%if (&nrows lt 100000 and &nrows gt 30000) %then %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ / 1e2 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For local EWAS or GWAS;*/
%else %if (&nrows lt 30000 and &nrows gt 4000) %then %do;

data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ /2 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For local EWAS or GWAS;*/
%else %if &nrows le 4000 %then %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For GWAS*/
%else %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ / 1e3 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;

%end;

%else %do;
*Here we will use fake positions with scaled and uneven gap  to draw manhattan plot;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin,
axis_var=&pos_var,
axis_grp=&chr_var,
new_fake_axis_var=Fake_position,
dsdout=manhattan,
axis_step=1,
concise_output=1,
reset_1st_value_as_one=1
);
%end;


data manhattan;
set manhattan;
/* Keep a SNP when any displayed GWAS track has a P value. In merged-wide
   tables, meta and differential values can occupy distinct allele rows;
   filtering on the primary track alone silently empties the other track. */
if n(of &P_var &Other_P_vars)=0 then delete;
%if (&logP=1) %then %do;
logp=-log10(&P_var);
%end;
%else %do;
logp=&P_var;
%end;
run;

*Sorting the gwas will slow down the macro;
/*
proc sort data=manhattan;
by &chr_var Fake_position;
run;
*/

%if &gwas_sortedby_numchrpos=0 %then %do;
proc sort data=manhattan;
by &chr_var Fake_position;
run;
%end;
 
*find maximum value for the x-axis, store in a macro variable;
proc sql noprint;
select 1.005*ceil(max(Fake_position)) into :maxbp 
from manhattan;
quit;
 
* 
find mean of BP within each chromosome (C)
used later to position x-axis labels
;

*A potential bug here especially when there are a lot of SNPs with missing p values;
*were removed from the data set before calculating the mean of these positions;
*Try to generate a temporary data set;
proc sort data=manhattan(keep=&chr_var Fake_position) out=_manhattan_ nodupkeys;
by &chr_var Fake_position;
run;
proc sql;
create table _manhattan_ as
select *
from _manhattan_
group by &chr_var
having Fake_position=min(Fake_position) or Fake_position=max(Fake_position);
*If the above invite some bugs, it is feasible to use the data set manhattan to replace _manhattan_;
proc summary data=_manhattan_ nway;
%if &Keep_order_of_target_SNPs=1 %then %do;
*Draw local Manhattan plots by keeping the original order of target SNPs;
/*class &chr_var tag_snp;*/
*No need to add tag_snp as &chr_var is updated as tag_snp;
class &chr_var;
%end;
%else %do;
class &chr_var;
%end;
var Fake_position;
/*output out=mbp mean=;*/
/*output out=mbp mean= min=min max=max;*/
output out=mbp mean=;
run;

%if &Keep_order_of_target_SNPs=1 %then %do;
proc sql;
create table mbp as
select a.*, b.&ordered_target_label_var
from mbp as a
left join _chr_map_ as b
  on a.&chr_var=b._chr_
;
quit;
%end;

*The _mid_ is the same as the mean position;
/*data mbp;*/
/*set mbp;*/
/*_mid_=(max-min)/2 + min;*/
/*run;*/

 
* annotate data set used to add x-axis labels
"manually" add the frame around the graph
possibly add a horizontal reference line
;
data anno ;
length color $10. text $64. style $20.;
*Note: the position will decide where to put the text;
*position '1': put text under the position and left adjusted;
*position '2': put text at the middle of the position and left adjusted;
*position '3': put text above the position and left adjusted;
*position '4': put text under the position and center adjusted;
*see other useful positions, such as A, B, C, D, E, F;
*and <,+, and >, and 7,8,9;
*at: https://documentation.sas.com/doc/es/pgmsascdc/v_053/graphref/annotate_position.htm;
%if "&var_type"="2" or &Keep_order_of_target_SNPs=1 %then %do;
retain position '4' xsys ysys '2' y &xgrp_y_pos function 'label' text 'xx'  angle &angle4xaxis_label;
%end;
%else %do;
*Key part to put the genomewide xgroup labels, such as 1,2,3,...,20 at the center of the position on the x-axis;
%*put the xgroup labels at the center but one cell lower than the position;
/* retain position '8' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Put the xgroup labels at the center of the position;
/* retain position '+' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Text baseline half cell below location;
/* retain position '5' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Half cell below location;
retain position 'E' xsys ysys '2' y 0 function 'label' text 'xx';
%end;
do until (last1);
  %if &Keep_order_of_target_SNPs=1 %then %do;
  *Draw local Manhattan plots by keeping the original order of target SNPs;
/*   set mbp (keep = Fake_position &chr_var  tag_snp) end=last1;*/
   *No need to add tag_snp as &chr_var is tag_snp when keep_order_of_target_SNPs is true;
     set mbp (keep = Fake_position &chr_var &ordered_target_label_var) end=last1;
  %end;
  %else %do;
   set mbp (keep = Fake_position &chr_var) end=last1;
  %end;
   x = round(Fake_position) ;
   *This step can be modified to remove the x-axis group labels by asigning empty str to text;
   %if &Keep_order_of_target_SNPs=1 %then %do;
     *For ordered local grouped Manhattan plots, keep numeric ordering in _chr_
      while restoring the original SNP:gene label for the bottom box.;
     text = strip(&ordered_target_label_var);
   %end;
   %else %if "&var_type"="2" %then %do;
   *text="";
    text=put(&chr_var,Xaxis_var_label.);
/*       text=cat(&chr_var);*/
   %end;
   %else %do;
      text = cat(&chr_var);
      if text="20" or text="22"  then text=" ";
   %end;
   output;
end;
 
* top of frame;
%if &n_gwas_pvars > 1 %then %do;
xsys = '1'; ysys = '1'; function = 'move'; x = 0; y=100; output;
xsys = '2'; function = 'draw'; x = &maxbp ; output;
%end;
* bottom of frame;
xsys = '1'; ysys = '1'; function = 'move'; x = 0; y=0; output;
xsys = '2'; function = 'draw'; x = &maxbp ; output;
 
* horizontal reference line (if needed for 5x10-08);
%if &n_gwas_pvars > 1 %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;

* Explicit zero-reference line for the first/bottom GWAS track.
* This is separate from the frame border because axis offsets used for SNP/gene
* labels can move the visible plotting region away from the graph edge.
%if &draw_local_Manhattan=1 %then %do;
* When drawing local Manhattan plot, it is better to have the reference line for zero association signals;
%if (&flip1stGWAS_signal=0) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=0; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;
%else %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;
%end;

*Note: only when &_logP_topval>&gwas_thrsd, the macro can draw these gwas threshold reference line;
%if (&flip1stGWAS_signal=0) %then %do;
%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&gwas_thrsd; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;
%end;
%else %do;
%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval-&gwas_thrsd; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;
%end;

%do ri=1 %to &n_other_pvars;

*For lines in the middle separating different scatter plots, use large line size to draw lines;
%if &ri < &n_other_pvars %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval+&_logP_topval*&ri; output;
xsys = '2'; function = 'draw'; x = &maxbp ;  line=1; size=3; color="&refline_color_4zero";output;
%end;

%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
*For lines at the top and bottom, use lighter line size to draw lines;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&gwas_thrsd+&_logP_topval*&ri; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;

%end;

* Add GWAS variable names in the middle of each stacked GWAS track;
%do _gwas_label_i_=1 %to &n_gwas_pvars;
  label_x = &maxbp / 2;
  label_y = (&_gwas_label_i_ - 1) * &_logP_topval +
            min(&_logP_topval - 0.8, max(0.8, &_logP_topval * &gwas_label_y_frac));
  %if %superq(gwas_label_names) ne %then %do;
    text = "%qscan(%superq(gwas_label_names),&_gwas_label_i_,|)";
  %end;
  %else %do;
    text = "%scan(&P_var &Other_P_vars,&_gwas_label_i_,%str( ))";
  %end;

  * A white label underlay gives a readable halo over dense point clouds;
  * when 'a' is used for when, the label will be drawn after all the points are drawn, which can make sure the label is not covered by any points;
  xsys = '2';
  ysys = '2';
  hsys = '3';
  when='a';
  function = 'label';
  x = label_x;
  y = label_y;
  color = 'white';
  style = 'Albany AMT';
  size = &gwas_label_halo_size;
  position = '5';
  angle = &gwas_label_angle;
  output;

  * Dark label centered over the white underlay;
  function = 'label';
  x = label_x;
  y = label_y;
  color = 'black';
  style = 'Albany AMT';
  size = &gwas_label_size;
  position = '5';
  angle = &gwas_label_angle;
  when='a';
  output;
%end;
drop label_x label_y;

run;

*Further split text annotation if it contains the split char ":";
*https://communities.sas.com/t5/Graphics-Programming/Splitting-text-in-two-lines-using-annotion-dataset/td-p/246199;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/graphref/annotate_position.htm;
data anno;
retain str_len_diff 0;
set anno;
text0=trim(left(text));
if prxmatch("/[^&snp_gene_splitter]+:[^&snp_gene_splitter]+/",text) and function='label' then do;
	  do ti=1 to min(3,countw(text0,"&snp_gene_splitter"));
		 text=scan(text0,ti,"&snp_gene_splitter");
		 str_len_diff=length(scan(text0,1,"&snp_gene_splitter"));

		 *half cell above location right aligned;
		 %if &angle4xaxis_label=90 %then %do;
		 if ti=1 then do;
            position='B';
            y=&xgrp_y_pos;
            hsys='3';
            size=max(1,&fontsize*0.80);
            style='Albany AMT';
         end;
		 %end;
		 %else %do;
		 if ti=1  then position='2';
		 *one cell below location centeral aligned;
		 %end;

		 else if ti=2 then do;
            %if &angle4xaxis_label=90 %then %do;
             position='E';
             y=&xgrp_y_pos;
             hsys='3';
             size=max(1,&fontsize*0.72);
			*Use annotate relative-position placement for the second rotated line,
             which matches the behavior of the original macro better than
             forcing explicit x/y offsets.;
			 %end;
			 %else %do;
		     position='+';*original location central alignment; 
			 %end;
			 *See availabel SAS font style: https://documentation.sas.com/doc/en/vwbgraphref/v_001/n0c8945h7o2kmrn1h0uehmio2i6j.htm;
			 style='ITALIC';
			str_len_diff=str_len_diff-length(scan(text0,2,"&snp_gene_splitter"))+1;
			*str_len_diff=round(str_len_diff/2);
			if str_len_diff>0 then do;
			  *text=resolve('%AddSpaces4str(str='||text||',add2end=1,nspaces='|| str_len_diff ||',char4space=-)');
			end;
		 end;
		 else do;
            *Third component, when supplied, is the chromosome name.
             Place it to the right of the vertical gene symbol.;
			%if &angle4xaxis_label=90 %then %do;
            position='E';
            y=&xgrp_y_pos;
            hsys='3';
            size=max(1,&fontsize*0.66);
            *Convert the gene-label font height to fake-position units so
             the chromosome label has its own column to the right.;
            x=x+1.3*&maxbp*max(1,&fontsize*0.72)*&fig_height/(100*&fig_width);
			%end;
			%else %do;
            position='+';
			%end;
            style='Albany AMT';
		 end;
		 output;
	  end;
end;
else output;
drop text0 ti;
run;

 
* reset all then set some graphics options;
%let max_yaxis_val=%sysevalf(&n_other_pvars*&_logP_topval + &_logP_topval);
*If put reset=all inside the command of goptions, the title will be removed;
*It is necessary to reset all here, otherwise, the figure may be distorted;
*Albany AMT is equivalent to Arial in SAS;
* destination for the plot;
filename gout "~/&outputfigname..png";

goptions reset=all ftext="Albany AMT" htext=&fontsize gunit=pct 
         dev=png xpixels=&fig_width ypixels=&fig_height gsfname=gout gsfmode=replace;

 
/* Clear inherited titles and draw a requested title with a compact font. */
%if %length(%superq(plot_title))>0 %then %do;
  title1 h=1.3 "&plot_title";
%end;
%else %do;
  title1;
%end;
title2;
title3;
footnote1;
 
* let SAS choose the colors;
* use h=5 to set dot size for the plot;
%if &use_uniq_colors=0 %then %do;
symbol1 v=dot r=46 h=&dotsize;
%end;
%else %do;
 %if %length(&uniq_colors)=0 %then %do;
      *Use default unique colors;
      %uniqcolors;
  %end;
   %else %do;
     *Use customized unique colors;
     %uniqcolors(inputcolors=&uniq_colors);
    %end;
%end;

* two alternating colors;
* gray-scale;
*%twocolors(gray33,graycc);
* blue and blue-green;
*%twocolors(cx2C7FB8,cx7FCDBB);
 
*If the y_axix_step is larger than the top _logp_topval;
*Use step value 2 instead;
%if %sysevalf(2*&y_axix_step)>=&_logp_topval %then %do;
					 %put Your assigned y-axis step value &y_axix_step is too large and even larger than half of the top association value;
           %put The macro will reset the y-axis step value as 2!;
           %let y_axix_step=2;
%end;

%if %length(&y_axis_label_size)=0 %then %let y_axis_label_size=&fontsize;
%if %length(&y_axis_value_size)=0 %then %let y_axis_value_size=&fontsize;

* suppress drawing of any x-axis feature;
axis1 value=none major=none minor=none label=none style=0;
* rotate y-axis label and asign font as f='Albany AMT';
axis2 label=(angle=90 "-Log10(p)" f=Arial h=&y_axis_label_size) 
     order=(0 to  &max_yaxis_val by &y_axix_step)	 &yoffset_setting
      value=(f=Arial h=&y_axis_value_size
             %do _pi_=0 %to &n_other_pvars;
                %if (&flip1stGWAS_signal=1 and &_pi_=0) %then %do;
                  %do _ti_=&_logp_topval %to &y_axix_step %by -&y_axix_step;
                      "&_ti_"
                   %end;              
                 %end;
                 %else %do;
                  %do _ti_=0 %to %sysevalf(&_logp_topval-&y_axix_step) %by &y_axix_step;
                      "&_ti_"
                   %end;
                  %end;
               %end;
                ' '
                  );
 
* use PROC GPLOT to create the plot;
*Add format for customized &chr_var labels;
*Make sure to remove nolegend;

data manhattan;
set manhattan;
length _LD_SNP_MARK_ $8 _LD_COLOR_ $16;
_LD_SNP_MARK_='';
_LD_R2_=.;
%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and %upcase(&LD_display_mode) ne NONE %then %do;
if findw(upcase("&LD_SNPs2mark_scatterplot_dots"),upcase(strip(&snp_var)),' ')>0
  then _LD_SNP_MARK_="&LD_marker_symbol";
%end;
%if %length(&LD_r2_values)>0 and
    (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
%do _li_=1 %to %ntokens(&LD_r2_values);
  %let _ld_pair_=%scan(&LD_r2_values,&_li_,%str( ));
  if upcase(strip(&snp_var))=upcase("%scan(&_ld_pair_,1,%str(:))") then
    _LD_R2_=input("%scan(&_ld_pair_,2,%str(:))",best32.);
%end;
if not missing(_LD_R2_) then do;
  if _LD_R2_<0.5 then _LD_COLOR_="%scan(&LD_heatmap_colormodel,1,%str( ))";
  else if _LD_R2_<0.8 then _LD_COLOR_="%scan(&LD_heatmap_colormodel,2,%str( ))";
  else _LD_COLOR_="%scan(&LD_heatmap_colormodel,-1,%str( ))";
end;
%end;
*Further remove signals with logP<1.3, which will save space and prevent the reference lines covered by these signals with logP<1.3;
if logP<&rm_signals_with_logP_lt then logP=.;
if logp>&_logP_topval then logp=&_logP_topval;

%if (&flip1stGWAS_signal=1) %then %do;
logp=&_logP_topval-logp;
%end;


%do _mi_=1 %to &n_other_pvars;
 logp&_mi_=-log10(%scan(&Other_P_vars,&_mi_,' '));
if logP&_mi_<&rm_signals_with_logP_lt then logP&_mi_=.;
 if logp&_mi_>&_logP_topval then logp&_mi_=&_logP_topval ;
if logp&_mi_^=. then logp&_mi_=logp&_mi_+&_logP_topval*&_mi_;
%end;

run;

%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and
    (%upcase(&LD_display_mode)=MARKERS or %upcase(&LD_display_mode)=BOTH) %then %do;
data _ld_snp_anno;
  set manhattan(where=(not missing(_LD_SNP_MARK_)));
  length function $8 text $40 color $16 position $1 style $12;
  retain xsys '2' ysys '2' function 'label' text "&LD_marker_symbol" color "&LD_marker_color"
         position '5' style 'Arial' size 1.6;
  x=Fake_position;
  array _ld_logp_[*] logp logp1-logp%ntokens(&Other_P_vars);
  do _ld_i_=1 to dim(_ld_logp_);
    y=_ld_logp_[_ld_i_];
    if not missing(y) then output;
  end;
  keep x y xsys ysys function text color position style size;
run;
proc append base=anno data=_ld_snp_anno force;
run;
data _ld_snp_legend;
  length function $8 text $40 color $16 position $1 style $12;
  xsys='1'; ysys='1'; x=1; y=98; function='label'; position='6';
  text=cats("&LD_marker_symbol",' High-LD SNP'); color="&LD_marker_color"; style='Arial'; size=1.2;
run;
proc append base=anno data=_ld_snp_legend force;
run;
%end;

%if %length(&LD_r2_values)>0 and
    (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
data _ld_r2_anno;
  set manhattan(where=(not missing(_LD_R2_)));
  length function $8 text $40 color $16 position $1 style $12;
  xsys='2'; ysys='2'; function='label'; text='o'; color=_LD_COLOR_;
  position='5'; style='Arial'; size=1.8; x=Fake_position;
  array _ld_logp_[*] logp logp1-logp%ntokens(&Other_P_vars);
  do _ld_i_=1 to dim(_ld_logp_);
    y=_ld_logp_[_ld_i_]; if not missing(y) then output;
  end;
  keep x y xsys ysys function text color position style size;
run;
proc append base=anno data=_ld_r2_anno force; run;
data _ld_r2_legend;
  length function $8 text $80 color $16 position $1 style $12;
  xsys='1'; ysys='1'; function='label'; position='6'; style='Arial'; size=1.0;
  x=68; y=98; text="&LD_heatmap_legend_title"; color='black'; output;
  x=78; text='o 0-0.5'; color="%scan(&LD_heatmap_colormodel,1,%str( ))"; output;
  x=86; text='o 0.5-0.8'; color="%scan(&LD_heatmap_colormodel,2,%str( ))"; output;
  x=95; text='o 0.8-1'; color="%scan(&LD_heatmap_colormodel,-1,%str( ))"; output;
run;
proc append base=anno data=_ld_r2_legend force; run;
%end;

proc transpose data=manhattan out=manhattan(rename=(col1=logP) drop=_name_);
var logp:;
by &chr_var Fake_position;
run;

*Get the max position for each chr;
proc sql noprint;
select distinct Fake_position into: min_fk_pos separated by ' '
from manhattan
group by &chr_var
having fake_position=min(fake_position);
*Remove the first element in the list;
%select_element_range_from_list( 
list=&min_fk_pos, 
st=2, 
end=%ntokens(&min_fk_pos), 
sublist=new_min_fk_pos, 
sep=%str( ) 
); 


%if "&var_type"="2" or &Keep_order_of_target_SNPs=1 %then %do;

/*Note: the offset setting will make the legend move left when value is negative!*/
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/graphref/p0anvu6ux4d0ijn1mt06fn9yl0wx.htm#p18f31f18e6elan1ge5bb2pjiv34;
*Note: asign empty string for the label of the legend;
legend1 across=10 down=2 repeat=1 label=(height=4 position=top justify=center ' ')
        value=(height=2) shape=symbol(2,2) offset=(1pct)
        position=(bottom center outside);
*The offset=(0,0)cm or offset=(2pct) will affect the left position of the legend;
*See how to customize legend:;
*https://support.sas.com/resources/papers/proceedings/proceedings/forum2007/163-2007.pdf;

%if &sep_chr_grp=1 %then %do; 
%let maxbp=&maxbp &new_min_fk_pos;
%end;

proc gplot data=manhattan;
plot logp*Fake_position=&chr_var 
 /  
                 haxis = axis1
                 vaxis = axis2
                 href  = &maxbp 
                 annotate = anno
                nolegend
		            noframe
/*		         legend=legend1*/
;
%if &Keep_order_of_target_SNPs^=1 %then %do;
format &chr_var Xaxis_var_label.;
%end;
label Fake_position="Groups"
      &chr_var="Legends of groups";
run;

*Also keep a copy of the dataset for further plotting with the macro;
/*
data _tgthits_;
set _tgthits_;
drop tag_snp;
run;
*/

%end;

%else %do;
proc gplot data=manhattan;
plot1 logp*Fake_position=&chr_var
 / 
                 haxis = axis1
                 vaxis = axis2
                 href  = &maxbp
                 annotate = anno
                 nolegend
		         noframe
;
run;
%end;

*This will enable the macro generate one figure by proc gplot in SAS OnDemand for Academics;
*Otherwise, there would be two duplicated Manhattan plots;
/* %return; */
*return does not work, and only quit dose!;
%put After successfully generate manhattan plot, the macro will quit to prevent from two duplicated Manhattan plots printed!;
quit;

%mend;
%macro twocolors(c1,c2);
%do j=1 %to 23 %by 2;
symbol&j v=dot c=&c1;
symbol%eval(&j+1) v=dot c=&c2;
%end;
%mend;
%macro uniqcolors(inputcolors=);

%if %length(&inputcolors)=0 %then %do;
/*https://support.sas.com/content/dam/SAS/support/en/books/pro-template-made-easy-a-guide-for-sas-users/62007_Appendix.pdf*/
*For standard RGB chars generated by inkscape, it is necessary to remove the last two chars ff and put cx at the beginning;
symbol1 v=dot h=&dotsize c=cx0072bd;
symbol2 v=dot h=&dotsize c=cxd95319;
symbol3 v=dot h=&dotsize c=cxedb120;
symbol4 v=dot h=&dotsize c=cx7e2f8e;
symbol5 v=dot h=&dotsize c=cx77ac30;
symbol6 v=dot h=&dotsize c=cx4dbeee;
symbol7 v=dot h=&dotsize c=cxa2142f;
symbol8 v=dot h=&dotsize c=cx0072bd;
symbol9 v=dot h=&dotsize c=cxd95319;
symbol10 v=dot h=&dotsize c=cxedb120;
symbol11 v=dot h=&dotsize c=cx7e2f8e;
symbol12 v=dot h=&dotsize c=cx77ac30;
symbol13 v=dot h=&dotsize c=cx4dbeee;
symbol14 v=dot h=&dotsize c=cxa2142f;
symbol15 v=dot h=&dotsize c=cx0072bd;
symbol16 v=dot h=&dotsize c=cxd95319;
symbol17 v=dot h=&dotsize c=cxedb120;
symbol18 v=dot h=&dotsize c=cx7e2f8e;
symbol19 v=dot h=&dotsize c=cx77ac30;
symbol20 v=dot h=&dotsize c=cx4dbeee;
symbol21 v=dot h=&dotsize c=cxa2142f;
symbol22 v=dot h=&dotsize c=cx0072bd;
symbol23 v=dot h=&dotsize c=cxd95319;

*repeat the symbols until to 46, in case of drawing local manhattan plots with more than 23 groups;
*If there are more than 46 groups, the manhattan plots will be too busy!;
symbol24 v=dot h=&dotsize c=cx0072bd;
symbol25 v=dot h=&dotsize c=cxd95319;
symbol26 v=dot h=&dotsize c=cxedb120;
symbol27 v=dot h=&dotsize c=cx7e2f8e;
symbol28 v=dot h=&dotsize c=cx77ac30;
symbol29 v=dot h=&dotsize c=cx4dbeee;
symbol30 v=dot h=&dotsize c=cxa2142f;
symbol31 v=dot h=&dotsize c=cx0072bd;
symbol32 v=dot h=&dotsize c=cxd95319;
symbol33 v=dot h=&dotsize c=cxedb120;
symbol34 v=dot h=&dotsize c=cx7e2f8e;
symbol35 v=dot h=&dotsize c=cx77ac30;
symbol36 v=dot h=&dotsize c=cx4dbeee;
symbol37 v=dot h=&dotsize c=cxa2142f;
symbol38 v=dot h=&dotsize c=cx0072bd;
symbol39 v=dot h=&dotsize c=cxd95319;
symbol40 v=dot h=&dotsize c=cxedb120;
symbol41 v=dot h=&dotsize c=cx7e2f8e;
symbol42 v=dot h=&dotsize c=cx77ac30;
symbol43 v=dot h=&dotsize c=cx4dbeee;
symbol44 v=dot h=&dotsize c=cxa2142f;
symbol45 v=dot h=&dotsize c=cx0072bd;
symbol46 v=dot h=&dotsize c=cxd95319;
%end;
%else %do;
 %local _ci_ ncls;
 %let ncls=%ntokens(&inputcolors);
 %do _ci_=1 %to &ncls;
    symbol&_ci_ v=dot h=&dotsize c=%scan(&inputcolors,&_ci_,%str( ));
 %end;
%end;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/Multgscatter_with_gene_exons.sas */
%macro Multgscatter_with_gene_exons(
bed_dsd=,/*This input dsd should contain association signals, but not 
for gene bed regions; the name of the var should not be misunderstood!
It should contain the arbitrary vars: chr, st, and end
If the bed_dsd is missing, the macro will use the min and max position from
the gene_exon_bed_dsd as a fake data set to draw track without the scatterplot;
The typical input format of bed_dsd would be:
chr st end grp num_scattergrp num_lattice_scattergrp
the var grp should be character;
*/
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
For SNVs, please assign missing value . to them;
*/
yval_var=,
scatter_grp_var=,
lattice_subgrp_var=,
gene_exon_bed_dsd=,
/*
This input dsd is for exonic bed regions, which should contains the following vars:
chr, st, end, and grp, and these varnames are fixed and used by the internal macro!
Make sure there is only one unique chr included in the gene_exon_bed_dsd when the 1st data set bed_dsd is missing!
The typical input format of gene_exon_bed_dsd would be:
chr st end grp num_scattergrp
grp would be character, such as gene or exon
char_scattergrp would be y-axis values for these genes and it corresponding exons;
*/
dist2st_and_end=50000,
design_width=1000,
design_height=200,
image_dpi=300,
barthickness=20,
dotsize=6,
grp_font_size=8,
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
min_dist4genes_in_same_grps=0.3, 
/*this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
sc_labels_in_order= ,/*Provide scatter names matched with the numeric scatter_grp_var
Use _ to represent blank space in each name, and these _ will be changed back into blank space!*/

/*Note: More parameters included in the sub-macro Lattice_gscatter_over_bed_track 
can be modified to obtain better figures; please just find the sub-macro and
update the default setting for specific parameters to improve the final figure
*/
min_xaxis=,/*These two parameters will restrict the min and max position for xaxis*/
max_xaxis=,
yaxis_offset4min=0.05, /*provide 0-1 value or auto to offset the min of the yaxis*/
yaxis_offset4max=0.05, /*provide 0-1 value or auto or to offset the max of the yaxis*/
yoffset4max_drawmarkersontop=0.15,/*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=,/*Optional visible title naming the plotted color metric.*/
xaxis_offset4min=0.02, /*provide 0-1 value or auto  to offset the min of the xaxis*/
xaxis_offset4max=0.02, /*provide 0-1 value or auto to offset the max of the xaxis*/
shift_text_yval=-0.2, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/


makedotheatmap=1,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/
/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=, /*Optional character variable containing '*' for LD-linked variants.*/
ld_marker_color=black,
ld_marker_legend_symbol=*,
ld_heatmap_var=,
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
ld_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=,
font_size4textlabels=10,
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=0, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=0.25, /*For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 5 top SNPs if track_width between 500 and 800, or 6 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
adj_spaces_among_top_snps=1 /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);

%let missingscatterdsd=0;
%if %length(&bed_dsd)=0 %then %do;
 %put Going to use the ene_exon_bed_dsd to make fake scatterplot dsd;
 %let bed_dsd=fake_bed_dsd;
 proc sql;
 create table &bed_dsd as
 select *
 from &gene_exon_bed_dsd
 group by chr
 having st=min(st) or end=max(end);

 %let missingscatterdsd=1;
 *Also need to create these variables;
 %let yval_var=yval_var;
 %let lattice_subgrp_var=lattice_subgrp_var;
 
 data &bed_dsd;
 set &bed_dsd;
 *Assign yval_var with value 1, these values will be excluded latter by the sub-macro lattice_gscatter;
 *with the parameter NotDrawScatterPlot=&missingscatterdsd;
 &yval_var=1;
 *This variables should be the same types as that from gene_exon_bed_dsd;
 &scatter_grp_var=1;
 *This arbitary group var;
 grp="sc";
 *This variable should be numeric;
 &lattice_subgrp_var=1;
 run;
 *Only keep these common vars, other vars may be conficted with newly generated vars;
 data &gene_exon_bed_dsd;
 set &gene_exon_bed_dsd;
 keep chr st end grp;
 *Need to add the following var and asign negative value;
 *For gene and exon, this var need to be negative;
 &scatter_grp_var=-1;
 run;
%end;


/*proc print data=_last_(obs=10);run;*/

*Note: both the bed_dsd and gene_exon_bed_dsd should have char chromosomes;

/*
%chr_format_exchanger(
dsdin=_last_,
char2num=1,
chr_var=chr,
dsdout=a1);
*/

/*%chr_format_exchanger(
dsdin=x0,
char2num=0,
chr_var=chr,
dsdout=x1);
*/

/*data &gene_exon_bed_dsd;*/
/*set &gene_exon_bed_dsd;*/
/*&scatter_grp_var=-1;*/
/*run;*/

proc sql noprint;
select unique(chr) into: chrs separated by " "
from &bed_dsd;
%put These chromosomes are included in the bed dsd &bed_dsd: &chrs;

%let ci=1;

%do %while (%scan(&chrs,&ci) ne );
   %let _chr_=%scan(&chrs,&ci);
   %put running analysis for chromosome &_chr_;

   proc sql noprint;
   create table bed&_chr_ as
   select * 
   from &bed_dsd
   where chr="&_chr_";
   
   select min(st)-&dist2st_and_end,max(end)+&dist2st_and_end into: min_st,:max_end
   from bed&_chr_;

   create table exon&_chr_ as
   select chr,st,end,grp,
          -1 as &yval_var
   from &gene_exon_bed_dsd
   where chr="&_chr_" and (
         (st<=&min_xaxis and end>=&min_xaxis and end<=&max_xaxis ) or 
         (st>=&min_xaxis and end<=&max_xaxis) or 
         (end>=&max_xaxis and st<=&max_xaxis)
   ); 
*Remove duplicate gene positions, otherwise, these genes will be plotted multiple times in the gene track;
proc sort data=exon&_chr_ nodupkeys out=exon&_chr_ dupout=exondup&_chr_;
by _all_;
run; 

/*  
*Because the min_st and max_end is larger than then the actual disigned &min_xaxis and &max_xaxis;
*There will be more genes included in the output data set, leading to the wrong adjusted gene group number for drawing lattice scatter plot;  
   create table exon&_chr_ as
   select chr,st,end,grp,
          -1 as &yval_var
   from &gene_exon_bed_dsd
   where chr="&_chr_" and (
         (st<=&min_st and end>=&min_st and end<=&max_end ) or 
         (st>=&min_st and end<=&max_end) or 
         (end>=&max_end and st<=&max_end)
   );
 %put min_st is &min_st;
 %put max_end is &max_end;
 */
/*  %let noexon_dsd=0;*/
   %delete_empty_dsd(dsd_in=work.exon&_chr_);
   %if %eval(%sysfunc(exist(work.exon&_chr_))^=1) %then %do;
     %put Warning: no scatter data positions overlapped with exon regions, please enlarge the searching distance if the figure is not generated!;
/*       %abort 255;*/
/*	 %let noexon_dsd=1;*/
	 %put try to add a fake exon ranging from min_st to max_end;
	 data exon&_chr_;
	 set bed&_chr_(obs=1 keep=chr st end grp);
	 &yval_var=-1;
	 *Use this position just for indicating the fact that no genes are in the region;
	 st=&min_xaxis;
	 end=st+1;
	 grp="No gene in the region on &_chr_";
	 run;
   %end;
/*   %abort 255;*/
   /*Only if you want to draw bed track instead of scatter plot for these no gene data points, you can increase the ratio*/         
   %let dist4scatterplot=%sysevalf((&max_end-&min_st)*0.0001,integer);
   %local _effective_gene_dist_thrhd _gene_track_row_count _gene_track_row_retry_count _effective_pct4neg_y _effective_grp_font_size _effective_barthickness _total_gene_label_count _target_gene_track_rows;
   %let _effective_gene_dist_thrhd=&min_dist4genes_in_same_grps;
   %let _effective_pct4neg_y=&pct4neg_y;
   %let _effective_grp_font_size=&grp_font_size;
   %let _effective_barthickness=&barthickness;

   proc sql noprint;
   select count(distinct grp) into: _total_gene_label_count trimmed
   from exon&_chr_
   where not missing(grp);
   quit;
   %if %superq(_total_gene_label_count)= %then %let _total_gene_label_count=1;
   %let _target_gene_track_rows=%sysfunc(max(1,%sysfunc(min(24,%sysfunc(ceil(%sysevalf(&_total_gene_label_count/2.5)))))));

   *By asigning ngrp=-1, all gene tracks will be put under the refline y=0;
			*This will asign the negative value -1 to gene grps and draw them together on a single line;
   /*data exon&_chr_;set exon&_chr_;&yval_var=-1;run;*/

			*This will asign different negative values to gene grps and draw them separately;
			proc sort data=exon&_chr_;by grp;run;

/* 			data exon&_chr_; */
/* 			retain &yval_var 0; */
/* 			*Make sure to drop the &yval_var from the dsd, otherwise, the retain and if condition will not work; */
/* 			set exon&_chr_ (drop=&yval_var); */
/* 			*Draw all genes into separated lines, but these exons may be draw into single lines, too?; */
/* 			*if first.grp then &yval_var=&yval_var-1; */
/*             *Draw all genes in a single line; */
/*             if first.grp then &yval_var=-1; */
/* 			output; */
/* 			by grp; */
/* 			run; */
*Use a macro to asign yval_var by separating genes too close to each other;
*reg_type and focused_reg_type4grouping can be omitted if wanting to use the longest region as gene;
/*%abort 255;*/
   %adj_grpnum4close_gene_bed_regs(
   gene_bed_dsd=exon&_chr_,
   st_var=st,
   end_var=end,
   reg_type=,
   focused_reg_type4grouping=,
   gene_grp=grp,
   gene_dist_thrhd=&_effective_gene_dist_thrhd,
   dsdout=exon&_chr_,
   outnumgrp=_numgrp_
   );
   proc sql noprint;
   select max(_numgrp_) into: _gene_track_row_count trimmed
   from exon&_chr_;
   quit;
   %if %superq(_gene_track_row_count)= %then %let _gene_track_row_count=1;
   %let _gene_track_row_retry_count=0;
   %do %while (%sysevalf(%superq(_gene_track_row_count) < %superq(_target_gene_track_rows)) and %sysevalf(%superq(_effective_gene_dist_thrhd) >= 0) and &_gene_track_row_retry_count < 5);
      %let _gene_track_row_retry_count=%eval(&_gene_track_row_retry_count+1);
      %if %sysevalf(&_effective_gene_dist_thrhd>1) %then %do;
        %let _effective_gene_dist_thrhd=%sysfunc(int(%sysevalf(&_effective_gene_dist_thrhd*1.6)));
      %end;
      %else %do;
        %let _effective_gene_dist_thrhd=%sysevalf(%sysfunc(min(0.95,%sysevalf(&_effective_gene_dist_thrhd*1.5))));
      %end;
      %put NOTE: Dense gene labeling detected on &_chr_ with &_total_gene_label_count genes and &_gene_track_row_count rows, retry &_gene_track_row_retry_count with gene_dist_thrhd=&_effective_gene_dist_thrhd target_rows=&_target_gene_track_rows.;
      %adj_grpnum4close_gene_bed_regs(
      gene_bed_dsd=exon&_chr_,
      st_var=st,
      end_var=end,
      reg_type=,
      focused_reg_type4grouping=,
      gene_grp=grp,
      gene_dist_thrhd=&_effective_gene_dist_thrhd,
      dsdout=exon&_chr_,
      outnumgrp=_numgrp_
      );
      proc sql noprint;
      select max(_numgrp_) into: _gene_track_row_count trimmed
      from exon&_chr_;
      quit;
      %if %superq(_gene_track_row_count)= %then %let _gene_track_row_count=1;
   %end;
   %if %sysevalf(%superq(_gene_track_row_count) < %superq(_target_gene_track_rows)) %then %do;
      %put NOTE: Applying round-robin gene-row expansion on &_chr_ to reach target_rows=&_target_gene_track_rows while keeping all labels.;
      proc sql;
        create table exon&_chr_._row_seed as
        select grp,
               min(st) as grp_st,
               max(end) as grp_end,
               mean((st+end)/2) as grp_mid
        from exon&_chr_
        group by grp
        order by calculated grp_mid, calculated grp_st, grp
        ;
      quit;
      data exon&_chr_._row_seed;
        set exon&_chr_._row_seed;
        _target_numgrp_=mod(_n_-1,&_target_gene_track_rows)+1;
      run;
      proc sort data=exon&_chr_;
        by grp st end;
      run;
      proc sort data=exon&_chr_._row_seed;
        by grp;
      run;
      data exon&_chr_;
        merge exon&_chr_(in=a) exon&_chr_._row_seed(keep=grp _target_numgrp_);
        by grp;
        if a;
        _numgrp_=_target_numgrp_;
        drop _target_numgrp_;
      run;
      %let _gene_track_row_count=&_target_gene_track_rows;
   %end;
   %if %sysevalf(%superq(_gene_track_row_count) > 24) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,7.0));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(3,%sysevalf(&_effective_barthickness-5)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 18) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,5.8));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(4,%sysevalf(&_effective_barthickness-4)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 12) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,4.6));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(4,%sysevalf(&_effective_barthickness-3)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 8) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,3.6));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,7));
      %let _effective_barthickness=%sysfunc(max(5,%sysevalf(&_effective_barthickness-3)));
   %end;
   %put NOTE: Final gene-track layout on &_chr_: genes=&_total_gene_label_count rows=&_gene_track_row_count target_rows=&_target_gene_track_rows gene_dist_thrhd=&_effective_gene_dist_thrhd pct4neg_y=&_effective_pct4neg_y grp_font_size=&_effective_grp_font_size barthickness=&_effective_barthickness.;
/*%abort 255;*/
   *Asign negative value to &yval_var;
   *Note: the above macro can not output the var outnumgrp with the same name of &yval_var in the table exon&_chr_;
   data exon&_chr_(drop=_numgrp_);
   set exon&_chr_;
   &yval_var=-1*_numgrp_;
   run;
			
   data _x1_;
   set bed&_chr_ exon&_chr_;
			*enlarge the dist between st and end, which will make the square visible in scatter plot; 
/*			st=st-&dist4scatterplot;*/
			if st<0 then st=0;
/*			end=end+&dist4scatterplot;*/
   run;

		

			*Fix a bug here;
			*Need to asign -1 for all groups of &yval_var;
			*such as &yval_var1,&yval_var2, and so on;
			*If not fix the bug, these missing groups will be ploted at the bottern of each subplot;
		 data _x1_;
			set _x1_;
			*No need to process these data when missingscatterdsd is true;
			%if &missingscatterdsd=0 %then %do;
			array Y{*} &yval_var.:;
			do yi=1 to dim(Y);
			   if Y{yi}=. then Y{yi}=-1;
			end;
			drop yi;
			%end;
			if &scatter_grp_var=. then &scatter_grp_var=-1;
			run;

	
   /*proc print;run;*/
   *options nonotes;
   *old macro %bed_region_plot_by_grp, which is slow!;
   *Use the new macro by plotting scatter plot;
   *There are many more parameters with default settings are not;
   *listed out for the following macro, and it is easy to the change;
   *them for better visualization in the final figure;
    %let yaxislabel=&scatter_yaxis_label;
    *remove yaxis label when setting of NotDrawScatterPlot is true;
    %if &missingscatterdsd=1 %then %let yaxislabel=;
/*	%abort 255;*/
    %Lattice_gscatter_over_bed_track(
    bed_dsd=_x1_,
    chr_var=chr,
    st_var=st,
    end_var=end,
    Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!*/
    grp_var=grp,
    scatter_grp_var=&scatter_grp_var,
    lattice_subgrp_var=&lattice_subgrp_var,
    yval_var=&yval_var,
    yaxis_label=&yaxislabel,
    linethickness=&_effective_barthickness,
    track_width=&design_width,
    track_height=&design_height,
    image_dpi=&image_dpi,
    dist2st_and_end=&dist2st_and_end,
    dotsize=&dotsize,
    grp_font_size=&_effective_grp_font_size,
	/*Important parameters for drawing SNVs and CNVs together*/
    scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
   highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
    ordered_sc_grpnames=&sc_labels_in_order,
    NotDrawScatterplot=&missingscatterdsd,
    xaxis_viewmin=&min_xaxis,/*arbitrary xaxis min value to show the figure, and it requires to work with thresholdmin=0*/
    xaxis_viewmax=&max_xaxis,/*arbitrary xaxis max vale to show the figure, and it requires to go along with thresholdmax=0*/
    yaxis_offset4min=&yaxis_offset4min, /*provide 0-1 value or auto to offset the min of the yaxis*/
    yaxis_offset4max=&yaxis_offset4max, /*provide 0-1 value or auto or to offset the max of the yaxis*/
    yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop,/*If draw scatterplot marker labels on the top of track, 
    this fixed value will be used instead of yaxis_offset4max!*/
      Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
      heatmap_legend_title=&heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
      plot_title=&plot_title,
      xaxis_offset4min=&xaxis_offset4min, /*provide 0-1 value or auto  to offset the min of the xaxis*/
    xaxis_offset4max=&xaxis_offset4max, /*provide 0-1 value or auto to offset the max of the xaxis*/

  shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
  fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
  pct4neg_y=&_effective_pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
  adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

 makedotheatmap=&makedotheatmap,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/
/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=&heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=&heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

 makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
 var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/ 
 var4mark_ld_scatterplot_dots=&var4mark_ld_scatterplot_dots,
 ld_marker_color=&ld_marker_color,
 ld_marker_legend_symbol=&ld_marker_legend_symbol,
 ld_heatmap_var=&ld_heatmap_var,
 ld_heatmap_colormodel=&ld_heatmap_colormodel,
 ld_heatmap_legend_title=&ld_heatmap_legend_title,
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=&pct2adj4dencluster,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
    );
  
   *options notes;
%let ci=%eval(&ci+1);
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/OpenSVG_Printer.sas */
%macro OpenSVG_Printer(
filename=mysvgfilename,
svgfileref=out,
other_paras4ods_graphics=%str( ),
outdir=,/*output svg to the dir; if empty, it will save it 
into the dir %sysfunc(pathname(HOME));*/
);

*In Windows, due to sysfunc(pathname(HOME)) only works in Linux;
*the SVG will be failed to be written into the SAS installation dir;
*To address the issue, change the dir into working dir;
%if &sysscp=WIN %then %do;
data _null_;
rx=dlgcdir("%sysfunc(getoption(work))");
run;
%end;
%else %if %length(&outdir)=0 %then %do;
data _null_;
rx=dlgcdir("%sysfunc(pathname(HOME))");
run;
%end;

*Check whether the svg exist;
*add appendix to it to not overwrite previous svg;
%let fi=1;
%let oldname=&filename;
%do %while (%FileOrDirExist(%sysfunc(pathname(HOME))/&filename..svg)=1);
  %put rename your svg output filename as:;
  %let filename=&oldname._&fi;
  %put &filename;
  %let fi=%eval(&fi+1);
%end;

options printerpath=(svg &svgfileref) nobyline;
filename out "&filename..svg";
ods listing close;
ods printer;
ods graphics on/outputfmt=svg
&other_paras4ods_graphics;

%if &sysscp=WIN %then %do;
data _null_;
rx=dlgcdir("%sysfunc(getoption(work))");
run;
%end;
%else %do;
data _null_;
rx=dlgcdir("%sysfunc(pathname(HOME))");
run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/QQplot.sas */
%macro QQplot(dsdin,P_var);
proc sql noprint;
select count(*) into: tot
from &dsdin;

data &dsdin;
set &dsdin;
where &P_var>0;

*sort and exclude these missing P values;
proc sort data=&dsdin;
by &P_var;
run;

data dataout;
set &dsdin;
retain x_;
gap=1/&tot;
ini=gap/2;
if _n_=1 then x_=ini;
else x_=x_+gap;
x=-log10(x_);
y=-log10(&P_var);
run;


proc sql noprint;
select ceil(max(y)) into: max_y
from dataout;

*Adjust the tick number when the &max_y>10;
%let step=1;
%if &max_y>=20 %then %do;
  %let step=5;
  *Update the max_y can be divided by 5;
  %let max_y=%sysevalf(%sysevalf(&max_y/5,ceil)*5);
%end;

/*make sure to put reset here*/
/*otherwise symbol2 will not work*/
goptions reset=global hsize=15cm vsize=15cm;
symbol1 interpol=none value=dot color=maroon;
symbol2 interpol=rl value=none color=black;
%let fontsize=3;
axis1 label=(f='arial' h=&fontsize 'Expected -log10(P)' justify=c)
      order=(0 to &max_y by &step) value=(f='arial' h=&fontsize);
axis2 label=(a=90 f='arial' h=&fontsize 'Observed -log10(P)')
      order=(0 to &max_y by &step) value=(f='arial' h=&fontsize);
proc gplot data=dataout;
plot y*x x*x/overlay 
           haxis=axis1
           vaxis=axis2
           noframe;
run;

*Also make a QQ plot with x- and y-axis with the same scale and maximum value of 8;
goptions reset=global hsize=15cm vsize=15cm;
symbol1 interpol=none value=dot color=maroon;
symbol2 interpol=rl value=none color=black;
%let fontsize=3;
axis1 label=(f='arial' h=&fontsize 'Expected -log10(P)' justify=c)
      order=(0 to 8 by 1) value=(f='arial' h=&fontsize);
axis2 label=(a=90 f='arial' h=&fontsize 'Observed -log10(P)')
      order=(0 to 8 by 1) value=(f='arial' h=&fontsize);
proc gplot data=dataout;
plot y*x x*x/overlay 
           haxis=axis1
           vaxis=axis2
           noframe;
run;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/QueryLD_SNPs_at_Haploreg4.sas */
%macro QueryLD_SNPs_at_Haploreg4(
  snp=rs2564978,
  LDpop=EUR,
  ldThresh=0.7,
  outdsd=LD_dsd
);
%local query_str _http_status _has_rsid _has_r2 _n_rows _out_lib _out_mem _response_bytes _response_records
       _cache_min _cache_action _cache_self_n;
%global HAPLOREG_LD_HTTP_STATUS HAPLOREG_LD_QUERY_OK HAPLOREG_LD_QUERY_SOURCE
        HAPLOREG_LD_CACHE_DSD HAPLOREG_LD_CACHE_MIN_R2 HAPLOREG_LD_CACHE_MISS_ACTION;
%let HAPLOREG_LD_HTTP_STATUS=;
%let HAPLOREG_LD_QUERY_OK=0;
%let HAPLOREG_LD_QUERY_SOURCE=NONE;
%if %sysfunc(countw(%superq(outdsd),.))>1 %then %do;
  %let _out_lib=%scan(%superq(outdsd),1,.);
  %let _out_mem=%scan(%superq(outdsd),-1,.);
%end;
%else %do;
  %let _out_lib=WORK;
  %let _out_mem=&outdsd;
%end;

/*
Optional local cache. The cache is a long table with QUERY_SNP, PROXY_SNP,
LD_POPULATION, PROXY_R2, and CACHE_MIN_R2. It can be produced by
extract_haploreg_ld_for_candidates.pl from the official downloadable archives.
Archive data are available only from r2=0.2 upward; a cache is never used for a
lower requested cutoff. A cache miss falls back to the web query by default.
*/
%let _cache_action=%upcase(%sysfunc(strip(%superq(HAPLOREG_LD_CACHE_MISS_ACTION))));
%if %sysevalf(%superq(_cache_action)=,boolean) %then %let _cache_action=WEB;
%let _cache_min=%sysfunc(inputn(%superq(HAPLOREG_LD_CACHE_MIN_R2),best32.));
%if %sysevalf(%superq(_cache_min)=,boolean) %then %let _cache_min=0.2;

%if not %sysevalf(%superq(HAPLOREG_LD_CACHE_DSD)=,boolean)
    and %sysfunc(exist(%superq(HAPLOREG_LD_CACHE_DSD))) %then %do;
  %if %sysevalf(&ldThresh >= &_cache_min) %then %do;
    data &outdsd;
      length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
      set &HAPLOREG_LD_CACHE_DSD;
      where query_snp=upcase("&snp")
        and ld_population=upcase("&LDpop")
        and proxy_r2 >= &ldThresh;
      query_snp_rsid="&snp";
      rsID=strip(proxy_snp);
      r2=proxy_r2;
      chr='';
      pos_hg38=.;
      keep query_snp_rsid rsID chr pos_hg38 r2;
    run;
    proc sql noprint;
      select count(*) into :_cache_self_n trimmed
      from &outdsd
      where upcase(strip(rsID))=upcase("&snp");
    quit;
    %if %sysevalf(%superq(_cache_self_n)=,boolean) %then %let _cache_self_n=0;
    %if &_cache_self_n>0 %then %do;
      %let HAPLOREG_LD_HTTP_STATUS=LOCAL_CACHE;
      %let HAPLOREG_LD_QUERY_OK=1;
      %let HAPLOREG_LD_QUERY_SOURCE=LOCAL_CACHE;
      %put NOTE: HaploReg LD cache hit snp=&snp population=&LDpop threshold=&ldThresh cache=&HAPLOREG_LD_CACHE_DSD.;
      %return;
    %end;
    %put WARNING: HaploReg LD cache miss for &snp population=&LDpop.;
    %if &_cache_action ne WEB %then %do;
      %let HAPLOREG_LD_HTTP_STATUS=CACHE_MISS;
      %let HAPLOREG_LD_QUERY_SOURCE=LOCAL_CACHE_MISS;
      %return;
    %end;
  %end;
  %else %put WARNING: Ignoring HaploReg LD cache because requested r2=&ldThresh is below cache minimum r2=&_cache_min.;
%end;

%let query_str=%nrstr(&query=)&snp%nrstr(&ldThresh=)&ldThresh%nrstr(&ldPop=)&LDpop%nrstr(&output=text&submit=submit);
%let HAPLOREG_LD_QUERY_SOURCE=WEB;

filename hap temp lrecl=1000000000;
proc http
  url="https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php/post"
  method="POST"
  in="&query_str"
  out=hap
  ct='application/x-www-form-urlencoded';
run;

%let _http_status=&SYS_PROCHTTP_STATUS_CODE;
%let HAPLOREG_LD_HTTP_STATUS=&_http_status;

%if %sysevalf(%superq(_http_status)=,boolean)
    or %sysevalf(&_http_status < 200)
    or %sysevalf(&_http_status >= 400) %then %do;
  %put WARNING: HaploReg LD query failed for &snp population=&LDpop HTTP=&_http_status.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

%let _response_bytes=0;
data _null_;
  length _size_text $64;
  _fid=fopen('hap');
  if _fid>0 then do;
    _size_text=finfo(_fid,'File Size (bytes)');
    call symputx('_response_bytes',input(compress(_size_text,,'kd'),best32.),'L');
    _rc=fclose(_fid);
  end;
run;
%if %sysevalf(%superq(_response_bytes)=,boolean) %then %let _response_bytes=0;
%if %sysevalf(&_response_bytes <= 0) %then %do;
  %put WARNING: HaploReg returned an empty response for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

/*
PROC IMPORT writes a fatal-looking ERROR when HaploReg returns only a blank
line or a header without data.  Count nonblank records first so an expected
"no LD response" is represented by an empty data set and audit status instead
of poisoning an otherwise successful SAS ODA job log.
*/
%let _response_records=0;
data _null_;
  infile hap lrecl=32767 truncover end=_eof;
  input;
  if not missing(_infile_) then _n_nonblank+1;
  if _eof then call symputx('_response_records',_n_nonblank,'L');
run;
%if %sysevalf(%superq(_response_records)=,boolean) %then %let _response_records=0;
%if %sysevalf(&_response_records < 2) %then %do;
  %put WARNING: HaploReg returned no tabular LD rows for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

proc import datafile=hap dbms=tab out=&outdsd replace;
  getnames=yes;
  guessingrows=max;
run;
filename hap clear;

%if not %sysfunc(exist(&outdsd)) %then %do;
  %put WARNING: HaploReg returned no importable table for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  %return;
%end;

proc sql noprint;
  select sum(upcase(name)='RSID'),
         sum(upcase(name)='R2')
    into :_has_rsid trimmed,
         :_has_r2 trimmed
  from dictionary.columns
  where libname=upcase("&_out_lib")
    and memname=upcase("&_out_mem")
  ;
quit;

%if %sysevalf(%superq(_has_rsid)=,boolean) %then %let _has_rsid=0;
%if %sysevalf(%superq(_has_r2)=,boolean) %then %let _has_r2=0;

%if &_has_rsid=0 or &_has_r2=0 %then %do;
  %put WARNING: HaploReg response for &snp population=&LDpop lacks rsID or r2 columns.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  %return;
%end;

data &outdsd;
  length query_snp_rsid $128;
  set &outdsd(drop=query_snp_rsid);
  query_snp_rsid="&snp";
run;

proc sql noprint;
  select count(*) into :_n_rows trimmed
  from &outdsd
  where upcase(strip(rsID))=upcase("&snp")
  ;
quit;
%if %sysevalf(%superq(_n_rows)=,boolean) %then %let _n_rows=0;
%if %sysevalf(&_n_rows > 0) %then %let HAPLOREG_LD_QUERY_OK=1;

%put NOTE: HaploReg LD query snp=&snp population=&LDpop threshold=&ldThresh HTTP=&_http_status query_ok=&HAPLOREG_LD_QUERY_OK.;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/RandBetween.sas */
%macro RandBetween(min, max);
%local min max rnd _unif_num_ _rnd_;
%let _unif_num_=%sysfunc(ranuni(0));
%let _rnd_=%sysevalf((1+&max-&min)*&_unif_num_);
%let rnd=%sysfunc(floor(&_rnd_));
&rnd
%mend;


/* Source companion/research/advanced_figures/sources/definitions/Rename_Del_Rgx4All_Vars.sas */
%macro Rename_Del_Rgx4All_Vars(indsd,Rgx);
%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
proc sql noprint;
create table temp as 
select name,label,format
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA";
data temp;
set temp;
newname=prxchange("s/&Rgx//",-1,name);
run;

proc sql noprint;
   select count(*) into :n from temp
   where prxmatch("/&Rgx/",name);

%if &n>0 %then %do;
proc sql noprint;
   select cat('rename ',strip(name),
              '= ',strip(newname),';')
      into :l1 - %sysfunc(compress(:l&n))
      from temp
   where prxmatch("/&Rgx/",name);
quit;

proc datasets lib=&dsd_lib nolist;
modify &dsd_name;
   %do i = 1 %to &n; 
     &&l&i 
   %end;
run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/SNP_Local_Manhattan_With_GTF.sas */
%macro SNP_Local_Manhattan_With_GTF(
/*Note: this macro can draw CNVs and SNVs together. Please ensure the macro variable
Variant_Length_Var is not empty, which contains distance of these CNVs (>1), with non-CNVs
assigned with missing value, and the middle positions of these CNVs is required to be 
combined with that of SNVs and gene tracks!

Tip 1: when there gene labels are cluttered within the gene track, it is feasible to 
resolve the issue by increasing the values for either variable pct4neg_y or dist2sep_genes or both!
such as pct4neg_y and dist2sep_genes=1000000; alternatively, it also possible to address the problem
by increase the width of figure, such as assigning larger value to the macro variable track_width=800.

  Tip 2: the figure width and height should ideally set around 500 and no less then 300 or greater than
1000, as large figures are not good for publication purpose! 

  Tip 3: For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!

 Tip 4: dist_pct_to_cluster_pos and pct2adj4dencluste (0.0001 to ~) can affect the top SNP labels positions when there are <= 3 or 4, or 5 SNP labels, as the its value
dist_pct_to_cluster_pos will be internally replaced as 0.5/total number of top SNPs, and pct2adj4dencluste will be changed differently
when make_even_pos=1, the macro will multiple the amplification_fc with 10*pct2adj4dencluster to further enlarge the even distance among positions; 
while if make_even_pos=0, it is useful when elements within a cluster is overlapped with each other or overlapped with elements from other cluster, 
so it is also feasible to avoid this issue by increasing or reducing the pct.

 Tip 5: In default, the scatterplot will use the transformed values of all variables inclued in the macro variable
ZscoreVars into a variable for the lattice_subgrp_var to color dots differently across different scatter groups; User can supply
an independent variable represented by the macro variable color_resp_var to color scatter plot dots but different scattergroups
will be applied in a union style! 
*/

/*
As this macro use other sub-macros, it is not uncommon that some global macro
vars would be in the same name, such as macro vars chr and i, thus, to avoid of crash, 
chr_var is used instead of macro var chr in this macro;*/
/*
Important: there are many other parameters of the sub-macro Lattice_gscatter_over_bed_track,
which can be modified by changing the default values for them to improve the quality of final produced figure!
*/

focus_on_transcript=0,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/
gwas_dsd=,
chr_var=chr,
AssocPVars=pval1 pval2,
SNP_IDs=rs370604612 rs2070788 9:5114773,
/*if providing chr:pos or chr:st:end, it will query by pos;
Please also enlarge the dist2snp to extract the whole gene body and its exons,
although the final plots will be only restricted by the input start and end positions!*/
dist2snp=2000000,
chromosome_lengths=,/*Comma-separated lengths for chromosomes 1-22, X, Y in the GWAS build.*/
/*assign value in bp, and the final figure will be add extend this distance for both start and end positions*/
SNP_Var=snp,
Pos_Var=pos,
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
gtf_dsd=FM.GTF_HG19,
ZscoreVars=zscore1 zscore2,/*Can be beta1 beat2 or other numberic vars indicating assoc or other +/- directions,
the values of which can be used to color scatter plots of association signals specifically for its corresponding scatter
plot group membership for the following gwas labels. Please ensure makedotheatmap=1 and the input zscoreVars 
are in the same type of variable that can be used properly along with the heatmap feature*/ 
gwas_labels_in_order=gwas1 gwas2,/*If providing _ for labeling each GWAS, 
the _ will be replaced with empty string, which is useful when wanting to remove gwas label 
if only one scatterplot or the label for a gwas containing spaces;
The list will be used to label scatterplots 
by the sub-macro map_grp_assoc2gene4covidsexgwas*/
design_width=500,/*Best width for publication, and usually used width rangs from 400 to 800*/ 
design_height=500,/*Best height for publication, and usally used height rangs from 400 to 800*/
image_dpi=300,/*Raster output DPI; the SAS ODA wrapper uses 150 to limit Java memory.*/
barthickness=10, /*gene track bar thinkness*/
dotsize=6,/*scatter data point size for the following macro variable scattermarker_symbol*/
grp_font_size=8,/*font size for gene labels in the bottom gene track*/

/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/

dist2sep_genes=100000,/*Distance to separate close genes into different rows in the gene track; provide negative value or 0
to have all genes in a single row in the final gene track
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 or negative value to plot ALL genes in the same line;
(2) give value >0 and <1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
where_cndtn_for_gwasdsd=%str(), /*where condition to filter input gwas_dsd*/

shift_text_yval=0.1, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=png, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.2, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
makedotheatmap=1,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot
Note: the macro is updated to use heatmap to illustrate positve and negative values
of scatter plot represented by the variable ZscoreVars in the sub macros
map_grp_assoc2gene4covidsexgwas=>Multgscatter_with_gene_exons (HERE inside the 1st submacro) 
=>Lattice_gscatter_over_bed_track, and you can see the details by reading the 
parameters for  the 2nd sub macro used by the 1st sub mcro;
Set it as 0 to use binary mode to color the negative and postive values in scatter plot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=AssocGrp,/*This variable is generated by transposing all ZscoreVars into a long format internally by the macro,
thus, do not change this macro variable, just update ZscoreVars accordingly; the macro uses this var to draw scatter plot in heatmap
with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/

color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots= ,/*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
the variable should contain values of target SNPs and other non-targets are asigned with empty values;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
SNPs2label_scatterplot_dots=, /*Add multiple SNP rsids to label dots within or at the top of scatterplot
Note: if this parameter is provided, it will replace the parameter var4label_scatterplot_dots!
If there are too much space on the top for these SNP labels, please manually change default value of
the macro variable yoffset4max_drawmarkersontop included in the macro Lattice_gscatter_over_bed_track
 from 0.2 to a smaller value, such as 0.1;
*/
LD_SNPs2mark_scatterplot_dots=, /*Optional space-delimited LD-linked SNPs overlaid with the selected marker on every association track.*/
LD_marker_symbol=*, /*Marker text for LD-linked SNPs: *, +, x, o, s, ^, or d.*/
LD_marker_color=black, /*SAS color name or CXrrggbb value for LD-linked SNP markers.*/
LD_r2_values=, /*Space-delimited SNP:r2 pairs used by the optional LD heatmap overlay.*/
LD_r2_var=LD_R2, /*Numeric LD column uploaded with the GWAS plotting dataset.*/
LD_reference_snp=, /*Explicit LD reference SNP; falls back to the first labeled SNP when omitted.*/
LD_display_mode=none, /*none, markers, heatmap, or both. LD display is opt-in.*/
LD_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F, /*Retained for legacy marker-overlay mode.*/
LD_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=, /*Optional SNP=BP list computed before SAS to avoid label collisions.*/
font_size4textlabels=10, /*Actual text size used by the Perl label planner and SAS renderer.*/
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=1, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
pct2adj4dencluster=2,/*Input value can be ranging from 0.0001 to 10 or even higher value!
For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=0.25, /*If draw scatterplot marker labels on the top of track, 
 this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
adj_spaces_among_top_snps=1,/*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
verbose=0 /*Not print any notes in SAS log*/
);

%local effective_ld_marker_var effective_ld_heatmap_var effective_heatmap_legend_title effective_plot_title _chrom_end_for_window;
%let effective_ld_marker_var=;
%let effective_ld_heatmap_var=;
%let effective_heatmap_legend_title=&heatmap_legend_title;
 
%*It is better to output these notes into the log for AI; 
%*However, too large number of notes will slow down the pipeline dramatically;
%*Thus, we will only print these notes when verbose=1;
%if &verbose=0 %then %do;
%put To prevent too many notes printed in the SAS log, we will enable options nonotes;
options nonotes;
%end;


*Note: the macro map_grp_assoc2gene4covidsexgwas requires the input dsd contain the var chr;
%if "&chr_var"^="chr" %then %do;
data &gwas_dsd;
set &gwas_dsd;
chr=&chr_var;
run;
%end;

*Add a compact star-overlay variable for LD-linked SNPs.;
%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and
    (%upcase(&LD_display_mode)=MARKERS or %upcase(&LD_display_mode)=BOTH) %then %do;
 %let effective_ld_marker_var=_LD_SNP_MARK_;
 data &gwas_dsd;
 set &gwas_dsd;
 length _LD_SNP_MARK_ $8.;
 _LD_SNP_MARK_="";
 %do _li_=1 %to %ntokens(&LD_SNPs2mark_scatterplot_dots);
   if &SNP_Var="%scan(&LD_SNPs2mark_scatterplot_dots,&_li_,%str( ))" then _LD_SNP_MARK_="&LD_marker_symbol";
 %end;
 run;
%end;

*Add a numeric r2 overlay variable from the uploaded LD_R2 column.;
%if (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
 %let effective_ld_heatmap_var=_LD_R2_;
 data &gwas_dsd;
 set &gwas_dsd;
 _LD_R2_=&LD_r2_var;
 %let _ld_reference_snp_=&LD_reference_snp;
 %if %length(&_ld_reference_snp_)=0 %then %let _ld_reference_snp_=%scan(&SNPs2label_scatterplot_dots,1,%str( ));
 %if %length(&_ld_reference_snp_)=0 %then %let _ld_reference_snp_=%scan(&SNP_IDs,1,%str( ));
 if missing(_LD_R2_) and upcase(&SNP_Var)=upcase("&_ld_reference_snp_") then _LD_R2_=1;
 %if %length(%superq(LD_r2_values))>0 %then %do;
   %do _li_=1 %to %ntokens(&LD_r2_values);
     %let _ld_pair_=%scan(&LD_r2_values,&_li_,%str( ));
     if upcase(&SNP_Var)=upcase("%scan(&_ld_pair_,1,%str(:))") then
       if missing(_LD_R2_) then _LD_R2_=input("%scan(&_ld_pair_,2,%str(:))",best32.);
   %end;
 %end;
 run;
 %let effective_signed_r2=1;
 %let effective_ld_heatmap_var=;
%end;
%else %let effective_signed_r2=0;
%let effective_zscore_vars=&ZscoreVars;
%let effective_heatmap_min_neg_val=&heatmap_min_neg_val;
%let effective_heatmap_max_pos_val=&heatmap_max_pos_val;
%if &effective_signed_r2=1 %then %do;
  %let effective_zscore_vars=;
  data &gwas_dsd;
  set &gwas_dsd;
  %do _zi_=1 %to %sysfunc(countw(&ZscoreVars));
    _SIGNED_R2_&_zi_=0;
    if not missing(_LD_R2_) then do;
      if %scan(&ZscoreVars,&_zi_) < 0 then _SIGNED_R2_&_zi_=-_LD_R2_;
      else if %scan(&ZscoreVars,&_zi_) > 0 then _SIGNED_R2_&_zi_=_LD_R2_;
    end;
  %end;
  run;
  %do _zi_=1 %to %sysfunc(countw(&ZscoreVars));
    %let effective_zscore_vars=&effective_zscore_vars _SIGNED_R2_&_zi_;
  %end;
  %let effective_heatmap_min_neg_val=-1;
  %let effective_heatmap_max_pos_val=1;
  %let effective_heatmap_legend_title=&LD_heatmap_legend_title;
%end;

*Add labels for target SNPs if they exist;
%if %length(&SNPs2label_scatterplot_dots)>0 %then %do;
 %let var4label_scatterplot_dots=_Target_SNP_;
data &gwas_dsd;
set &gwas_dsd;
length _Target_SNP_ $25.;
 _Target_SNP_="";
 %do _si_=1 %to %ntokens(&SNPs2label_scatterplot_dots);
    if &SNP_Var="%scan(&SNPs2label_scatterplot_dots,&_si_,%str( ))" then _Target_SNP_=&SNP_Var;
 %end;
run;
%end;

%do snpi=1 %to %ntokens(&SNP_IDs);
  *query SNP using the index snpi (do not use i that may interupt with other macro var i used other sub-macros!);
  %let qsnp=%scan(&SNP_IDs,&snpi,%str( ));
   %if %sysfunc(countc(&qsnp,%str(:)))=1 %then %do;
      *Manually add the start position as end position when the input is in the format of chrNum:Pos!;
      %let qsnp=%sysfunc(prxchange(s/^([^:]+):(\d+)/$1:$2:$2/,-1,&qsnp));
   %end;
  *determine whether input snp is a chrpos based markder;
  %if %sysfunc(prxmatch(/:/,&qsnp)) %then %do;
    %let qsnp=%sysfunc(prxchange(s/chr//i,-1,&qsnp));
    %let chrposquery=1;
    %let num_chr=%scan(&qsnp,1,%str(:));
    %let tgt_pos=%scan(&qsnp,2,%str(:));
    
    %let st_pos=%sysevalf(&tgt_pos-&dist2snp);
    %let end_pos=%sysevalf(&tgt_pos+&dist2snp);
    
    %if %sysfunc(countc(&qsnp,%str(:)))>1 %then %do;
     /*To keep the proc sql codes consistant for creating macros vars of minst and maxend;
     The position range need to be adjusted by dist2snp, because the proc sql command
     will substract and add the dist2snp to the st and end positions; By adding and substracting
     the dist2snp from st and end position, respectively, the final minst and maxend will
     be the same as the input st and end positions!*/
     %if &dist2snp<50000000 %then %do;
      %let st_pos=%sysevalf(%scan(&qsnp,2,%str(:)) - 50000000);
      %let end_pos=%sysevalf(%scan(&qsnp,3,%str(:)) + 50000000);
     %end;
     %else %do;
      %let st_pos=%sysevalf(%scan(&qsnp,2,%str(:)) - &dist2snp);
      %let end_pos=%sysevalf(%scan(&qsnp,3,%str(:)) + &dsdt2snp);    
     %end;
    %end;
    
  %end;
  %else %do;
    %let chrposquery=0;
    %if %sysfunc(prxmatch(/^rs/i,&qsnp)) and &dist2snp<10000 %then %do;
      %put Please be noted that your query SNP is rsid (&qsnp);
      %put It is necessary to expand the searching region > +/-10kb to get genes that cover the variant and specific genes!;
      %abort 255;
    %end;
  %end;
  
  title "Query SNP is &qsnp";
  proc sql noprint;
  select &chr_var,&SNP_Var,minst,maxend
  into: chr,:snp,:minst,:maxend
  from (
  select &chr_var,&SNP_Var,&Pos_Var-&dist2snp as minst,&Pos_Var+&dist2snp as maxend
  from &gwas_dsd
  %if &chrposquery=0 %then %do;
    where &SNP_Var="&qsnp"
  %end;
  %else %do;
    where &chr_var=&num_chr and 
    (&Pos_Var between 
      &st_pos and &end_pos
    )
  %end;
  );
  %if %sysfunc(countc(&qsnp,%str(:)))=2 %then %do;
     /*To keep the proc sql codes consistant for creating macros vars of minst and maxend;
     The position range need to be adjusted by dist2snp, because the proc sql command
     will substract and add the dist2snp to the st and end positions; By adding and substracting
     the dist2snp from st and end position, respectively, the final minst and maxend will
     be the same as the input st and end positions!*/
     %let chr=%scan(&qsnp,1,%str(:));
     %let minst=%sysevalf(%scan(&qsnp,2,%str(:))-&dist2snp);
     %let maxend=%sysevalf(%scan(&qsnp,3,%str(:))+&dist2snp);    
  %end;  
  
  %if %symexist(chr)=0 %then %do;
   %put no record for your query SNP &qsnp;
   %abort 255;
  %end;
  %if %length(%superq(chromosome_lengths))>0 %then %do;
    /* PROC SQL can pad numeric chromosome values in macro variables. Strip
       that padding before checking the chromosome and looking up its length. */
    %let _chrom_for_window=%sysfunc(strip(%superq(chr)));
    %if %sysfunc(prxmatch(/^(?:[1-9]|1[0-9]|2[0-4])$/,%superq(_chrom_for_window))) %then %do;
      %let _chrom_end_for_window=%scan(%superq(chromosome_lengths),&_chrom_for_window,%str(,));
      %if %sysevalf(&maxend>&_chrom_end_for_window) %then %do;
        %put NOTE: Clipping the local GTF x-axis for chromosome &_chrom_for_window from &maxend to its reference end &_chrom_end_for_window.;
        %let maxend=&_chrom_end_for_window;
      %end;
    %end;
  %end;
  %let force_lattice_xaxis_viewmin=&minst;
  %let force_lattice_xaxis_viewmax=&maxend;
  %if %sysevalf(&force_lattice_xaxis_viewmin<1) %then %let force_lattice_xaxis_viewmin=1;
  %put Your input three parameters for the SNP &qsnp are: chr=&chr minst=&minst maxend=&maxend;
  %put NOTE: The displayed x-axis for &qsnp will use the requested SNP-centered window [&force_lattice_xaxis_viewmin, &force_lattice_xaxis_viewmax].;

  /* SAS ODA already has the HTML5 plot destination open. The extra printer
     destination renders a second 300-DPI bitmap and can exhaust Java memory. */
  %if not %symexist(local_gtf_ods_html5) %then %do;
    %OpenSVG_Printer(
     filename=Local_SNP_Manhattanplot,
     svgfileref=out,
     other_paras4ods_graphics=%str(noborder)
     );
  %end;
/*  %abort 255;*/
  %if &effective_signed_r2=1 %then
    %let effective_plot_title=Signed LD r2 x sign(Z score): &qsnp;
  %else
    %let effective_plot_title=Z-score-colored local Manhattan: &qsnp;
  title "&effective_plot_title";
  %map_grp_assoc2gene4covidsexgwas(
focus_on_transcript=&focus_on_transcript,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/ 
  gwas_dsd=&gwas_dsd, 
  gtf_dsd=&gtf_dsd, 
  chr=&chr, 
  min_st=&minst, 
  max_end=&maxend, 
  dist2genes=1000, 
  AssocPVars=&AssocPVars, 
  ZscoreVars=&effective_zscore_vars,
  gwas_labels_in_order=&gwas_labels_in_order,
  design_width=&design_width, 
  design_height=&design_height, 
  image_dpi=&image_dpi,
  barthickness=&barthickness, 
  dotsize=&dotsize, 
  grp_font_size=&grp_font_size,
  /*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
  dist2sep_genes=&dist2sep_genes,
 /*this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track! */
  where_cndtn_for_gwasdsd=&where_cndtn_for_gwasdsd,
  gwas_pos_var=&Pos_Var,
  Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
  shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
  fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
 pct4neg_y=&pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
  adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
  makedotheatmap=&makedotheatmap,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
  heatmap_min_neg_val=&effective_heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty;
change this to customize the minimum value for colorbar in heatmap*/
  heatmap_max_pos_val=&effective_heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty;
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=&effective_ld_marker_var,
ld_marker_color=&LD_marker_color,
ld_marker_legend_symbol=&LD_marker_symbol,
ld_heatmap_var=&effective_ld_heatmap_var,
ld_heatmap_colormodel=&LD_heatmap_colormodel,
ld_heatmap_legend_title=&LD_heatmap_legend_title,
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
pct2adj4dencluster=&pct2adj4dencluster,/*For SNP labels on the top, please try to use this parameter, which only works when there are less than or equal to 4 top SNPs
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop, /*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=&scatter_yaxis_label, /*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=&effective_heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=&effective_plot_title,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
  ); 
  %if not %symexist(local_gtf_ods_html5) %then %do;
    ods printer close;
    *Also need to close the fileref out generated by the macro;
    filename out clear;
    ods listing;
  %end;
  
  proc print data=&gwas_dsd;
  where &SNP_Var="&qsnp";
  run;
  
  *Need to delete previously generated dataset Final;
  proc datasets nolist;
/*   delete Final: _X1_ BEDCHR: Exon: X1 X2 TMP_: Single_DSD; */
  delete _X1_ BEDCHR: Exon: X1 X2 TMP_: Single_DSD;
  run;
  title;
  %let force_lattice_xaxis_viewmin=;
  %let force_lattice_xaxis_viewmax=;
  
%end;

*Reove target SNPs if they exist;
%if %length(&SNPs2label_scatterplot_dots)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _Target_SNP_;
run;
%end;

%if %length(&effective_ld_marker_var)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _LD_SNP_MARK_;
run;
%end;

%if %length(&effective_ld_heatmap_var)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _LD_R2_;
run;
%end;

%if &verbose=0 %then %do;
%put We will enable options notes;
options notes;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/TotVarsInDsd.sas */
%macro TotVarsInDsd(/*This macro is able to count all, numeric, or character vars in a sas dataset*/
ds, /*This macro return total number of variables in a dsd*/
var_type=_all_ /*optional values including _all_, _numeric_, or _character_ 
for counting total number of all, numeric, or character vars*/
);
   
   %local dset dsid;
   %let dset=&ds;
   %let dsid = %sysfunc(open(&dset(keep=&var_type)));
   %if &dsid %then
      %do;
/*         %let nobs =%sysfunc(attrn(&dsid,NOBS));*/
         %let nvars=%sysfunc(attrn(&dsid,NVARS));
         %let rc = %sysfunc(close(&dsid));
          &nvars
      %end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/add_fake_pos_by_grp4nonnegvars.sas */
%macro add_fake_pos_by_grp4nonnegvars(
dsdin,
axis_var,/*No negative values are allowed for the target axis var*/
axis_grp,
new_fake_axis_var,
dsdout, /*Two new variables, tag var and tpos, can be used to draw a ref line to separe each group*/
axis_step=1, /*Add extra step to separate each group for the end value of axis_var*/
concise_output=0, /*Provide value 1 to only keep 3 vars and other vars included in the original input dsdin, 
including axis_var, axis_grp, and new_fake_axis_var, and others in the output dsdout*/
reset_1st_value_as_one=0 /*Default is not to reset the 1st value of each group as one;
Provide the value 1 to reset the 1st value of each group as 1 and other values to minus the 1st value in the input dsdin;
this would be helpful if the 1st position value of each group is too large to draw plot by group!*/ 
);

/*
%let dsdin=a;
%let axis_grp=g;
%let axis_var=y;
%let dsdout=b;
%let axis_step=1;
%let new_fake_axis_var=fy;
*/

*Test whether there are negative values in the &dsdin;
*the macro only works for values >= 0;
proc sql noprint;
select count(&axis_var) into: neg_var_tot
from &dsdin
where &axis_var<0;


%if &neg_var_tot>0 %then %do;
 %put the macro only works for positve values, and you dsd &dsdin contains &neg_var_tot number of negative values;
 %abort 255;
%end;


*Fix a bug when only one record in a group;
*make an extra copy for the records to make it has >1 records;
*This is because the script will not be able to update corrected;
*y axis labels if there is only one record for a group;

proc sql;
create table _single_ as 
select *
from &dsdin
group by &axis_grp
having count(&axis_grp)=1;

data &dsdin;
set &dsdin _single_;

proc sort data=&dsdin;
by &axis_grp &axis_var;
run;

data _dsdin_;
set &dsdin;
*Scale position value and make it larger by fold change;
*if &axis_var>0 then &axis_var=&fc2scale_pos_vals*&axis_var;
run;

*Reset the 1st axis_var as 1;
%if &reset_1st_value_as_one=1 %then %do;
%put Going to reset the 1st value of each group as one and other values will adjusted accordingly;
 proc sql;
create table _dsdin_ (drop=&axis_var) as
select a.*,
           a.&axis_var-min(a.&axis_var)+1 as _new_
from _dsdin_ as a
group by &axis_grp
order by &axis_grp,_new_;
data _dsdin_;
set _dsdin_;
rename _new_=&axis_var;
run;
%end;

data &dsdout;
retain tpos 0 step &axis_step grp_n 0 grpnum 0;
set _dsdin_;

n=_n_;
*add the var grp_n for sorting the values inside each group;
*which would be handy to handle all negative values by using the macro;
*the method is simply to change all negative values into positve, ane then;
*use this macro. Finally, flip the order of fake axis values by this var grp_n later;
*grp_n need to be put in the retain command;

if first.&axis_grp then do;
 fst_tag=1;
 grpnum=grpnum+1;
 grp_n=1;
 if n=1 then do;
   *important to make tpos as 0 when n=1;
   tpos=tpos;
   &new_fake_axis_var=&axis_var;
 end;
 else do;
   &new_fake_axis_var=&axis_var + tpos;
 end;
end;

if last.&axis_grp then do;
   grp_n=grp_n+1;
   tag=1;
   &new_fake_axis_var=tpos + &axis_var;
   if not first.&axis_grp then do;
      *only floor but not ceil can be used here;
      tpos=ceil(&axis_var) + tpos + step;
   end;
end;

if (not first.&axis_grp) and (not last.&axis_grp) then do;
 grp_n=grp_n+1;
 &new_fake_axis_var=&axis_var + tpos;
end;

by &axis_grp;

run;

*Also add a new var to indicate the middle axis value for each group;
data &dsdout;
retain mid_val 0;
set &dsdout;
if tag=1 then mid_val=tpos-0.5*(tpos-mid_val);
run;

data &dsdout;
set &dsdout;
*reassign missing value for mid_val whoes tag is not 1;
if tag=. then mid_val=.;
run;

*Make the last maximum value minus the step;
data &dsdout;
set &dsdout end=eoff;
if eoff then tpos=tpos-step;
run;
%if &concise_output=1 %then %do;
data &dsdout;
set &dsdout;
drop mid_val tpos step grp_n grpnum n fst_tag tag;
run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/adj_grpnum4close_gene_bed_regs.sas */
%macro adj_grpnum4close_gene_bed_regs(
/*Note: the macro can only separate most of the bed regions
for better labeling bed regions, and usually the 1st track will be
good, with genes included in other tracks may not be well separated!*/
gene_bed_dsd=a,
st_var=st,
end_var=end,
reg_type=type,/*if empty, it will use the longest region as gene and 
               other shorter region from the same group as exons*/
focused_reg_type4grouping=gene,
gene_grp=grp,
gene_dist_thrhd=0.1,/*(1) give 0 or negative value to incluce all genes into a single group;
                      (2) given value in bp > 1 to separate genes by absolute distance in bp;
                      (3) if given value ranging from 0 to 1, it will use the pct of the whole region
                          to separate genes into different groups!
                          This option would be most useful to enable enough space for adding text on each
                          gene, as it will consider the length of gene as well as the distance between genes*/
dsdout=_gene_regions_,/*dsdout can be the same as gene_bed_dsd*/
outnumgrp=numgrp /*the var name for outnumgrp can not be same as other vars in gene_bed_dsd*/
);

%if "&gene_bed_dsd"="&dsdout" %then %do;
    %put Your input dsd name is the same as the output dsd name;
    %put we will temporarily change the &dsdout as: &dsdout._;
    %let old_dsdout=&dsdout;
    %let dsdout=&dsdout._;
%end;
%else %do;
    %let old_dsdout=&dsdout;
%end;

%if &reg_type ne %then %do;
  proc sort 
  data=&gene_bed_dsd(where=(&reg_type="&focused_reg_type4grouping"))
  out=&dsdout
  nodupkeys;
  by &st_var &end_var &gene_grp;
  run;
%end;
%else %do;
 data &dsdout;
 set &gene_bed_dsd;
 dist=&end_var - &st_var;
 run;
 proc sql;
 create table &dsdout(drop=dist) as 
 select &st_var,&end_var, &gene_grp, dist 
 from &dsdout
 group by &gene_grp
 having dist=max(dist);
%end;

*It is important to sort the start position again!;
*otherwise, the _grp_ number would not be the best!;
proc sort data=&dsdout;by &st_var;run;

proc sql noprint;
select left(put(count(&gene_grp),3.)) into: ngenes
from &dsdout;
run;

%if &gene_dist_thrhd > 0 %then %do;

 %if &gene_dist_thrhd<1 %then %do;
     proc sql noprint;
     select min(st),max(end) into: st_min,:end_max
     from &dsdout;
     %put Now we will use the relative distance based on the percent &gene_dist_thrhd of whole region;
     %put from &st_min to &end_max to separate genes into different groups!;
     %let gene_dist_thrhd=%sysevalf((&end_max-&st_min)*&gene_dist_thrhd);
 %end;
/*  data &dsdout(drop=_lag_end:);*/
 data &dsdout;
  retain _grp_ 1;
  set &dsdout;
  _lag_end_1=(lag(end) ^=.) and (abs(st-lag(end))<&gene_dist_thrhd or st-lag(end)<0);
  _lag_end_1= _lag_end_1 >0 or ((lag(st) ^=.) and (abs(st-lag(st))<&gene_dist_thrhd or st-lag(st)<0))>0;
  /*
  lag_end1=lag(end);
  */
  %do ni=2 %to &ngenes;
    /*
    lag_end2=lag2(end);
    lag_end3=lag3(end);
    */
    _lag_end_&ni=(lag&ni.(end) ^=.) and ((abs(st-lag&ni.(end))<&gene_dist_thrhd) or st-lag&ni.(end)<0);
    _lag_end_&ni=_lag_end_&ni>0 or ((lag&ni.(st) ^=.) and (abs(st-lag&ni.(st))<&gene_dist_thrhd or st-lag&ni.(st)<0))>0;
  %end;
  %if &ngenes>1 %then %do;
   *Add one to make it start from 1 for the 1st group;
    _grp_=sum(of _lag_end_1-_lag_end_&ngenes)+1;
  %end;
  run;
 %end;
 
%else %do;
 *Include all genes into one group;
 data &dsdout;
 set &dsdout;
 _grp_=1;
 run;
%end;
/*%abort 255;*/


*exclude records with the same consecutive _grp_;
data &dsdout(drop=_consect_grp_tag) 
     &dsdout._bad(drop=_consect_grp_tag);
set &dsdout;
_consect_grp_tag=lag(_grp_);
if (_consect_grp_tag=_grp_ and _grp_>1) then output &dsdout._bad;
else output &dsdout;
run;
/*for debugging*/
/* %abort 255; */

*make consective numeric groups for _grp_;
*The limitation of this part is that only element in the _grp_=1 can be separated well;
proc sort data=&dsdout;by _grp_ st end;
data &dsdout;
retain _cgrp_ 0;
set &dsdout;
if first._grp_ then _cgrp_=_cgrp_+1;
by _grp_;
run;

*Combine the grps, such as n+1 and n+3, with n=0,1,2,3;
*An easy way to combine them would be as follows:;
*Make these grps with reverse order;
*Note: use _grp_ to get max;
proc sql noprint;
select max(_grp_) into: mgrp
from &dsdout;

*Add back these bad groups and assign _cgrp_=&mgrp+_n_;
data &dsdout._bad;
retain init_num 1;
set &dsdout._bad;
_cgrp_=&mgrp+_n_;

/*Assume it is better but it is not!;
*Better to group regions with different _cgrp_ together;
*which will aggregate these regions in a single track;
if first._grp_ then do;
  _cgrp_=&mgrp+1;
  init_num=1;
end;
else do;
  init_num=init_num+1;
  _cgrp_=init_num+&mgrp;
end;
by _grp_;
*/
run;


data &dsdout;
set &dsdout &dsdout._bad;
run;

*Note: use _cgrp_ but not _grp_ to get max;
proc sql noprint;
select max(_cgrp_) into: newmgrp
from &dsdout;
/*%abort 255;*/
%if %superq(newmgrp)= %then %let newmgrp=0;

data &dsdout;
set &dsdout;
*Important to adjust group number by not allowing the new _cgrp_ close to original _grp_;
/* if &mgrp-_cgrp_+3 <= _grp_ then _cgrp_=&newmgrp-_cgrp_+1; */
/* if &mgrp-_cgrp_+2 <= _grp_ then _cgrp_=&newmgrp-_cgrp_+1; */
*Put half of these _cgrp_ with larger numbers started from 1;
*This part is a bug if all grps are indeed not mergable, which means there are the same number of orginal and newly generated groups;
%if %sysevalf(&newmgrp>=10) %then %do;
  %put WARNING: the macro adj_grpnum4close_gene_bed_regs will modify the newly created numeric group since it is the same number of groups as the original group;
  if _cgrp_>ceil(0.5*&newmgrp) then _cgrp_=_cgrp_-ceil(0.5*&newmgrp);
%end;
run;

/*
proc sql noprint;
select max(_cgrp_) into: mgrp
from &dsdout;
*Add back these bad groups and assign _cgrp_=&mgrp+1;
data &dsdout._bad;
set &dsdout._bad;
_cgrp_=&mgrp+1;
data &dsdout;
set &dsdout &dsdout._bad;
run;
*/

proc sort data=&dsdout;by _grp_ st end;
*Note that the macro var &old_dsdout is used here to avoid of potential errors when the gene_bed_dsd is the same as &dsdout;
proc sql;
create table &old_dsdout as 
select a.*,b._cgrp_ as &outnumgrp 
from &gene_bed_dsd as a
left join
&dsdout as b 
on a.&gene_grp=b.&gene_grp;

data &dsdout;
set &old_dsdout;
run;
*When the two vars &dsdout and &old_dsdout have the same name, the original dataset will be overwritten;
*Need to keep a copy for it.;
data &old_dsdout.0;
set &old_dsdout;
run;
/*%abort 255;*/
***It is necessary to further optimize these regions by merging the largest group number with the smallest group numer;
***when any regions in the largest group number are not within the distance threshold;

  *This part might invite issues for separating a gene and its corresponding exons into different groups;
  *To resovle the issue, it is necessary use minmum st and max end for each gene_grp as input;
  *First keep a copy for the above &dsdout, and then later update the &outnumgrp with newly calculated group numbers; 
  proc sql;
  create table &dsdout as 
  select distinct &gene_grp,min(&st_var) as &st_var,max(&end_var) as &end_var,&outnumgrp
  from &dsdout
  group by &gene_grp;
/*  %abort 255;*/

%let nmgrp_0=0; 
%let nmgrp_1=1;
*For debugging the loop;
%let nloop=0;
*Restrict the loop only run maximum of 300 iterations;
%do %while (&nmgrp_0 ne &nmgrp_1 and &nloop<300);
   %let nloop=%eval(&nloop+1);
  *Need to create a new numgrp var and reorder the numgrp based on new &outdsd in the loop;
  proc sql;
  create table _tmp_ as
  select unique(&outnumgrp) as _tmpnumgrp_
  from &dsdout
  order by &outnumgrp;
/*  %abort 255;*/
  data _tmp_;set _tmp_;&outnumgrp=_n_;
  proc sql;
  create table &dsdout as
  select a.*,b.&outnumgrp as new&outnumgrp
  from &dsdout as a
  left join
  _tmp_ as b
  on a.&outnumgrp=b._tmpnumgrp_;
/*  %abort 255;*/
  *Put the newnumgrp into the macro var &nmgrps;
  *This will update the macro var nmgrps in each interation;
  proc sql noprint;
  select put(new&outnumgrp,best12.) into: nmgrps separated by ' '
  from (
    select distinct new&outnumgrp from &dsdout
  );
/*  %abort 255;*/
  *Use the newnumgrp to replace older numgrp;
  data &dsdout(rename=(new&outnumgrp=&outnumgrp));
  set &dsdout(drop=&outnumgrp);
  run;

 %if %ntokens(&nmgrps)>=3 %then %do;

   proc sql noprint;
   select put(&outnumgrp,best12.) into: nmgrp_0 separated by ':'
   from &dsdout
   order by &gene_grp, &st_var, &end_var; 
   *Important to only consider the comparision between regions from i and i+2 groups;
   *since the consecutive groups, i and i+1 do not have potential non-overlapped regions based on the distance threshold;

   %do nmg_i=%ntokens(&nmgrps) %to 3 %by -1; 
         *%let start_num=%eval(1+%ntokens(&nmgrps)-&nmg_i);
          %let start_num=1;
		 *Note: only compare 3 pairs, and the following can not be uncommented as SAS will fail to parse the macro contents due to it is use of pcts;
		 %let end_num=%sysfunc(ifc(%eval(&nmg_i-2)>%eval(&start_num+6),%eval(&start_num+6),%eval(&nmg_i-2)));
/*		  %let end_num=%eval(&nmg_i-2);*/
		 %put Your start and end number for the loop is &start_num and &end_num;
	     %do nmg_ii= &start_num %to &end_num %by 2; 
/*		      %let nloop=%eval(&nloop+1);*/
		       %put Running the n=&nloop loop: comparison for the group &nmg_i with group &nmg_ii;
			 data p1;set &dsdout;where &outnumgrp=&nmg_ii;
			 data p2;set &dsdout;where &outnumgrp=&nmg_i;
			 run;
/*			 %if %totobsindsd(work.p2)=0 %then %do;*/
/*						%put No obs in the dataset p2 for the numgrp &nmg_i;*/
/*						%abort 255;*/
/*			 %end;*/
			%if %totobsindsd(work.p2)>0 %then %do;

			 %if %ntokens(&nmgrps)>=3 %then %do;
				 data left;set &dsdout;where &outnumgrp^=&nmg_ii and &outnumgrp^=&nmg_i;
			 %end;
			  run;
/*			  %abort 255;*/
			  *It is important to use distinct to remove duplicate records due to the where condition leads to potential multiple matches;
			  proc sql;
			  create table p1_p2 as
			  select distinct b.*
			  from p1 as a,
			           p2 as b
			  where (b.&st_var between  (a.&st_var-&gene_dist_thrhd) and (a.&end_var+&gene_dist_thrhd)) or 
                         (b.&end_var between  (a.&st_var-&gene_dist_thrhd) and (a.&end_var+&gene_dist_thrhd)); 
/*			   proc print;run;*/
			   %if %totobsindsd(work.p1_p2)>0 %then %do;;			      
					 proc sql;
					 create table p1p2_except as 
					 select * from p2
					 except 
					 select * from p1_p2;
					   data p1p2_except;set p1p2_except;&outnumgrp=&nmg_ii;
					   *Update data set p2, which have different outnumgrp for p1_p2 and p1p2_except;
					   data p2;set p1_p2 p1p2_except;run;
			   %end;
			   %else %do;
			   	  *Merge all records with the largest group &nmg_i as that of &nmg_ii;
			      data p2;set p2;&outnumgrp=&nmg_ii;
			   %end;
			    data &dsdout;
				set p1 p2 
                %if %ntokens(&nmgrps)>=3 %then %do;
				  left
				%end;
                ;
				run;

				proc sql;
				drop table left;
				drop table p1;
				drop table p2;
				drop table p1_p2;
				drop  table p1p2_except;
/*				%abort 255;*/
	      %end;
         %end;
   %end;
  *Capture these new group numbers and order them by positions;
  *The macro var will be used to compare with previous numbers &nmgrp_0;
   proc sql noprint;
   select put(&outnumgrp,best12.) into: nmgrp_1 separated by ':'
   from &dsdout
   order by &gene_grp, &st_var, &end_var; 
%end;
 %else %do;
	 %let nmgrp_0=1; 
     %let nmgrp_1=1;
 %end;

%end;

  *It is necessary to rename the &dsdout as &old_dsdout;
*&old_dsdout contains the target output data set name, in case that it is the same as input data set name;
*Update the newly generated grp number to the &old_dsdout;
/*%put old_dsdout is &old_dsdout and dsdout is &dsdout;*/
proc sql;
create table &old_dsdout as 
select a.*,b.&outnumgrp 
from &old_dsdout.0(drop=&outnumgrp) as a
left join
&dsdout as b
on a.&gene_grp=b.&gene_grp;
/*%abort 255;*/
/* proc print;run; */
%mend;


/* Source companion/research/advanced_figures/sources/definitions/adjust_close_positions.sas */
%macro adjust_close_positions(
/*Limitation: where there are only 2 closely related positions, a fixed distance with Pct4OnlyTwoPos*step will be used to separate them;
Additonally, if there are positions too close to the start or end of position in the figure, it is possible to modify the internal macro
var pct2adj4dencluster from 0.25 to larger value but less than 1 at line 90 in the sas macro!
amplification_fc can be increased to separate closely related positions, too!*/
indsd=,
outdsd=,
pos_var=pos,
new_pos_var=newpos,
dist_pct_to_cluster_pos=0.01,/*Use the pct of range of positions to cluster these positions
Note: positions with distance less then ceil(&dist_pct_to_cluster_pos*(max(&pos_var)-min(&pos_var)+1)) will
be asigned into a single cluster for further adjusting distance using amplification_fc!*/
amplification_fc=1.5, /*Increase the distance fold change among these close records;
Note: all positions within the same cluster will be amplified using the formula: pos+(&pos_var-median(&pos_var))*&amplification_fc by cluster*/
make_even_pos=1, /*If provide value 1, which will ensure all position with the same distance between min and max pos;
This will replace previous setting of dist_pct_to_cluster_pos and amplification_fc;
Note: *Only when the total number of records is gt the number of distant cluster, the macro will generate even positions for all records
*/
pct2adj4dencluster=0.05,/*This parameter is mainly designed when make_even_pos=0; it is useful when elements within a cluster is overlapped with each other
or overlapped with elements from other cluster, so it is feasible to avoid this issue by increasing the pct or reducing it.
However, when make_even_pos=1, the macro will multiple the amplification_fc with 10*pct2adj4dencluster to further enlarge the even distance among positions*/
Pct4OnlyTwoPos=0.5,/*In case of only two positions, it is necessary to use arbitrary proportion of dist_step to separate them,
i.e., minus and add Pct4OnlyTwoPos*dist_step and for the first and second positions, respectively*/
fixed_min_pos=,/*Provide fixed minimum and maximum positions for generating even psotions;
Default is empty to use the minimum and maximum positions from input dsd!*/
fixed_max_pos=
);

proc sql noprint;
select count(unique(&pos_var)) into: tot_rows
from &indsd;

select min(&pos_var),max(&pos_var),
ceil(&dist_pct_to_cluster_pos*(max(&pos_var)-min(&pos_var)+1)),
min(&pos_var), max(&pos_var), 
(max(&pos_var)-min(&pos_var)+1)/(1+&tot_rows)
into: min_pos,:max_pos,
:offset_dist,
:min_pos,:max_pos,
:dist_step
from &indsd;
quit;

%if %length(&fixed_min_pos)>0 %then %let min_pos=&fixed_min_pos;
%if %length(&fixed_max_pos)>0 %then %let  max_pos=&fixed_max_pos;
%let dist_step=%sysevalf((&max_pos-&min_pos+1)/(1+&tot_rows));

*Need to update the macro var offset_dist as min_pos and max_pos might be changed;
%let offset_dist=%sysevalf(&dist_pct_to_cluster_pos*(&max_pos-&min_pos+1));

proc sort data=&indsd out=&outdsd nodupkeys;by &pos_var;run;
/* proc print;run; */


data &outdsd(drop=_pre_pos_);
retain _pre_pos_ dist_cluster 0;
set &outdsd;
ord=_n_;
if _n_=1 then do;
   dist_cluster=1;
   _pre_pos_=&pos_var;
   output;
end;
*This means that two positions with distance less than the offset_dist will be assigned with the same cluster number;
if _n_>1 and &pos_var-_pre_pos_<&offset_dist then do;
    _pre_pos_=&pos_var;
    dist_cluster=dist_cluster;
    output;
 end;
 else if _n_>1 then do;
    _pre_pos_=&pos_var;
    dist_cluster=dist_cluster+1;
    output;
 end;
run;
/* proc print;run; */


/* %let amplification_fc=1.5; */
*Note that if these positions within a cluster are too close, the adjusted position by only adding or minusing median(pos) would fail to separate positions;
*So by including the ratio between distance between positions within a cluster to the average positions in the cluster to the offset_dist and further reduce it by 10 fold;
*these positions will be separated from each other;

*Note: that it is necessary to use median pos as a separator to add or substract offset distances among positions within a cluster;
*the function avg fails to separate the most closest positions in each cluster, as these position tend to be not changed in scale in the final output;


*Note that the extra amplification factor 0.1*&offset_dist/abs(&pos_var-median(&pos_var)) is not multiplied for _pos_;
*Instead, we multiple it with the new factor: 10*pct2adj4dencluster; 
proc sql;
create table &outdsd._with_close_records as
select dist_cluster,&pos_var,ord,
&pos_var+(&pos_var-median(&pos_var))*&amplification_fc*(10*&pct2adj4dencluster) as _pos_
from &outdsd
group by dist_cluster
having count(dist_cluster)>1
order by ord;
/*proc print;run;*/
/*%abort 255;*/

*Now update the positions in the output data set;
proc sql;
create table &outdsd as
select *
from &outdsd
natural full join
&outdsd._with_close_records
;
*This will keep duplicate records in the outdsd;
proc sql;
create table &outdsd as
select *
from &indsd
natural full join
&outdsd;


proc sort data=&outdsd;by ord;
proc sql noprint;
select max(dist_cluster) into: max_cluster
from &outdsd;

data &outdsd(rename=(_pos_=&new_pos_var) );
set &outdsd;
if _pos_=. then _pos_=&pos_var;
/*drop=dist_cluster ord;*/
run;
/*proc print;run;*/

*Only when the total number of records is gt the number of distant cluster, the macro will generate even positions for all records;
%if &make_even_pos=1 and  &max_cluster^=&tot_rows %then %do;
data &outdsd;
set &outdsd;
&new_pos_var=&min_pos+ord*&dist_step;
run;
%end;


proc sql;
drop table &outdsd._with_close_records;
quit;
/* proc print;run; */

*The above will failed to revise the positions of markers if the total number of which is 2;
*The following code will update these positions specifically for the above scenario;
proc sql noprint;
select count(*) into: _tot_rescaled_pos_
from &outdsd;
%if &_tot_rescaled_pos_=2 %then %do;
data &outdsd;
set &outdsd;
if _n_=1 then do;
/*  &new_pos_var=&new_pos_var-0.1*&dist_step;*/
  &new_pos_var=&new_pos_var-&Pct4OnlyTwoPos*&dist_step;
end;
else do;
/*  &new_pos_var=&new_pos_var+0.1*&dist_step;*/
  &new_pos_var=&new_pos_var+&Pct4OnlyTwoPos*&dist_step;
end;
run;
%end;
/*proc print;run;*/
*Further correct the minimum and maximum value in the outpu data set;
data &outdsd;
set &outdsd;
if &new_pos_var<&min_pos then &new_pos_var=&pos_var-(&max_pos-&min_pos)*0.05;
if &new_pos_var>&max_pos then &new_pos_var=&pos_var+(&max_pos-&min_pos)*0.05;
run;
*Further separate positions that are too close based on the  cutoff 0.1*&dist_step;
data &outdsd(drop=_new_pos_var_);
set &outdsd;
  if &new_pos_var-lag(&new_pos_var)<0.5*&dist_step  then do;
   if first.dist_cluster then do;
     _new_pos_var_=lag(&new_pos_var)+0.5*&dist_step;
   end;
   else do;
	 _new_pos_var_=lag(&new_pos_var)+0.25*&dist_step;
   end;
  end;
  if _new_pos_var_^=.  then &new_pos_var=_new_pos_var_;
  by dist_cluster;
run;
/*proc print;run;*/
/*%abort 255;*/

%mend;


/* Source companion/research/advanced_figures/sources/definitions/bed_region_plot_by_grp.sas */
%macro bed_region_plot_by_grp(
bed_dsd,
chr_var,
st_var,
end_var,
grp_var,
yval_var,
linethickness=20,
track_width=800,
track_height=400,
dist2st_and_end=0
);
%number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=&st_var,descending_or_not=0,dsdout=x1);
data x1(keep=&chr_var pos &yval_var &grp_var ord st end);
set x1;
array X{2} &st_var &end_var;
do i=1 to 2;
 pos=X{i};
 output;
end;
run;
/*Get max grp number for split data into different dsd*/;
proc sql noprint;
select max(ord),floor(min(&yval_var)),ceil(max(&yval_var)),min(&st_var)-&dist2st_and_end,max(&end_var)+&dist2st_and_end 
       into: max_ord,: min_y,: max_y,: min_x,: max_x
from x1;
%if %eval(&min_x<0) %then %do;
    %let min_x=0;
%end;
/*
data tmp;
set x1(keep=&grp_var &yval_var);
proc sort data=tmp nodupkeys;by &yval_var &grp_var;
run;
proc sql noprint;
select quote(&grp_var) into: y_grp_values separated by " "
from tmp
order by &yval_var;
drop table tmp;
*/

data tmp;
do i=&min_y to &max_y;
output;
end;
run;
proc sql noprint;
select i into: y_axis_values separated by " "
from tmp;
drop table tmp;

/***********************No need this, as it generates missing group that will be put into the legend
in in the final figure*/
/*data x1;*/
/*set x1;*/
/*%do i=1 %to &max_ord;*/
/*if ord=&i then do;*/
/*  &grp_var.&i=&grp_var;*/
/*  pos&i=pos;*/
/*  &yval_var.&i=&yval_var;*/
/*  output;*/
/*end;*/
/*%end;*/
/*run;*/
/************************************************************************************************/


/*Need to fill these missing values with pair of non-missing values,
otherwise, the missing values will be a group that will be included 
in the legend in the final figure*/
%do gi=1 %to &max_ord;
data y&gi(keep=ord &grp_var&gi pos&gi &yval_var&gi);
set x1;
if ord=&gi then do;
  &grp_var&gi=&grp_var;
  pos&gi=pos;
  &yval_var&gi=&yval_var;
  output;
end;
else do;
  /*grp_var may be numeric or char, 
   just use its original value here,
   will remove it later*/
  &grp_var&gi=&grp_var;
  pos&gi=.;
		label pos&gi="Relative position (bp)";
  &yval_var&gi=.;
		label &yval_var&gi="Group";
  output;
end;
run;

/*proc sort data=y&gi;by &grp_var&gi ord pos&gi;*/
/*run;*/

/*get the 1st two records without missing values,
which will be used for fill these missing values later*/
data y&gi._ y&gi._missing;
set y&gi;
if pos&gi^=. then output y&gi._;
else output y&gi._missing;
/*create the common var n with values of 1 or 2
for matching with non-missing values from y1_*/
data y&gi._missing;
set y&gi._missing;
if mod(_n_,2)=0 then n=2;
else n=1;
/*Also get the 1st two non-missing values and 
label them with 1 and 2 for matching*/
data y&gi._1;
set y&gi._;
n=_n_;
if _n_<=2;
run;
proc sql;
create table y&gi._filled as
select a.n as n&gi, b.*
from y&gi._missing as a,
     y&gi._1 as b
where a.n=b.n;
/*merge y1_filled with y1_*/
data y&gi._final(drop=ord n);
set y&gi._filled(drop=n&gi) y&gi._;
run;
%end;

data final;
%do i=1 %to &max_ord;
set y&i._final;
%end;
run;
*documentation for adjusting axis for layout overlay;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatug/p1pqfzgbuzbpkzn1mrbzhgggvhkz.htm;
proc template;
define statgraph Bedgraph;
dynamic _chr _pos _value _G;
begingraph / designwidth=&track_width designheight=&track_height;
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
         layout overlay/yaxisopts=(
                        type=linear offsetmin=0.1 offsetmax=0.1
                        linearopts=(minorticks=false tickvaluelist=(&y_axis_values))
                        )
                        xaxisopts=(linearopts=(viewmin=&min_x viewmax=&max_x));
                        /* Need to add this into linearopts later: tickdisplaylist=(&y_grp_values)*/
		 %do i=1 %to &max_ord;
	       %if &i=1 %then %do;
		     referenceline y=0 /lineattrs=(color=black pattern=1 thickness=2);
						%if &min_y<0 %then %do;
						  %do _yi_=&min_y %to -1;
		       referenceline y=&_yi_ /lineattrs=(color=black pattern=2 thickness=0.5);
								%end;
						%end;
						%else %do;
						  %do yi=1 %to &max_y;
		        referenceline y=&yi /lineattrs=(color=black pattern=2 thickness=0.5);
								%end;
						%end;
		   %end;

               seriesplot x=pos&i y=&yval_var.&i / group=&grp_var.&i name='series' connectorder=xaxis 
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
                                      name="series&i"
                                      ;
         %end;	
      endlayout; 
	  sidebar /align=bottom;
	  discretelegend "series1"; 
	  endsidebar;
   endlayout;
endgraph;
end;
run;

proc sgrender data=WORK.final template=BedGraph;
dynamic _chr="&chr_var";
run;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/beta2OR_forest_plot.sas */
%macro Beta2OR_forest_plot(
dsdin=,
beta_var=,
se_var=,
sig_p_var=,/*adjust the threshold of p in the extra_condition4updatedsd*/
marker_var=,
marker_label=,
svgoutname=,
plot_title=OR Forest Plot,
figfmt=png,
figwidth=600,
figheight=800,
dotsize=10,
autolegend=0,
xaxis_value_range=%str(0.4 to 1.6 by 0.2),
sort_var4y=,/*Provide a variable in the input dsdin to sort the y axis tickets in the final figure;
1. If left empty, it will use the default data order of marker_var to label y-axis from lower to upper;
The default order of data can be modified by using proc sort procedure as follows:
proc sort data=tops;by type gwas2_beta rsid;run;
This is powerful because multiple variables can be used to sort the final y-axis tickets;
2. Alternatively, it is fine to use a new variable, as sometimes it is better to create 
a new variable for sorting the input dsdin before applying the current macro
*/
y2axis_ticket_var=,/*Default is emptyp to not to draw the 2nd yaxis;
Provide a variable name to use its values to draw the 2nd yaxis*/
both_y_font_size=12, /*Font size for any of the two y-axis*/
sig_datalabel_pos=,
sig_datalabel_size=,
min_axis=0,
max_axis=2,
yoffsetmax=0.03, /*offset for the upper y axis maximum value*/
yoffsetmin=0.03, /*offset for the lower y axis minimum value*/
y_refline_values=,
y_refline_lineattrs=%str(pattern=shortdash color=gray thickness=1),
randomize_output_suffix=1,
output_suffix=,
/*Note: the macro need to have a input variable grp to color dots representing OR;
So in the following extra condition for input dataset, a new variable grp is created.*/
outdsd=dsd4OR,/*Output calcuated ORs for further evaluation*/
extra_condition4updatedsd=%nrstr(
length sigtag $10.;
if &marker_var="rs16831827" then do;
 grp=0;sigtag='';
end;
else if &sig_p_var<5e-8 then do;
 grp=1;sigtag='*';
end;
else do;
 grp=1;sigtag="";
end;
if &marker_var="12:113357193:G:A" then &marker_var="rs10774671";
if &marker_var="17:44219831:T:A" then &marker_var="rs1819040";
if &marker_var="19:10427721:T:A" then &marker_var="rs74956615";

if &marker_var in ('rs2271616','rs11919389','rs912805253','rs4801778') then grp=0;
else if &marker_var='rs16831827' then grp=1;
else grp=2;
 )
);

%local _forest_output_suffix _forest_output_stub _forest_output_stub_norm _forest_image_name _forest_output_dir _forest_printer_device;
%if %length(&sig_datalabel_size)=0 %then %let sig_datalabel_size=&both_y_font_size;
%if %length(&output_suffix)>0 %then %do;
  %let _forest_output_suffix=&output_suffix;
%end;
%else %if %sysevalf(&randomize_output_suffix ne 0) %then %do;
  %let _forest_output_suffix=%RandBetween(1,100);
%end;
%else %do;
  %let _forest_output_suffix=;
%end;
%let _forest_output_stub=&svgoutname;
%if %length(&_forest_output_suffix)>0 %then %let _forest_output_stub=&svgoutname.&_forest_output_suffix;
%let _forest_output_stub_norm=%sysfunc(tranwrd(%superq(_forest_output_stub),%str(\),/));
%let _forest_image_name=%sysfunc(scan(%superq(_forest_output_stub_norm),-1,%str(/)));
%let _forest_output_dir=%sysfunc(prxchange(s/\/[^\/]+$//,1,%superq(_forest_output_stub_norm)));
%if %superq(_forest_output_dir)=%superq(_forest_output_stub_norm) %then %let _forest_output_dir=.;
%let _forest_printer_device=%lowcase(&figfmt);
%if %length(&_forest_printer_device)=0 %then %let _forest_printer_device=png;

data tmp;
set &dsdin;
effect=exp(&beta_var);
uppercl=exp(&beta_var+1.96*&se_var);
lowercl=exp(&beta_var-1.96*&se_var);
%unquote(&extra_condition4updatedsd);
run;

ods listing close;
ods listing gpath="&_forest_output_dir";

%if %length(&plot_title)>0 %then %do;
title "&plot_title";
%end;
%else %do;
title;
%end;
ods graphics on/reset=all noborder outputfmt=&figfmt
                            width=&figwidth height=&figheight
                            imagename="&_forest_image_name";
data _tmp_;
set tmp;
keep by_n &marker_var;
%if %length(&sort_var4y)=0 %then %do;
   by_n=_n_;
%end;
%else %do;
  by_n=&sort_var4y;
%end;
run;

%mkfmt4grps_by_var(
grpdsd=_tmp_,
grp_var=&marker_var,
by_var=by_n,
outfmt4numgrps=x2y,
outfmt4chargrps=y2x
);

data tmp;
set tmp;
*format char grps to numeric grps;
new_grp_var=input(&marker_var,x2y.);
run;

***********Import attrmap to assign the same color schemes to different grp*****************************;
/*https://blogs.sas.com/content/iml/2017/01/30/auto-discrete-attr-map.html*/
%let VarName = grp;           /* specify name of grouping variable */
proc freq data=tmp ORDER=FORMATTED noprint;   /* or ORDER=DATA|FREQ  */
   tables &VarName / out=Attrs(rename=(&VarName=Value));
run;
data DAttrs;
ID = "&VarName";                 /* or "ID_&VarName" */
set Attrs(keep=Value);
length MarkerStyleElement $11.;
MarkerStyleElement = cats("GraphData", 1+mod(_N_-1, 12)); /* GraphData1, GraphData2, etc */
run; 
/*proc print; run;*/
***********The above codes are important to assign the same color schemes to different grp*********;


proc sgplot data=tmp dattrmap=DAttrs %if &autolegend=0 %then noautolegend;;
/* scatter x=effect y=&marker_var / datalabel=sigtag */
scatter x=effect y=new_grp_var / datalabel=sigtag 
datalabelattrs=(size=&sig_datalabel_size weight=bold)
%if %length(&sig_datalabel_pos)>0 %then %do;
datalabelpos=&sig_datalabel_pos
%end;
group=grp xerrorlower=lowercl  grouporder=ASCENDING attrid=grp
xerrorupper=uppercl	 name="dotsc"
markerattrs=(symbol=circleFilled size=&dotsize);
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0er4dg9tojp05n1sf7maeqdz1d8.htm;
refline 1 / axis=x lineattrs=(pattern=solid color=darkgray thickness=1) ;
xaxis label="OR and 95% CI " labelattrs=(size=&both_y_font_size) min=&min_axis valueattrs=(size=&both_y_font_size) max=&max_axis values=(&xaxis_value_range);
*It is necessary to add the type=discrete to fix the yaxis using the newly created new_grp_var with its numeric format;
yaxis label="&marker_label" labelattrs=(size=&both_y_font_size) valueattrs=(size=&both_y_font_size style=normal) type=discrete display=(nolabel)
          offsetmax=&yoffsetmax offsetmin=&yoffsetmin;
%if %length(&y_refline_values)>0 %then %do;
refline &y_refline_values / axis=y lineattrs=(&y_refline_lineattrs);
%end;

*Align labels to SNP rows so repeated genes or NA values cannot collapse categories;
%if %length(&y2axis_ticket_var)>0 %then %do;
yaxistable &y2axis_ticket_var / y=new_grp_var position=right location=outside
  nolabel valueattrs=(size=&both_y_font_size style=italic);
%end;

%if &autolegend=1 %then %do;
keylegend "dotsc"/ title="";
%end;

format new_grp_var y2x.;
run;
ods listing;
title;

data &outdsd;
set tmp;
run;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/char_grp_to_num_grp.sas */
%macro char_grp_to_num_grp(
dsdin=,
grp_vars4sort=,
descending_or_not=,
dsdout=,
num_grp_output_name=,
keep_uniq_rows_by_grp=0
);
/*Note: if keep_uniq_rows_by_grp=1, then only unique grps will be remained in the final dataset*/
%let nvars=%numargs(&grp_vars4sort);
*Use key instead of by in the proc sort, as unknown error occurred when using by with descending function;
*Note: if &dsdin and &dsdout are the same, the final &dsdout will only contain unique rows by keys;
*This would be wrong if wanting to keep all rows!;
*So only use the temporary table dsdout here;
%if &descending_or_not %then %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort /descending;
run;
%end;
%else %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort;
run;
%end;

data dsdout;
set dsdout;
&num_grp_output_name=_n_;
%if &nvars>=1 %then %do;
grps_output_key=catx(':', of &grp_vars4sort);
%end;
run;
/*Only unique grp keys are kept in the above output dsd!*/

%if %eval(&keep_uniq_rows_by_grp=0) %then %do;
*Now add the num_grp_output_name back to the original table;
data tmp;
set &dsdin;
_grps_output_key_=catx(':', of &grp_vars4sort);
run;
proc sql;
create table &dsdout(drop=_grps_output_key_) as
select b.*,a.&num_grp_output_name,a.grps_output_key
from dsdout as a
right join
tmp as b
on a.grps_output_key=b._grps_output_key_;
%end;
%else %do;
data &dsdout;
set dsdout;
run;
%end;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/check_var_type.sas */
%macro check_var_type(dsdin,var_rgx);
proc contents data=&dsdin out=&dsdin._fmt noprint;
run;
proc sql noprint;
/*select distinct(TYPE) into: var_type separated by '|'*/
select TYPE into: var_type separated by '|'
from &dsdin._fmt
where prxmatch("/&var_rgx/i",NAME);

%put The types of variables matched with regular expression &var_rgx in dsd &dsdin are:;
%put &var_type;
%if %index(&var_type,|) %then %put Your regular expression matchs with >1 variables, please restrict your regular expression to only match with a unique variable name;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/delete_empty_dsd.sas */
%macro delete_empty_dsd(dsd_in);
%if (%sysfunc(count(&dsd_in,%str(.)))>0) %then %do;
%let lib=%scan(&dsd_in,1,'.');
%let dsd_in=%scan(&dsd_in,2,'.');
%end;
%else %do;
%let lib=work;
%end;
proc sql noprint;
select count(*)
into: obs_num
from &lib..&dsd_in;
%if (&obs_num=0) %then %do;
proc datasets lib=&lib nolist;
delete &dsd_in;
run;
%put "The dataset &dsd_in in the library &lib is empty!";
%put "The above dataset is deleted!";
%end;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/format_xaxis_with_numeric_order.sas */
%macro format_xaxis_with_numeric_order(
dsdin,
Xaxis_vars,
new_Xaxis_var,
Var4sorting_Xaxis,
function4sorting,
descending_or_not,
dsdout,
createdfmtname,
KeyVar4Xaxis_vars=KeyVar4dsdout
);

*If AlsoAppFun4Cols=1, will apply specific function on each row or ALL Rows (if row_keys is missing) for ALL these matched columns;
*For AlsoAppFun4Cols=1, we can not use avg but mean, because avg is going to calculate mean based on group and mean is to calculate mean of different columns;
*Should be careful to use this function to calculate mean of ALL data points.;
*Note: KeyVar4dsdout will try to catx all row_keys with ':';
%ApplyFunc_rowwide(dsdin=&dsdin
                  ,row_keys=&Xaxis_vars
                  ,KeyVar4dsdout=KeyVar4dsdout
                  ,Regex4col_vars2apply=&Var4sorting_Xaxis
				  ,SQL_Fun4apply=&function4sorting
                  ,dsdout=Sorted_dsd
                  ,AlsoAppFun4Cols=1);
%put Xaxis_vars are &Xaxis_vars;

*Add numeric grp id to each grp with the order in accordace with the summary of &var4sorting after applied for the function &function4sorting by grp;
*New variable &function4sorting will be created, which can be used to sort the new variable dataset;
*If supplying ONE or multiple vars into grp_vars4sort, a default new var combining all these vars with ':' will be created;
*which is grps_output_key;
%char_grp_to_num_grp(dsdin=Sorted_dsd,grp_vars4sort=&function4sorting KeyVar4dsdout,descending_or_not=&descending_or_not,dsdout=Sorted_dsd1,num_grp_output_name=&new_Xaxis_var);

/*catx Xaxis_vars*/
data var_labels;
set Sorted_dsd1;
*remove leading grp generated by supplied function;
grps_output_key=prxchange('s/^[^:]+://',-1,grps_output_key);
keep grps_output_key &new_Xaxis_var KeyVar4dsdout;
run;

proc sql noprint;
select count(grps_output_key), catx('','grp',count(grps_output_key)) into: vtot, : grp_v
from var_labels;
select grps_output_key into: vvgrp1 - : vv&grp_v
from var_labels;

*Print it for debugging;
%do xi=1 %to &vtot; 
   %put Apply format for &xi="&&vvgrp&xi";
%end;

*Delete previous format, otherwise the new format will not be applied;
/*
proc format lib=work fmtlib;
run;
*/

proc catalog cat=work.formats;
delete &createdfmtname..format;
run;

proc format;
value &createdfmtname 
%do i=1 %to &vtot; 
        &i="&&vvgrp&i"
%end;
;
data &dsdin;
set &dsdin;
KeyVar4dsdout=catx(':',of &Xaxis_vars);
run;

proc sql;
create table &dsdin._tmp as
select a.*,
       b.&new_Xaxis_var,
       b.grps_output_key
from &dsdin as a
left join
var_labels as b
on strip(left(a.KeyVar4dsdout))=strip(left(b.KeyVar4dsdout))
;

*This actually not helpful;
data &dsdout;
set &dsdin._tmp;
num_grp=&new_Xaxis_var;
/*Will change it manually outside the macro later*/
attrib &new_Xaxis_var format=&createdfmtname..;
run;

*Note: new evaluation revealed that the above format is not useful;
*The variable KeyVar4Xacis_vars can not used to draw plot with numeric order directly.;
proc sort data=&dsdout;by num_grp;run;
data &dsdout;
set &dsdout;
rename KeyVar4Xaxis_vars=&KeyVar4Xaxis_vars;
run;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/get_tgt_hits4Manhattan.sas */
%macro get_tgt_hits4Manhattan(/*Note: the macro is able to keep the order of target snps and generate a macro var
called _chr_colors_ according to the chromsomes that these input snps residing in!*/
dsdin=_last_,
snp_var=rsid,
chr_var=chr,
pos_var=pos,
p_var=p,
dsdout=tophits,
target_snps=rs2564978 rs17425819, /*Only focus on regions of these target snps*/
keep_target_snps_order=0,/*Supply value 1 to keep the original input order of target SNPs, otherwise, 
the macro will sort the input target SNPs and also sort _chr_colors_ by sorted SNPs!*/
dist4get_uniq_top_hit=1e6 /*Only get the top one hit among the distance by pos with the top one at the center*/
);

*Note: this global macro var will be used to draw Manhattan plot later;
%global _chr_colors_;
%let _chr_colors_=;

%let _grp_cols_=
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319;

%rank4grps(
grps=&_grp_cols_,
dsdout=grpcolsdsd
);

data grpcolsdsd;
set grpcolsdsd;
rename num_grps=&chr_var;
              cls=grps;
run;

%rank4grps(
grps=&target_snps,
dsdout=tgts
);
data tgts;
set tgts;
rename grps=&snp_var;
run;
*Also keep the order of input SNPs by keeping the variable num_grps;
proc sql;
create table top_ind as
select a.*,b.num_grps
from &dsdin as a,
         tgts as b
where a.&snp_var=b.&snp_var;

proc sql;
   create table &dsdout as 
   select a.*,b.&snp_var as tag_snp,b.num_grps
   from &dsdin as a,
            top_ind as b
 where a.&chr_var=b.&chr_var and 
a.&pos_var between (b.&pos_var-0.5*&dist4get_uniq_top_hit) and 
                                     (b.&pos_var+0.5*&dist4get_uniq_top_hit); 


*Now try to match colors for these top hits by chr;
%if &keep_target_snps_order=1 %then %let var4srt_snp=num_grps;
%else %let var4srt_snp=tag_snp;
proc sql noprint;
create table &dsdout as
select a.*,b.cls
from &dsdout as a
left join
grpcolsdsd as b
on a.&chr_var=b.&chr_var;

select distinct cls into: _chr_colors_ separated by ' '
from &dsdout 
order by &var4srt_snp;

%if %totobsindsd(mydata=&dsdout)=0 %then %do;
    *Do not kill the macro as this macro may be used by a macro loop within other macros;
		%put No targets for your quiry snps: &target_snps;
/*    %abort 255;*/
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/get_top_hits4Manhattan.sas */
%macro get_top_hits4Manhattan(
dsdin=_last_,
snp_var=rsid,
chr_var=chr,
pos_var=pos,
p_var=p,
dsdout=tophits,
p_thrsd=1e-5, /*Only keep these signals with smaller values than the threshold*/
dist4get_uniq_top_hit=1e6, /*Used only as an LD-query failure fallback when selection_method=LD*/
selection_method=LD,
ld_pops=EUR,
ld_r2_threshold=0.1,
ld_population_rule=ANY,
ld_query_failure_action=DISTANCE,
max_leads=0,
ld_audit_out=top_hit_ld_audit
);
*Note: these global macro vars will be used to draw Manhattan plot later;
%global _chr_colors_ _top_snps_;
%let _chr_colors_=;
%let _top_snps_=;

%let _grp_cols_=
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319;

%rank4grps(
grps=&_grp_cols_,
dsdout=grpcolsdsd
);

data grpcolsdsd;
set grpcolsdsd;
rename num_grps=&chr_var;
              cls=grps;
run;

proc sql;
create table _top_hits as
select * 
         from &dsdin
         where not missing(&p_var)
           and &p_var > 0
           and &p_var <= &p_thrsd;
quit;

%put NOTE: get_top_hits4Manhattan is selecting candidate hits with &p_var <= &p_thrsd.;

%if %upcase(&selection_method)=LD %then %do;
  %get_top_signal_with_ld(
    dsdin=_top_hits,
    snp_var=&snp_var,
    grp_var=&chr_var,
    signal_var=&p_var,
    select_smallest_signal=1,
    pos_var=&pos_var,
    signal_thrshd=&p_thrsd,
    ld_pops=&ld_pops,
    ld_r2_threshold=&ld_r2_threshold,
    ld_population_rule=&ld_population_rule,
    query_failure_action=&ld_query_failure_action,
    fallback_dist_bp=&dist4get_uniq_top_hit,
    max_leads=&max_leads,
    dsdout=top_ind,
    audit_out=&ld_audit_out
  );
%end;
%else %do;
  %get_top_signal_within_dist(
    dsdin=_top_hits,
    grp_var=&chr_var,
    signal_var=&p_var,
    select_smallest_signal=1,
    pos_var=&pos_var,
    pos_dist_thrshd=&dist4get_uniq_top_hit,
    dsdout=top_ind,
    signal_thrshd=&p_thrsd
  );
%end;
proc sql noprint;
select count(*) into: _top_snp_n trimmed
from top_ind;
quit;
%put NOTE: get_top_hits4Manhattan retained &_top_snp_n lead SNPs after &selection_method selection.;

proc sql outobs=200 noprint;
select &snp_var into: _top_snps_ separated by ' '
from top_ind
order by &snp_var;
%put Top snps are selected: &_top_snps_;
%if %sysevalf(%superq(_top_snp_n) > 200) %then %do;
  %put NOTE: &_top_snp_n top SNPs passed the threshold, and _top_snps_ is truncated to the first 200 names to avoid macro-length overflow.;
%end;
%else %do;
  %put They are saved into a global macro variable, _top_snps_;
%end;

proc sql;
   create table &dsdout as 
   select a.*,b.&snp_var as tag_snp
   from &dsdin as a,
            top_ind as b
 where a.&chr_var=b.&chr_var and 
a.&pos_var between (b.&pos_var-0.5*&dist4get_uniq_top_hit) and 
                                     (b.&pos_var+0.5*&dist4get_uniq_top_hit); 


*Now try to match colors for these top hits by chr;
proc sql noprint;
create table &dsdout as
select a.*,b.cls
from &dsdout as a
left join
grpcolsdsd as b
on a.&chr_var=b.&chr_var;

select distinct cls into: _chr_colors_ separated by ' '
from &dsdout 
order by tag_snp;
%put Colors for top snps are &_chr_colors_;
%put They are sorted by snps and saved into a global macro variable, _chr_colors_;

%if %totobsindsd(mydata=&dsdout)=0 %then %do;
		%put No hits after filtering with the p value threshold &p_thrsd;
/*    %abort 255;*/
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/get_top_signal_with_ld.sas */
%macro get_top_signal_with_ld(
  dsdin=,
  snp_var=SNP,
  grp_var=CHR,
  signal_var=P,
  select_smallest_signal=1,
  pos_var=BP,
  signal_thrshd=1,
  ld_pops=EUR,
  ld_r2_threshold=0.1,
  ld_population_rule=ANY,
  query_failure_action=DISTANCE,
  fallback_dist_bp=1e6,
  max_leads=0,
  dsdout=top_ind,
  audit_out=top_hit_ld_audit
);
%local _candidate_n _iter _remaining_n _lead_id _lead_snp _lead_chr
       _lead_query_snp _lead_bp _lead_signal _lead_is_rs _pop_n _pi _pop _valid_pop_n
       _requested_pop_n _response_valid _response_self_n _selected_n
       _rule _failure_action _max_leads_num _has_rsid _has_r2 _cache_pop_n
       _lead_query_status;
%global TOP_HIT_LD_SELECTION_STATUS TOP_HIT_LD_SELECTED_N TOP_HIT_LD_PRUNED_N;

%let TOP_HIT_LD_SELECTION_STATUS=RUNNING;
%let TOP_HIT_LD_SELECTED_N=0;
%let TOP_HIT_LD_PRUNED_N=0;
%let _rule=%upcase(%sysfunc(strip(%superq(ld_population_rule))));
%let _failure_action=%upcase(%sysfunc(strip(%superq(query_failure_action))));
%let _requested_pop_n=%sysfunc(countw(%superq(ld_pops),%str( )));
%let _max_leads_num=%sysfunc(inputn(%superq(max_leads),best32.));
%if %sysevalf(%superq(_max_leads_num)=,boolean) %then %let _max_leads_num=0;

%if &_requested_pop_n=0 %then %do;
  %put ERROR: get_top_signal_with_ld requires at least one HaploReg population in ld_pops=.;
  %let TOP_HIT_LD_SELECTION_STATUS=INVALID_LD_POPULATIONS;
  %return;
%end;
%if &_rule ne ANY and &_rule ne ALL %then %do;
  %put ERROR: ld_population_rule must be ANY or ALL, not &ld_population_rule.;
  %let TOP_HIT_LD_SELECTION_STATUS=INVALID_POPULATION_RULE;
  %return;
%end;

data _ld_candidates_unsorted;
  set &dsdin;
  length _ld_snp_key $128 _ld_chr_key $32;
  length _ld_signal _ld_bp_num 8;
  _ld_snp_key=upcase(strip(vvalue(&snp_var)));
  _ld_chr_key=upcase(compress(strip(vvalue(&grp_var)),' '));
  _ld_chr_key=prxchange('s/^CHR//i',1,_ld_chr_key);
  _ld_bp_num=input(strip(vvalue(&pos_var)),best32.);
  _ld_signal=input(strip(vvalue(&signal_var)),best32.);
  if missing(_ld_snp_key) or missing(_ld_chr_key) or missing(_ld_bp_num) then delete;
  if missing(_ld_signal) or _ld_signal <= 0 or _ld_signal > &signal_thrshd then delete;
run;

proc sort data=_ld_candidates_unsorted out=_ld_candidates_ranked;
%if &select_smallest_signal=1 %then %do;
  by _ld_signal _ld_chr_key _ld_bp_num _ld_snp_key;
%end;
%else %do;
  by descending _ld_signal _ld_chr_key _ld_bp_num _ld_snp_key;
%end;
run;

data _ld_candidates;
  if _n_=1 then do;
    declare hash _seen();
    _seen.defineKey('_ld_snp_key');
    _seen.defineDone();
  end;
  set _ld_candidates_ranked;
  if _seen.check()=0 then delete;
  _seen.add();
  length _ld_pruned_by $128 _ld_prune_population $32
         _ld_query_status $24 _ld_independence_method $24;
  retain _ld_candidate_id 0;
  _ld_candidate_id+1;
  _ld_selected=0;
  _ld_pruned=0;
  _ld_lead_rank=.;
  _ld_pruned_lead_rank=.;
  _ld_prune_r2=.;
run;

proc sql noprint;
  select count(*) into :_candidate_n trimmed from _ld_candidates;
quit;
%if %sysevalf(%superq(_candidate_n)=,boolean) %then %let _candidate_n=0;

%if &_candidate_n=0 %then %do;
  data &dsdout; set _ld_candidates; run;
  data &audit_out;
    length candidate_snp lead_snp $128 selection_action $24;
    stop;
  run;
  %let TOP_HIT_LD_SELECTION_STATUS=NO_CANDIDATES;
  %goto _ld_cleanup;
%end;

%do _iter=1 %to &_candidate_n;
  %let _remaining_n=0;
  %let _lead_id=;
  %let _lead_snp=;
  %let _lead_query_snp=;
  %let _lead_chr=;
  %let _lead_bp=;
  %let _lead_signal=;
  proc sql noprint;
    select count(*) into :_remaining_n trimmed
    from _ld_candidates
    where _ld_selected=0 and _ld_pruned=0;

    select _ld_candidate_id, _ld_snp_key, _ld_chr_key, _ld_bp_num, _ld_signal
      into :_lead_id trimmed, :_lead_snp trimmed, :_lead_chr trimmed,
           :_lead_bp trimmed, :_lead_signal trimmed
    from _ld_candidates
    where _ld_selected=0 and _ld_pruned=0
    having _ld_candidate_id=min(_ld_candidate_id);
  quit;

  %if %sysevalf(%superq(_remaining_n)=,boolean) %then %let _remaining_n=0;
  %if &_remaining_n=0 or %sysevalf(%superq(_lead_id)=,boolean) %then %goto _ld_finished;

  proc sql noprint;
    select count(*) into :_selected_n trimmed
    from _ld_candidates where _ld_selected=1;
  quit;
  %if %sysevalf(%superq(_selected_n)=,boolean) %then %let _selected_n=0;
  %if %sysevalf(&_max_leads_num > 0) and %sysevalf(&_selected_n >= &_max_leads_num) %then %goto _ld_finished;

  proc sql;
    update _ld_candidates
    set _ld_selected=1,
        _ld_lead_rank=&_selected_n+1
    where _ld_candidate_id=&_lead_id;
  quit;

  data _null_;
    call symputx('_lead_is_rs',prxmatch('/^RS[0-9]+$/i',symget('_lead_snp'))>0,'L');
  run;

  data _ld_lead_edges;
    length query_snp proxy_snp $128 ld_population $16 proxy_r2 8;
    stop;
  run;
  %let _valid_pop_n=0;
  %let _cache_pop_n=0;

  %if &_lead_is_rs %then %do;
    %let _lead_query_snp=%sysfunc(lowcase(%superq(_lead_snp)));
    %let _pop_n=%sysfunc(countw(%superq(ld_pops),%str( )));
    %do _pi=1 %to &_pop_n;
      %let _pop=%scan(%superq(ld_pops),&_pi,%str( ));
      %QueryLD_SNPs_at_Haploreg4(
        snp=&_lead_query_snp,
        LDpop=&_pop,
        ldThresh=&ld_r2_threshold,
        outdsd=_ld_raw_response
      );

      %let _has_rsid=0;
      %let _has_r2=0;
      %if %sysfunc(exist(work._ld_raw_response)) %then %do;
        proc sql noprint;
          select sum(upcase(name)='RSID'), sum(upcase(name)='R2')
            into :_has_rsid trimmed, :_has_r2 trimmed
          from dictionary.columns
          where libname='WORK' and memname='_LD_RAW_RESPONSE';
        quit;
      %end;
      %if %sysevalf(%superq(_has_rsid)=,boolean) %then %let _has_rsid=0;
      %if %sysevalf(%superq(_has_r2)=,boolean) %then %let _has_r2=0;

      %if &_has_rsid>0 and &_has_r2>0 %then %do;
        data _ld_response_norm;
          length query_snp proxy_snp $128 ld_population $16 proxy_r2 8;
          set _ld_raw_response;
          query_snp="&_lead_snp";
          proxy_snp=upcase(strip(vvaluex('rsID')));
          ld_population="%upcase(&_pop)";
          proxy_r2=input(strip(vvaluex('r2')),best32.);
          if not missing(proxy_snp) and not missing(proxy_r2);
          keep query_snp proxy_snp ld_population proxy_r2;
        run;
        proc sql noprint;
          select count(*) into :_response_self_n trimmed
          from _ld_response_norm
          where proxy_snp="&_lead_snp";
        quit;
        %if %sysevalf(%superq(_response_self_n)=,boolean) %then %let _response_self_n=0;
        %if &_response_self_n>0 %then %do;
          %let _valid_pop_n=%eval(&_valid_pop_n+1);
          %if %upcase(%superq(HAPLOREG_LD_QUERY_SOURCE))=LOCAL_CACHE %then
            %let _cache_pop_n=%eval(&_cache_pop_n+1);
          proc append base=_ld_lead_edges data=_ld_response_norm force; run;
        %end;
      %end;
      proc datasets library=work nolist;
        delete _ld_raw_response _ld_response_norm;
      quit;
    %end;
  %end;

  %if &_valid_pop_n>0 %then %do;
    %if &_valid_pop_n=&_requested_pop_n %then %let _lead_query_status=OK;
    %else %let _lead_query_status=PARTIAL;
    %if &_cache_pop_n=&_valid_pop_n %then %let _lead_query_status=&_lead_query_status._LOCAL_CACHE;
    %else %if &_cache_pop_n>0 %then %let _lead_query_status=&_lead_query_status._MIXED;

    proc sql;
      create table _ld_prune_keys as
      select proxy_snp as _ld_snp_key length=128,
             max(proxy_r2) as _edge_r2,
             case
               when count(distinct ld_population)>1 then 'MULTI'
               else min(ld_population)
             end as _edge_population length=32
      from _ld_lead_edges
      where proxy_snp ne "&_lead_snp"
        and proxy_r2 >= &ld_r2_threshold
      group by proxy_snp
      %if &_rule=ALL %then %do;
      having count(distinct ld_population) >= &_requested_pop_n
      %end;
      ;
    quit;

    proc sort data=_ld_candidates; by _ld_snp_key; run;
    proc sort data=_ld_prune_keys; by _ld_snp_key; run;
    data _ld_candidates;
      merge _ld_candidates(in=_candidate) _ld_prune_keys;
      by _ld_snp_key;
      if _candidate;
      if _ld_selected=0 and _ld_pruned=0 and not missing(_edge_r2) then do;
        _ld_pruned=1;
        _ld_pruned_by="&_lead_snp";
        _ld_pruned_lead_rank=&_selected_n+1;
        _ld_prune_r2=_edge_r2;
        _ld_prune_population=_edge_population;
        _ld_independence_method='LD';
      end;
      drop _edge_r2 _edge_population;
    run;
    proc sort data=_ld_candidates; by _ld_candidate_id; run;

    proc sql;
      update _ld_candidates
      set _ld_query_status="&_lead_query_status",
          _ld_independence_method='LD'
      where _ld_candidate_id=&_lead_id;
    quit;
  %end;
  %else %do;
    %if &_failure_action=DISTANCE and %sysevalf(&fallback_dist_bp > 0) %then %do;
      data _ld_candidates;
        set _ld_candidates;
        if _ld_selected=0 and _ld_pruned=0
           and _ld_chr_key="&_lead_chr"
           and _ld_bp_num >= (&_lead_bp-0.5*&fallback_dist_bp)
           and _ld_bp_num <= (&_lead_bp+0.5*&fallback_dist_bp) then do;
          _ld_pruned=1;
          _ld_pruned_by="&_lead_snp";
          _ld_pruned_lead_rank=&_selected_n+1;
          _ld_prune_population='NA';
          _ld_independence_method='DISTANCE_FALLBACK';
        end;
        if _ld_candidate_id=&_lead_id then do;
          _ld_query_status='NO_LD_RESPONSE';
          _ld_independence_method='DISTANCE_FALLBACK';
        end;
      run;
    %end;
    %else %do;
      proc sql;
        update _ld_candidates
        set _ld_query_status='NO_LD_RESPONSE',
            _ld_independence_method='UNRESOLVED_NO_LD'
        where _ld_candidate_id=&_lead_id;
      quit;
    %end;
  %end;

  proc datasets library=work nolist;
    delete _ld_lead_edges _ld_prune_keys;
  quit;
%end;

%_ld_finished:
data &dsdout;
  set _ld_candidates;
  where _ld_selected=1;
  length INDEPENDENCE_METHOD $24 LD_POPULATIONS $64 LD_POPULATION_RULE $8
         LD_QUERY_STATUS $24;
  LD_LEAD_RANK=_ld_lead_rank;
  INDEPENDENCE_METHOD=_ld_independence_method;
  LD_R2_THRESHOLD=&ld_r2_threshold;
  LD_POPULATIONS="%upcase(&ld_pops)";
  LD_POPULATION_RULE="&_rule";
  LD_QUERY_STATUS=_ld_query_status;
  LD_FALLBACK_BP=&fallback_dist_bp;
  drop _ld_:;
run;
proc sort data=&dsdout; by LD_LEAD_RANK; run;

data &audit_out;
  set _ld_candidates;
  length candidate_snp lead_snp $128 selection_action $24
         independence_method $24 query_status $24 ld_population $32;
  candidate_rank=_ld_candidate_id;
  candidate_snp=_ld_snp_key;
  chr=_ld_chr_key;
  bp=_ld_bp_num;
  signal=_ld_signal;
  if _ld_selected then do;
    selection_action='SELECTED_LEAD';
    lead_rank=_ld_lead_rank;
    lead_snp=_ld_snp_key;
  end;
  else if _ld_pruned then do;
    selection_action=ifc(_ld_independence_method='LD','PRUNED_LD','PRUNED_DISTANCE_FALLBACK');
    lead_rank=_ld_pruned_lead_rank;
    lead_snp=_ld_pruned_by;
  end;
  else selection_action='NOT_REACHED';
  prune_r2=_ld_prune_r2;
  ld_population=_ld_prune_population;
  query_status=_ld_query_status;
  independence_method=_ld_independence_method;
  keep candidate_rank candidate_snp chr bp signal selection_action lead_rank
       lead_snp prune_r2 ld_population query_status independence_method;
run;
proc sort data=&audit_out; by candidate_rank; run;

proc sql noprint;
  select count(*) into :TOP_HIT_LD_SELECTED_N trimmed
  from _ld_candidates where _ld_selected=1;
  select count(*) into :TOP_HIT_LD_PRUNED_N trimmed
  from _ld_candidates where _ld_pruned=1;
quit;
%let TOP_HIT_LD_SELECTION_STATUS=COMPLETE;
%put NOTE: LD top-hit selection complete: candidates=&_candidate_n selected=&TOP_HIT_LD_SELECTED_N pruned=&TOP_HIT_LD_PRUNED_N r2=&ld_r2_threshold populations=&ld_pops rule=&_rule.;

%_ld_cleanup:
proc datasets library=work nolist;
  delete _ld_candidates_unsorted _ld_candidates_ranked _ld_candidates
         _ld_lead_edges _ld_prune_keys _ld_raw_response _ld_response_norm;
quit;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/get_top_signal_within_dist.sas */
%macro get_top_signal_within_dist(
dsdin=,
grp_var=,
signal_var=,
select_smallest_signal=1,
pos_var=,
pos_dist_thrshd=, /*Total exclusion span in bp; the macro keeps one lead signal within +/- 0.5*pos_dist_thrshd*/
dsdout=,
signal_thrshd=1 /*filter the input dsdin by association P, i.e, &signal_var <= &signal_thrshd*/
);

/*
Greedy in-group top-signal selection with a distance exclusion window.

Compared with the older self-join / SQL approach, this version is much faster
when many loci pass the threshold because it:

1. filters candidates first
2. sorts once by group and signal strength
3. keeps selected intervals for the current group only
4. greedily accepts the next best non-overlapping signal

The exclusion window matches the earlier behavior:
  dis_st = pos - pos_dist_thrshd * 0.5
  dis_end = pos + pos_dist_thrshd * 0.5

So a value such as 1e6 means "keep one lead signal per 1 Mb span"
rather than "use a 1 Mb half-window on each side".
*/

data _top_signal_candidates;
length Key $200.;
set &dsdin;
where not missing(&signal_var) and &signal_var > 0 and &signal_var <= &signal_thrshd;
dis_st=&pos_var-&pos_dist_thrshd*0.5;
dis_end=&pos_var+&pos_dist_thrshd*0.5;
Key=catx(':',&grp_var,&pos_var);
run;

%put Warning: duplicate records by Key and &signal_var will be kept for only one record.;
proc sort data=_top_signal_candidates dupout=_dup_records_ out=_top_signal_candidates nodupkeys;
%if &select_smallest_signal=1 %then %do;
  by &grp_var &pos_var &signal_var;
%end;
%else %do;
  by &grp_var &pos_var descending &signal_var;
%end;
run;
%put Warning: duplicate records by Key and &signal_var are saved into the data set _dup_records_.;

proc sort data=_top_signal_candidates;
%if &select_smallest_signal=1 %then %do;
  by &grp_var &signal_var &pos_var;
%end;
%else %do;
  by &grp_var descending &signal_var &pos_var;
%end;
run;

data &dsdout;
  array _sel_dis_st[50000] _temporary_;
  array _sel_dis_end[50000] _temporary_;
  retain _sel_n 0;
  length _keep 8 _i 8;

  set _top_signal_candidates;
  by &grp_var;

  if first.&grp_var then _sel_n = 0;

  _keep = 1;
  do _i = 1 to _sel_n;
    if (&pos_var >= _sel_dis_st[_i]) and (&pos_var <= _sel_dis_end[_i]) then do;
      _keep = 0;
      leave;
    end;
  end;

  if _keep then do;
    output;
    _sel_n + 1;
    if _sel_n > dim(_sel_dis_st) then do;
      put "ERROR: get_top_signal_within_dist exceeded the temporary selection buffer size of 50000.";
      stop;
    end;
    _sel_dis_st[_sel_n] = dis_st;
    _sel_dis_end[_sel_n] = dis_end;
  end;

  drop _sel_n _keep _i;
run;

%if &select_smallest_signal=1 %then %do;
proc sort data=&dsdout;
  by &grp_var &signal_var &pos_var;
run;
%end;
%else %do;
proc sort data=&dsdout;
  by &grp_var descending &signal_var &pos_var;
run;
%end;

proc datasets library=work nolist;
  delete _top_signal_candidates;
quit;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/iscolallmissing.sas */
%macro iscolallmissing(dsd,colvar,outmacrovar);
%global &outmacrovar;
proc sql noprint;
select nmiss(&colvar)/count(&colvar) 
into: allmissing
from &dsd;
quit;

%if %sysevalf(&allmissing=1,boolean) %then %do;
   %let &outmacrovar=1;
%end;
%else %do;
   %let &outmacrovar=0;
%end;

*This rescues the situation when all data of the column &colvar are missing;
%if &allmissing=. %then %do;
   %let &outmacrovar=1;
 %end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/make_fake_axis4NegPosVal_by_grps.sas */
%macro make_fake_axis4NegPosVal_by_grps(/*The macro will scale up or down positive or negative values and generate 
yaxis macro labels with the original postive values; To keep using the original positive value but also to scale the ratio
between these positve and negative values, the macro variable NotChangePosVals is set to 1.
The other global macro variable called fake_refline_values, can be used by other procedures to
draw reference lines to separate each group into the final figure if required!
Note: if NotChangePosVals=1, the final negative tick values are scaled values and the macro is updated 
to adjust the axis labels for negative values; since the negative values
are used to draw gene track at the bottom, they will be replaced as " " in the final figure
Note: the output put dsdout contain modified values based on the input scale;
However, the macro variable yaxis_macro_labels is updated to use the original values 
to label axis, although the negative positive values may use different steps in the final axis labels!
*/
dsdin,
axis_var,/*Both negative and positive values of axis var are allowed to use this macro,
           but in each group, only positve (>0) or negative (<0) values are allowed,
           and all 0 axis var values will be excluded from the dsdin, 
           the above of which are the limitations of the macro!*/
axis_grp,
new_fake_axis_var,
dsdout,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=1, /*Use this fc to enlarge the proportion of positive values in the plots
               It seems that fc=2 is the best for the final ticks of different tracks;*/
NotChangePosVals=1, /*For making manhattan plot, it is better to fix the positive y values,
as scale down the positive values will lead to the y tick labels containing decimals, and
the SAS macro to making local Manhattan plot is set in default to only show integer ticks;
When fc2scale_pos_vals is < 1, the original positive values will be
scaled down to generate fake values; sometimes it is necessary to keep the original values 
but also achieve the goal of scale down these positve values. The workaround method is 
to scale up the negative value with the fold change 1/&fcscale_pos_vals;
Reason for keep the positive values but scale up the negative values:
The coveat for squeezing the positive values by amplifying the value for negative values is that;
the final figure ticks for the positive values will be with very few ticks in the y-axis; 
To rescue this, it is better to multiple both negative and positive values by the same scale value &yscale again;*/
mod_num2keep= /*For the final yaxis_macro_labels, default value for the current var  is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0; 
Note that this will only be applied on numbers that are positve!*/
);

*This para is important for making correct fake axis;
%let axis_step=1;
************************************************************************;
*Get records with negative values in &dsdin;
data &dsdin._neg;
set &dsdin (where=(&axis_var<0));
*temporarily make all negative axis_var as positve ones;
&axis_var=&axis_var*-1;
%if &NotChangePosVals=1 %then %do;
&axis_var=&axis_var/&fc2scale_pos_vals;
%end;
run;

%if %totobsindsd(&dsdin._neg)=0 %then %do;
  %put Warning: there are NO negative values in the dsd &dsdin._neg;
  %abort 255;
%end;

*Make fake_axis for the dsd &dsdin._pos;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin._neg,
axis_var=&axis_var,
axis_grp=&axis_grp,
new_fake_axis_var=&new_fake_axis_var,
dsdout=&dsdin._neg_fk,
axis_step=&axis_step
);
/*
data &dsdin._neg_fk;
set &dsdin._neg_fk;
%if &NotChangePosVals=1 %then %do;
%end;
%else %do;
&new_fake_axis_var=&new_fake_axis_var*&fc2scale_pos_vals;
%end;
run;
*/

*change back all newly created vars into negative ones;
*including mid_val, tpos, &axis_var, fake&axis_grp, and grp_n;
data &dsdin._neg_fk;set &dsdin._neg_fk;
mid_val=mid_val*-1;grp_n=-1*grp_n;
tpos=tpos*-1;&axis_var=&axis_var*-1;
&new_fake_axis_var=&new_fake_axis_var*-1;
n=n*-1;grpnum=-1*grpnum;
run;

************************************************************************;
*Get records with postive values in &dsdin;
data &dsdin._pos;
*Here would be a potential bug if 0 is the top value in a group with all negative values;
*However, for gene track and scatterplot, this is unlikely happen, as the scatterplot;
*usually has all positive values, including 0;
set &dsdin (where=(&axis_var>=0));
*set &dsdin (where=(&axis_var>0));
*Scale position value and make it larger by fold change;
%if &NotChangePosVals=0 %then %do;
&axis_var=&axis_var*&fc2scale_pos_vals;
%end;
run;

%if %totobsindsd(&dsdin._pos)=0 %then %do;
  %put There are NO positive values in the dsd &dsdin._pos;
  %abort 255;
%end;

*Make fake_axis for the dsd &dsdin._pos;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin._pos,
axis_var=&axis_var,
axis_grp=&axis_grp,
new_fake_axis_var=&new_fake_axis_var,
dsdout=&dsdin._pos_fk,
axis_step=&axis_step
);

******************Combine fake negative and positve dsds****************;
data &dsdout;
*Note: put the neg dsd first;
set &dsdin._neg_fk &dsdin._pos_fk;
grp_end_tag=tag;
run;

************************************************************************;
*Generate real y axis labels;
%global &yaxis_macro_labels fake_max_y fake_min_y fake_refline_values;

*focus on negative axis values first;
data &dsdin._neg_fk;
set &dsdin._neg_fk;
max_neg=0;
run;
proc sql noprint;
select floor(&axis_var),max_neg
into: min_neg_y4grps separated by " ",
    : max_neg_y4grps separated by " "
from &dsdin._neg_fk
where tag=1
order by n;
proc sql noprint;
select tpos into: fake_refline_values_neg separated by " "
from &dsdin._neg_fk
where tag=1
order by n;
*All max_neg_fale_axis_var will be 0;
*Need to remove the 1st num in fake_refline_values;
%let fake_refline_values_neg=%sysfunc(prxchange(s/^[\-\d\.]+\s*//,-1,&fake_refline_values_neg));

*focus on positive axis values now;
data &dsdin._pos_fk;
set &dsdin._pos_fk;
min_pos=0;
run;
proc sql noprint;
select ceil(&axis_var),tpos,min_pos
into: max_pos_y4grps separated by " ",
    : fake_refline_values_pos separated by " ",
    : min_pos_y4grps separated by " "
from &dsdin._pos_fk
where tag=1
order by n;
*All min_pos_false_axis_var will be 0;
*Need to remove the last num in fake_refline_values;
%let fake_refline_values_pos=%sysfunc(prxchange(s/ [\d\.]+$//,-1,&fake_refline_values_pos));

%let fake_refline_values=&fake_refline_values_neg &fake_refline_values_pos;
%let max_y4grps=&max_neg_y4grps &max_pos_y4grps;
%let min_y4grps=&min_neg_y4grps &min_pos_y4grps;

%put max_y4grps: &max_y4grps;
%put min_y4grps: &min_y4grps;

*Also get the min_val when ll=1;
*Get the macro var fake_max_y value;
data _null_;
set &dsdout end=eof;
if eof then call symputx('fake_max_y',ceil(&new_fake_axis_var));
run;

%let fake_min_y=%scan(&min_y4grps,1,%str( ));
%let fake_min_y=%sysfunc(floor(&fake_min_y));

%let nums=;
*The macro &axis_step will affect the following codes;
*The default step is equal to 1, so there is no adjustment;
*If the step=2, then all _min_y and _end_ need to be minused by 1;

%do xi=1 %to %sysfunc(countw(&max_y4grps));
  *use %str( ) to prevent from lossing of negative nums;
                
	  	%let _min_y=%scan(&min_y4grps,&xi,%str( ));
                %if %sysevalf(&_min_y < 0) %then %do;
                  %let _end_=0;     
                %end;
                %else %do;
                  %let _min_y=%sysevalf(&_min_y+&axis_step,floor);
                  %let _end_=%sysevalf(%scan(&max_y4grps,&xi,%str( ))+&axis_step,ceil);
                %end;
                
                
               /* 
		%if %eval(&_min_y > -1) and %eval(&_min_y < 0)  %then %do;
                  *for negative axis, there is no offset of 1;
                  %let _min_y=%eval(&_min_y-1);
                  %let _end_=%eval(&_end_-1);
		%end;
	      */
		
		%put _min_y is &_min_y;
			
		%if %eval(&xi=1) %then %do;
       %if &NotChangePosVals=0 %then %do;
                  %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
        %end;
       %else  %do;/*Scale back the nums when NotChangePosVals is true;*/
                  %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=1,quote=1,mod_num2keep=&mod_num2keep);
                  *Need to scale the negative values back to its original values for the axis ticks;
                  %if %sysfunc(prxmatch(/\-/,&&nums&xi)) %then %let nums&xi=%scale_nums_in_list(list=&&nums&xi,factor=%sysevalf(&fc2scale_pos_vals),contain_double_quote=1);
                  *Note: use . to represent single double quote, as SAS will crash if using single quote in prxchange;
                  %let nums&xi=%sysfunc(prxchange(s/[^\-][\-\d]+\.\d+./" "/,-1,&&nums&xi));
                  %put nums&xi are: &&nums&xi;

       %end;        
		 %let nums=&&nums&xi;
     %put &nums;
     %let nums=%sysfunc(prxchange(s/\.\d+//,-1,&nums));
     %put &nums;
		 *Need to replace the last value as empty;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
     *Let the rgx not match -\d+, such as -1, -2, ..., and other negative numbers;
     *Otherwise, this bug would lead to unmatched quotes in the macro;
      %let nums=%sysfunc(prxchange(s/[^\-](\d+).$/" "/,-1,&nums));
/*      %let nums=%trim(%left(&nums));*/
		%end;
		
    %else %do;
       %if &NotChangePosVals=0 %then %do;
		              %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
       %end;
       %else %do;/*Scale back the negative nums when NotChangePosVals is true;*/
		              %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=1,quote=1,mod_num2keep=&mod_num2keep);
       %end;

		 *Need to replace the last value as empty;

     %let nums&xi=%sysfunc(prxchange(s/\.0//,-1,&&nums&xi));
     %put Unmodified num&xi are:;
     %put &&nums&xi;
     *Note: the rgx will remove the last element as empty;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
		 %let new_nums=%qsysfunc(prxchange(s/[^\-](\d+).$/" "/,-1,&&nums&xi));
		 %put modified new_nums are:; 
     %put &new_nums;
		 %let nums=&nums &new_nums;
     *If the value of &nums is too long to be truncated to contain an unmatched quote;

		%end;
		
   %end;

   *Need to remove fake_refline_values in the list of yaxis_macro_labels;
   %do ni=1 %to %ntokens(&fake_refline_values);
           %if &ni=1 %then %do;
               %let _refnum_=%scan(&fake_refline_values,1,%str( ));
           %end;
           %else %do;
               *Note: the fake refline values need to be substracted with the fake refline value before it;
						   %let _refnum_=%sysevalf(%scan(&fake_refline_values,&ni,%str( )) - %scan(&fake_refline_values,&ni-1,%str( )));
            %end;
            %let nums=%sysfunc(prxchange(s/[^\-]&_refnum_\D/" "/,1,&nums));
    %end;
     *Also need to remove the last fake refline value as the top value;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
     %let nums=%sysfunc(prxchange(s/[^\-](\d+).$/" "/,1,&nums));

	%let &yaxis_macro_labels=&nums;
	%put generated the global macro var &&yaxis_macro_labels for labeling y axis, which are: &&&yaxis_macro_labels;
		%put generated the global macro var fake_min_y, the value of which are all 0s;
	 %put generated the global macro var fake_max_y, the value of which is &fake_max_y;
		%put generated the global macro var fake_refline_values, the value of which can be used to make reflines to separate grps:;
		%put &fake_refline_values;
/*    %abort 255;*/

%mend;


/* Source companion/research/advanced_figures/sources/definitions/make_fake_axis_values4grps.sas */
%macro make_fake_axis_values4grps(
/*This macro has issue when axis_var containing positve and negative values among different grps*/
dsdin,
axis_var,
axis_grp,
new_fake_axis_var,
dsdout,
yaxis_macro_labels=ylabelsmacro_var,
step4yaxis_macro_labels=1,/*Only keep ticks with mod(t,step)=0, which will prevent the y-axis ticks from too compacted with each other!*/
fc2scale_pos_vals=2, /*Use this fc to enlarge the proportion of positive values in the plots
It seems that fc=2 is the best for the final ticks of different tracks;
*/
mod_num2keep= /*Default is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0*/
);

*Fix a bug when only one record in a group;
*make an extra copy for the records to make it has >1 records;
*This is because the script will not be able to update corrected;
*y axis labels if there is only one record for a group;
proc sql;
create table _single_ as 
select *
from &dsdin
group by &axis_grp
having count(&axis_grp)=1;
data &dsdin;
set &dsdin _single_;
data &dsdin;
set &dsdin;
*Scale position value and make it larger by fold change;
if &axis_var>0 then &axis_var=&fc2scale_pos_vals*&axis_var;
run;

*add 2 to the max value to make grps separated better;
proc sql;
create table &dsdout as
select a.*,&axis_var as &new_fake_axis_var,
       floor(min(&axis_var)) as min_val,
       ceil(max(&axis_var))+2 as max_val
from &dsdin as a
group by &axis_grp
order by &axis_grp,&axis_var;

data &dsdout;
retain max grpnum mtag 0;
set &dsdout;
grp_end_tag=0;
if first.&axis_grp then do;
*important to set max^=0;
*No other value can be used, as 0 is very special;
 if max^=0 then do;
/*	 if min_val<0 then do;*/
/*		 *The 1st one of each grp would be the min_val;*/
/*   &new_fake_axis_var=max-min_val;*/
/*		end;*/
/*		else do;*/
/*   &new_fake_axis_var=&axis_var+max;*/
/*		end;*/
	  *As max value is integer, the 1st y value if not integer, need to add back its decimal value;
	  &new_fake_axis_var=max+(&axis_var-min_val);
   grpnum=grpnum+1;
 end;
 else do;
  &new_fake_axis_var=&axis_var;
		mtag=1;
  grpnum=1;
 end;
end;

else if last.&axis_grp then do;
 grp_end_tag=1;
	*important to set max^=0;
	*also need to check mtag,which forces to run the following when passed the;
	*the 1st element;
 if max^=0 then do;
   &new_fake_axis_var=(&axis_var-min_val)+max;
/*		*for negative min_val, it is necessary to adjust max;*/
/*		if min_val<0 then do;*/
/*		  *when max is still equal to 0, keep it as 0;*/
/*		  if max^=0 then do;*/
/*     max=max+max_val-min_val;*/
/*					*Important to make it as the close largest integer;*/
/*					max=ceil(max);*/
/*				end;*/
/*		end;*/
/*		else do;*/
/*			 *max=max+max_val;*/
/*		  *The above can not be used;*/
/*		  *Not 100% sure why the following works!;*/
/*		   max=&axis_var-min_val+2+max;*/
/*					max=ceil(max);*/
/*		end;*/
			 *Use correct syntax;
			 max=ceil(&new_fake_axis_var)+2;
 end;
 else do;
  &new_fake_axis_var=&axis_var;
		*for negative min_val, it is necessary to adjust max;
		*Only if max^=0, the value of max will be updated;
		if min_val<0 and max^=0 then do;
   max=max+max_val-min_val;
			max=ceil(max);
		end;
		else do;
			max=max+max_val;
			max=ceil(max);
		end;
 end;
	mtag=0;
end;

else do;
  if min_val<0 then do;
     &new_fake_axis_var=&axis_var-min_val+max;
		end;
		else do;
		  *this is wrong;
/*				&new_fake_axis_var=&axis_var+max;*/
	  	&new_fake_axis_var=&axis_var-min_val+max;
		end;																																																	                                                                                                                                                           
		if max=0 and mtag=1 then &new_fake_axis_var=&axis_var;
end;
output;
*drop min max min_val max_val;
*Make sure to sort by two vars;
by &axis_grp &axis_var;
run;

*Generate real y axis labels;
%global &yaxis_macro_labels fake_max_y fake_min_y fake_refline_values;
proc sql noprint;
select max_val,min_val,max-1 
into: max_y4grps separated by " ",
    : min_y4grps separated by " ",
				: fake_refline_values separated by " "
from &dsdout
where grp_end_tag=1
order by grpnum,&axis_var;

%put max_y4grps: &max_y4grps;
%put min_y4grps: &min_y4grps;

*Also get the min_val when grp_end_tag=1;
*Get the macro var fake_max_y value;
data _null_;
set &dsdout end=eof;
if eof then call symputx('fake_max_y',ceil(&new_fake_axis_var));
run;

%let fake_min_y=%scan(&min_y4grps,1,%str( ));
%let fake_min_y=%sysfunc(floor(&fake_min_y));

%let nums=;
%do xi=1 %to %sysfunc(countw(&max_y4grps));
  *use %str( ) to prevent from lossing of negative nums;
		%let _min_y=%scan(&min_y4grps,&xi,%str( ));
		%put _min_y is &_min_y;
		%if %eval(&xi=1) %then %do;
   /* %nums_in_range(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,quote=1);*/
    %nums_in_range_adj_scale(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
				%let nums=&&nums&xi;
				*Need to replace the last value as empty;
   %let nums=%sysfunc(prxchange(s/\S+$/" "/,-1,&nums));
		%end;
		%else %do;
/*		  %nums_in_range(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,quote=1); */
		  %nums_in_range_adj_scale(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,
                                 filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
				*Need to replace the last value as empty;
				%let new_nums=%sysfunc(prxchange(s/\S+$/" "/,-1,&&nums&xi));
				%put modified new_nums are: &new_nums;
				%let nums=&nums &new_nums;
		%end;
	%end;
	%let &yaxis_macro_labels=&nums;
	%put generated the global macro var &&yaxis_macro_labels for labeling y axis, which are: &&&yaxis_macro_labels;
		%put generated the global macro var fake_min_y, the value of which is &fake_min_y;
	 %put generated the global macro var fake_max_y, the value of which is &fake_max_y;
		%put generated the global macro var fake_refline_values, the value of which can be used to make reflines to separate grps:;
		%put &fake_refline_values;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/map_grp_assoc2gene4covidsexgwas.sas */
%macro map_grp_assoc2gene4covidsexgwas(
/*Note: this macro uses a internal macro Multgscatter_with_gene_exons
Also, the macro will only focus on protein coding genes and its exons as demonstrated 
at lines 125 in the macro as follows:
type in ("gene" "exon") and protein_coding=1
It is possible to focus on transcript and its exons by updating the above code;
*/
focus_on_transcript=1,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/
gwas_dsd=FM.f_vs_m_mixedpop,/*Requires to have the arbitary var 
chr in the input gwas dsd*/
gtf_dsd=FM.GTF_HG19,/*Need to use sas macro import gtf to save GTF_HG19;
these vars are arbitrary, such as chr, st, end, protein_coding (1 or 0)
and type of bed region (gene or exon);*/
chr=,
min_st=,
max_end=,
dist2genes=100000,
AssocPVars=pval gwas1_p gwas2_p,
ZscoreVars=diff_zscore gwas1_z gwas2_z,
design_width=800,/*Width*height=800*800 would be the best for publication*/
design_height=800,
image_dpi=300,
barthickness=8,
dotsize=6,
grp_font_size=8,/*font size for gene labels in the bottom gene track*/
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
dist2sep_genes=0.3, /*
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!
*/
where_cndtn_for_gwasdsd=%str() /*add filters to the input gwas_dsd; such as pval < 0.05 or gwas1_p < 0.05 or gwas2_p < 0.05*/,

shift_text_yval=-0.2, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

gwas_pos_var=pos,
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
gwas_labels_in_order=gwas1_vs_gwas2 gwas1 gwas2, /*Provide gwas names matched with the numeric scatter_grp_var
Use _ to represent blank space in each name, and these _ will be changed back into blank space!*/
makedotheatmap=0,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/

color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=, /*Optional character variable containing '*' for LD-linked variants.*/
ld_marker_color=black,
ld_marker_legend_symbol=*,
ld_heatmap_var=,
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
ld_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=,
font_size4textlabels=10,
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=0, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=0.15,/*For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 5 top SNPs if track_width between 500 and 800, or 6 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=0.25, /*If draw scatterplot marker labels on the top of track, 
 this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=,/*Optional visible title naming the color metric.*/
adj_spaces_among_top_snps=1 /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);
%if %ntokens(&gwas_labels_in_order)^=%ntokens(&AssocPVars) %then %do;
  %put Please ensure the gwas_labels_in_order has the same number of elements as that of AssocPVars;
  %put gwas_labels_in_order=;
  %put AssocPVars=;
  %abort 255;
%end;

%let orig_minst=&min_st;
%let orig_maxend=&max_end;

%let min_st=%sysevalf(&min_st-&dist2genes);
%let max_end=%sysevalf(&max_end+&dist2genes);

*if the dist between min_st and max_end, the range may not be;
*able to cover the gene body, resulting in failure of drawing gene body and exons;
%if %sysevalf(&max_end - &min_st)<1e8 %then %do;
 %put Extend to the st and end position to cover gene bodies and exons;
 %let min_st=%sysevalf(&min_st - 50000000);
 %let max_end=%sysevalf(&max_end + 50000000);
%end;


%let totP=%sysfunc(countw(&AssocPVars));
%if &totP ne %sysfunc(countw(&ZscoreVars)) %then %do;
    %put Please make sure the two macro vars have the same number of parameters:;
    %put Your AssocPVars: &AssocPVars;
    %put Your ZscoreVars: &ZscoreVars;
    %abort 255;
%end;

%if &focus_on_transcript=0 %then %do;
*Need to first select these genes and get their min_pos and max_pos;
*then use these regions to lookup with associaiton signals;
data exons(keep=_chr_ st end grp pi type &Variant_Length_Var);
length _chr_ $5.;
*Enlarge the length of grp, which may be truncated if too short!;
length grp $30.;
set &gtf_dsd;
pi=0;
grp=genesymbol;
_chr_=cats("chr",put(chr,2.));
where chr=&chr and 
( (st between &min_st and &max_end) or (end between &min_st and &max_end) )
and 
/* type="gene" and protein_coding=1; */
/*This does not work as expected, as some exons belonging to the same gene are colored differently*/
/*It is also very time-consuming*/
/* type in ("exon" "gene") and protein_coding=1; */
type in ("gene" "exon") and protein_coding=1 and genesymbol not contains '.';
/*and genesymbol not contains 'ENSG';*/
run;
/* %abort 255; */
%end;
%else %do;
*Need to first select these transcripts of genes and get their min_pos and max_pos;
*then use these regions to lookup with associaiton signals;
data exons(keep=_chr_ st end grp pi type &Variant_Length_Var);
length _chr_ $5.;
*Enlarge the length of grp, which may be truncated if too short!;
length grp $50.;
set &gtf_dsd;
pi=0;
*Note that transcript variable ensembl_transcript is used to replace gene variable;
grp=ensembl_transcript;
_chr_=cats("chr",put(chr,2.));
where chr=&chr and 
( (st between &min_st and &max_end) or (end between &min_st and &max_end) )
and 
/* type="gene" and protein_coding=1; */
/*This does not work as expected, as some exons belonging to the same gene are colored differently*/
/*It is also very time-consuming*/
/* type in ("exon" "gene") and protein_coding=1; */
type in ("transcript" "exon") and protein_coding=1 and genesymbol not contains '.';
/*and genesymbol not contains 'ENSG';*/
run;

*Need to update the type of transcript as gene to draw each transcript as that of a gene in the final track of scatter plots;
data exons;
set exons;
if type="transcript" then type="gene";
run;
/* %abort 255; */
%end;


*Important to remove dup exons;
proc sort data=exons nodupkeys;by _all_;run;

*Count how many exons in the exons dsd;
*If there are more than 1000, keep only gene and exclude all exons;
proc sql noprint;
select count(type) into: tot_exons
from exons
where type="exon";
%put There are &tot_exons unique exons!;
%if &tot_exons > 20000 %then %do;
%put There are too many exons in the input dataset, with n=%left(&tot_exons)!;
%put The macro will exclude these exons;
/*%abort 255;*/
data exons;
set exons;
where type^="exon";
run;
%end;


*Need to drop the var type;
data exons;
set exons(drop=type);
run;
proc sql noprint;
select count(*) into: tot_bed_regs
from exons;
%if &tot_bed_regs > 20000 %then %do;
  %put Too many bed regions in your exon dsd;
		%put Only < 20000 bed regions can be fastly draw by the macro;
		%abort 255;
%end;

*Need to extend the min_st and max_end for better visualization in the final figure;
proc sql noprint;
select min(st)-1000-&dist2genes, max(end)+1000+&dist2genes 
into :min_gpos,:max_gpos
from exons;
*Need to compare it with original input min_st and max_end;
/* Large positions can be formatted as 6.601E7 or 1.1708E8.  A plain
   macro %IF may compare those strings lexically and clip away the lead SNP. */
%if %sysevalf(&max_end>&max_gpos,boolean) %then %let max_gpos=&max_end;
%if %sysevalf(&min_st<&min_gpos,boolean) %then %let min_gpos=&min_st;
%if %sysevalf(&min_gpos<0,boolean) %then %let min_gpos=0;
%put The final chromosomal range for your query region is from &min_gpos to &max_gpos;
%put However, we will restrict the x-axis to the original min and max genomic position in the final figure;
*Need to enlarge the grp length by asigning longer comman label for it;
*Filter input gwas_dsd with where condition to reduce the total number of markers;
*Assign enough length for the variable grp, which will be further combined with gene names later;
*Larger length will avoid of truncating of gene names;
proc sql;
create table signal_dsd as
select 
     %if %length(&color_resp_var)>0 %then %do;
       &color_resp_var,
     %end;
     %if %length(&var4label_scatterplot_dots)>0 %then %do;
       &var4label_scatterplot_dots,
     %end;
     %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
       &var4mark_ld_scatterplot_dots,
     %end;
     %if %length(&Variant_Length_Var)>0 %then %do;
       &Variant_Length_Var,
     %end;
 
     %do i=1 %to &totP;
	    %if &makedotheatmap=1 %then %do;
		%*Use original ZscoreVars for making heatmap later;
		%scan(&ZscoreVars,&i) as AssocGrp&i,
		%end;
		%else %do;
		%*use binary variable to color scatter plot dots when not in heatmap style;
		%*Pos=1 and Neg=0;
        %scan(&ZscoreVars,&i) > 0 as AssocGrp&i,
		%end;
       -log10(%scan(&AssocPVars,&i)) as var4log10P&i,
     %end;
       &gwas_pos_var as st,&gwas_pos_var+1 as end,"GWAS_Assoc_Signal" as grp length=50,
       cats("chr",put(chr,2.)) as _chr_
from &gwas_dsd	
%if %length(&where_cndtn_for_gwasdsd)^=0 %then %do;
(where=(&where_cndtn_for_gwasdsd))
%end;
where chr=&chr and 
(&gwas_pos_var between &min_gpos and &max_gpos);
/*%abort 255;*/

/* The region will be different from the (pos between &minst and &maxend); */

*For debug only;
/*data a;*/
/*set &gwas_dsd;*/
/*run;*/
/*%abort 255;*/

data signal_dsd(where=(var4log10P>0));
*The final output would be necessary with p<0.05;
set signal_dsd;
array X{*} var4log10P1-var4log10P&totP;
array Z{*} AssocGrp1-AssocGrp&totP;
*array W{*} _AssocGrp1-_AssocGrp&totP; *No need anymore;
do pi=1 to dim(X);
   var4log10P=X{pi};
   AssocGrp=Z{pi};
   *_AssocGrp=W{pi};*No need anymore;
   output;
end;
run;
/*%abort 255;*/

data signal_dsd(rename=(_chr_=chr));
set signal_dsd;
if _chr_="chr23" then _chr_="chrX";
data exons(rename=(_chr_=chr));
set exons;
if _chr_="chr23" then _chr_="chrX";
run;
/*%abort 255;*/
*Make sure the two datasets have 4 comman vars, including chr, st, end, and grp;
*Need to ensure the dist2st_and_end as 0 to make the final scatterplot and gene track matching perfectly.;
%Multgscatter_with_gene_exons(
bed_dsd=signal_dsd,
Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
yval_var=var4log10P,
scatter_grp_var=pi,
lattice_subgrp_var=AssocGrp,  /*When &makedotheatmap=0, use AssocGrp to color scatterplot by its direction, i.e., negative and position,
when &makedotheatmap=1, also use AssocGrp to make heatmap for the scatter plot in quantitative way, as the input variable AssocGrp is 
also modified based on the input parameter &makedotheatmap!*/
gene_exon_bed_dsd=exons,/*Too many exons will slow down the macro dramatically*/
dist2st_and_end=0,
design_width=&design_width,
design_height=&design_height,
image_dpi=&image_dpi,
barthickness=&barthickness,
dotsize=&dotsize,
grp_font_size=&grp_font_size,
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
min_dist4genes_in_same_grps=&dist2sep_genes, /*
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
sc_labels_in_order=&gwas_labels_in_order, /*Provide scatter names matched with the numeric scatter_grp_var*/
min_xaxis=&orig_minst,
max_xaxis=&orig_maxend,
yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop,/*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=&scatter_yaxis_label, /*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=&heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=&plot_title,
shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=&pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

makedotheatmap=&makedotheatmap,/*Use the default value 0 of &makedotheatmap to draw scatter plot in two color modes;
Assign value 1 to it to use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=&heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=&heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/
makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=&pct2adj4dencluster,
var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=&var4mark_ld_scatterplot_dots,
ld_marker_color=&ld_marker_color,
ld_marker_legend_symbol=&ld_marker_legend_symbol,
ld_heatmap_var=&ld_heatmap_var,
ld_heatmap_colormodel=&ld_heatmap_colormodel,
ld_heatmap_legend_title=&ld_heatmap_legend_title,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);
%mend;


/* Source companion/research/advanced_figures/sources/definitions/mkfmt4grps_by_var.sas */
%macro mkfmt4grps_by_var(
grpdsd,
grp_var,
by_var,/*Empty value is possible for this var, which is handy 
when there would be duplciates of grp_var after sorting by 
grp_var and by_var for the by_var to make a new format*/
outfmt4numgrps,
outfmt4chargrps,
dsd4fmt=dsd4fmt, /*This dataset can be used to get fmt info*/
numstarter=1 /*This will restrict the starter as 1 or other supplied number;
such as 0, which would be helpful when it is necessary to use different range
for making the format*/
);
%local rnd;

proc sort data=&grpdsd(keep=&grp_var &by_var) nodupkeys out=grpdsd;
*Make sure to sort it first by &by_var, and then by &grp_var;
*This was wrong, as some grps will be excluded by nodupkeys sorting with &by_var first;
by &grp_var &by_var;
run;

proc sql noprint;
select max(ndup_grps) into: maxdups
from 
(select count(*) as ndup_grps
from grpdsd
group by &grp_var)
;

%if &maxdups >1 %then %do;
		   %put Please evaluate the data set grpdsd for the combination between two vars, including &grp_var and &by_var;
		   %put It is necessary to have no duplicates in the first grp_var: &grp_var;
		   %put Currently there are duplicates for grp_var &grp_var after running proc sort nodupkeys by the two vars;
		   %put You may try to replace the two vars by using grp_var and grp_var, which means to use grp_var to replace the by_var;
		   %abort 255;
%end;

*The above dataset may still contains duplicates of &grp_var;
*Need to keep all unique &by_var and &grp_var;
/* proc sort data=grpdsd nodupkeys;by &grp_var; */
/* proc sort data=grpdsd;by &by_var &grp_var; */
/* run; */

*Need to sort grps by the by_var for making formats;
*Only when the by_var is not empty, run this codes;
%if %length(&by_var)>0 %then %do;
proc sort data=grpdsd;by &by_var;run;
%end;

/* Use a timestamp-derived suffix so this helper does not depend on
   a separately compiled random-number macro. */
%let rnd=%sysfunc(floor(%sysfunc(datetime())));
%let rnd=&rnd._;
data fmt4numgrps&rnd;
set grpdsd;
fmtname = "&outfmt4numgrps";
type = "I";
label = _N_ +  &numstarter - 1;
rename &grp_var = start;
run;
proc format cntlin=fmt4numgrps&rnd;
run;
quit;
data fmt4chargrps&rnd;
set grpdsd(drop=&by_var);
*Do not use &by_var here to asign group specific order for start;
*This will be a bug when there are duplicates in the &by_var;
/* by &by_var; */
start = _N_ + &numstarter - 1;
rename &grp_var=label;
fmtname = "&outfmt4chargrps";
type = "n";
run;
proc format cntlin=fmt4chargrps&rnd;
run;
%if %length(&dsd4fmt)>0 %then %do;
data &dsd4fmt;
set fmt4chargrps&rnd;
run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/ntokens.sas */
%macro ntokens(list);
    %if %length(%superq(list))=0 %then 0;
    %else %eval(1 + %length(%sysfunc(compbl(&list))) - %length(%sysfunc(compress(&list))));
%mend ntokens;


/* Source companion/research/advanced_figures/sources/definitions/numargs.sas */
%macro numargs(arg);
   %if &arg= %then %do;
        0
      %end;
    %else %do;
       %let n=1;
       %do %until (%qscan(&arg,%eval(&n),%str( ))=%str()); 
         %let n=%eval(&n+1);
       %end;
       %eval(&n-1)
    %end;
%mend numargs;


/* Source companion/research/advanced_figures/sources/definitions/number_rows_by_grp.sas */
%macro number_rows_by_grp(
dsdin,
grp_var,
num_var4sort,
descending_or_not,
dsdout
);

%if &descending_or_not %then %do;
proc sort data=&dsdin;
key &grp_var &num_var4sort/ descending;
run;
%end;
%else %do;
proc sort data=&dsdin;
key &grp_var &num_var4sort;
run;
%end;

proc sort data=&dsdin;by &grp_var;
run;

data &dsdout;
retain ord 0;
set &dsdin;
if first.&grp_var then do;
 ord=1;output;
end;
else if not last.&grp_var then do;
 ord=ord+1;output;
end;
else if last.&grp_var then do;
 ord=ord+1;output;
 ord=0;
end;
by &grp_var;
run;

%if &descending_or_not %then %do;
proc sort data=&dsdout;
key &grp_var &num_var4sort / descending;
run;
%end;
%else %do;
proc sort data=&dsdout;
by &grp_var &num_var4sort;
run;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/nums_in_range_adj_scale.sas */
%macro nums_in_range_adj_scale(
/*Note: the scale can only be integer with value >=1, as the macro will only be able to scale down the numbers in range!*/
st,/*start value that can be negative and position*/
end,/*end value*/
by,/*by value for each step; make sure it is matchable with st and end values*/
outmacrovar,/*created a global macro var containing linked nums by space for later access*/
filter4scaledvals=%str(>0),/*Only apply the scaling to specific numbers met the filter*/
scale=2,/*integer num to scale down the nums, i.e., num/scale, that will be in the final macro var*/
quote=1, /*quote the nums and separated by space in the final macro var*/
mod_num2keep= /*Default is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0*/
);
				%global &outmacrovar;
				*This make the format include larger or negative numbers;
				/**Note: sometimes the negative numbers may be out of range of the format;
				%let numlength=%eval(%length(&end)+1);
                                %if %eval(&numlength<3) %then %let numlength=3;
                                */
                                *Use 8 as the default, which is even better, as the above will missing numbers, such as 0.666;
                                %let numlength=8;
				
				data range;
				*Make sure not to use if condition within the do loop in datastep;
				*otherwise, sas will run forever within the do loop!;
				do i=&st to &end by &by;
                                  output;
                                end;
                                run;

                                *Filter data and replace these selected values that can not be modded by scale value;
                                data range;
                                set range;
                                ord=_n_;
				 *scale the value i by scale;
                                 if i &filter4scaledvals then do;
                                    *Only keep these numbers can be modded by the &scale;
                                    *https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/ds2ref/n0t9j8b09x4uphn1kl1i70x63z19.htm;
                                    *If &scale<1, such as 0.3, 10*i/3=>remain*0.1;
                                    if mod(i,&scale)=0 then i=i/&scale;
                                    else i=round(i/&scale,0.1);
                                 end;
				run;

       %if %length(&mod_num2keep)>0 %then %do;
                data range;
                set range;
                *Note: only focus on i passed the filter of i &filter4scaledvals;
                if i &filter4scaledvals and mod(i,&mod_num2keep)^=0 then i=.;
                run;
       %end;
        
       
				proc sql noprint;
				%if %eval(&quote=1) %then %do;
				  select quote(prxchange("s/^\./ /",-1,trim(left(put(i,&numlength..1))))) 
                                  into: &outmacrovar separated by " "
                                %end;
				%else %do;
			          select prxchange("s/^\./ /",-1,trim(left(left(put(i,&numlength..1))))) into: &outmacrovar separated by " "
				%end;
				from range
				order by ord;
				drop table range;
				quit;

/*                              Can not replace these missing values as blank space, as later the global macro var seems be changed as local   */
/*				%let &outmacrovar=%sysfunc(rgxchange(s/\./ /,-1,&&&outmacrovar));                                              */

				%put generated numbers for the range from &st to &end by &by are: &&&outmacrovar;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/rank4grps.sas */
%macro rank4grps(grps,dsdout);
data &dsdout;
length grps $300.;
%do i=1 %to %sysfunc(countw(%superq(grps),%str( )));
  %let gval=%qscan(%superq(grps),&i,%str( ));
  grps="&gval";num_grps=&i;
  output;
%end;
run;
proc sort data=&dsdout;by grps;
data &dsdout;
set &dsdout;
char_ord=_n_;
run;
proc sort data=&dsdout;by num_grps;
run;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/rows_in_sas_dsd.sas */
%macro rows_in_sas_dsd(test_dsd);
%local dsid nlobs rc;
%let nlobs=0;
%let dsid=%sysfunc(open(&test_dsd,IS));
%if &dsid=0 %then 
%put %sysfunc(sysmsg());

%let nlobs=%sysfunc(attrn(&dsid,NLOBS));
%let rc=%sysfunc(close(&dsid));

&nlobs

%if &nlobs gt 1 %then %do;
 %put There are &nlobs in your dataset;
%end;

%mend;


/* Source companion/research/advanced_figures/sources/definitions/sas_dsd_exist.sas */
%macro sas_dsd_exist(sasdsd,lib=work);
%local sas_dt_exist;
%let sas_dt_exist=0;
%if %sysfunc(prxmatch(/\./,&sasdsd)) %then %do;
   %let lib=%scan(&sasdsd,1,.);
   %let sasdsd=%scan(&sasdsd,2,.);
%end;
%let sas_dt_exist=%sysfunc(exist(&lib..&sasdsd));
&sas_dt_exist
%mend;


/* Source companion/research/advanced_figures/sources/definitions/scale_nums_in_list.sas */
%macro scale_nums_in_list(/*Note that the input list with or without double quotes should be delimited by space*/
list,
factor,
contain_double_quote=1
);
%local _list_ _a_;
%*remove double quotes if there;
%if &contain_double_quote=1 %then %do;
  %let list=%qsysfunc(prxchange(s/" "/ /,-1,&list));
  %let list=%qsysfunc(prxchange(s/"(.*)"/$1/,-1,&list));
  %*%put Input list has been removed for double quotes: &list;
%end;
%let _list_=;
%do li=1 %to %ntokens(&list);
				%let _a_=%sysevalf(&factor*%scan(&list,&li,%str( ))); 
        %let _list_=&_list_ &_a_;
%end;
%if &contain_double_quote^=1 %then %do;
        &_list_
%end;
%else %do;
				%let _list_="%sysfunc(prxchange(s/ /" "/,-1,&_list_))";
        &_list_
%end;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/select_element_range_from_list.sas */
%macro select_element_range_from_list(
list=,
st=1,	
end=,	/*If empty, the total number of elements will be used by it*/
sublist=sublist,/*Output a global macro variable for using by other SAS codes*/
sep=\s /*Perl regular expression for target separator (no | is allowed to match different separators)*/
);
%global &sublist;
%if %length(&end)=0 %then %let end=%ntokens(&list);
%let slcted_elems=%sysfunc(prxchange(s/^([^&sep]+&sep?){%sysevalf(&st-1)}(([^&sep]+&sep?){%sysevalf(&end-&st+1)}).*/\2/,-1,%bquote(&list))); 
*Need to remove the last separator;
*Note: the bquote for the macro var slcted_elems in case that it contain comma!;
%let slcted_elems=%sysfunc(prxchange(s/&sep$/ /,-1,%bquote(&slcted_elems)));
%put &slcted_elems;
%let &sublist=&slcted_elems;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/spaceAdjust.sas */
%macro spaceAdjust(
/*
 This macro can generate new numbers by adjusting its distance space
 in the sorted numbers, so please ensure the input dataset containing
numbers that are sorted in ascending order; if the input is a list, the macro
will generate a sorted dataset and generate adjust numbers automatically.
*/
data=, /*Input dsd with long format with vars like col1-coln
or a list containing blank space separated elements*/
out=, /*out dsd in long format but only contains one column AdjPos*/
goal=COL:,/*Target column vars in the input data set, such as col1-coln*/ 
sep=, /*Minimum distance to separate numbers in the input data set and 
adjust the number by ensuring its distances to left and right numbers
at least greater than the minimum distance*/
newvar4adjnum=AdjPos /*Create a new variable to contain these
position adjusted numers*/);

%if %ntokens(&data)>=1 and %sysfunc(prxmatch(/^\d[\.E\d\s]+/,&data/)) %then %do;
   %put The macro will transform the input list: &data;
   %put into a sas dataset in wide-format that all vars col1-coln containing these input elements;
   %rank4grps(
    grps=&data,
    dsdout=&out);
    data &out;
    set &out;
    value=grps+0;
    *Need to sort these numeric values;
    proc sort data=&out;by value;run;
    proc transpose data=&out(keep=value) out=&out(drop=_name_);
    var value;
    run;
    %let goal=col:;
    %let data=&out;
%end;

  *First save a copy of input dataset for later merging with adjust positions;
  data _old_;
  set &data;
  run;
/*proc print;run;*/
/*%abort 255;*/

%let nvars=%TotVarsInDsd(&data,var_type=_numeric_);
/*  %abort 255;*/
  *Now generate adjust positions for these input numbers;
/*
https://www.lexjansen.com/pharmasug/2010/CC/CC05.pdf
It is important to add options nosyntaxcheck here before the data step that is prone to error;
otherwise, other procedures followed the failed data step will be under the environment of 
options obs=0; adding this is the only solution when running sas codes in batch mode!
*/
OPTIONS NOSYNTAXCHECK;  
data &out.new;
        set &data.;
		*Need to make a copy for these input numbers;
        array u(*) u1-u&nvars;
		*The input numbers will be changed during evaluation in the array w;
        array w(*) &goal.;
        eps1000 = 1000*1E-12; /* SAS equivalent for precision */
        n = dim(w);
        v = &sep.;
        
        /* Initialize output */
		*Ensure these _i_ and _ii_ will not interupt other similar loop vars;
		do _i_=1 to n;
          u[_i_] = w[_i_];
		end;
        do _ii_ = 2 to n;
            w[_ii_] = max(w[_ii_-1] + v, u[_ii_]);
        end;
        
        moving = 1;
		*Only try 500 times optimization, which would prevent the macro run forever;
		nmoving=1;
        do while (moving and nmoving<=500);
            moving = 0;
			nmoving+1;

            i = 1;
			*It is important to restrict the i < n;
			*when i=n, the loop will fail;
            do while (i <n);
                /* Find next block */
                b = 0;
                do j = i to n-1;
                    b+1;*It is necessary to put b+1 here before the leave command!;
                    if abs(w[j+1] - w[j] - v) > eps1000 then leave;
                    /*b + 1;*/
                end;

				*Get the last block;
				*Important: assign b=n-1 if b=0;
				if b=0 then b=n-1;

                sum_u=0;
                sum_w=0;
                do jj=i to i+b;
                  sum_u+u[jj];
                  sum_w+w[jj];
                end;
                
                sh = sum_u/(1+b) - sum_w/(1+b);
                if abs(sh) > eps1000 then do;
				   if i=1 then leftLim=-1E12;
				   else leftLim=w[i-1]+v;
				   if i+b=n then rightLim=1E12;
				   else rightLim=w[i+b+1]-v;
/*				   The following will fail, as ifn will evaluate w[i-1] even when i=1;*/
/*                    leftLim  = ifn(i=1, -1E12, w[i-1] + v);*/
/*                    rightLim = ifn(i+b=n, 1E12, w[i+b+1] - v);*/
                    if w[i] + sh < leftLim then sh = leftLim - w[i];
                    if w[i+b] + sh > rightLim then sh = rightLim - w[i+b];
                    
                    do jjj = i to i+b;
                        w[jjj] = w[jjj] + sh;
                    end;
                    moving = 1;
                end;
                i = i + b + 1;
            end;
            
            /* Move singles */
			/*Use xi but not i*/

/*Matlab original codes for debugging;
	nloop=0;
    while ~isempty(i) && nloop<500
        k0 = abs(diff(w)-v)>eps1000;
        nloop=nloop+1;
        for i = find(([1 k0] & w>u) | ([k0 1] & w<u))
            if i==1; leftLim  =-inf; else leftLim  = w(i-1)+v; end
            if i==n; rightLim = inf; else rightLim = w(i+1)-v; end
            w(i) = max(min(u(i),rightLim),leftLim);
            moving = true;
        end
    end
end % moving
*The following implements the above matlab codes in SAS;
*/

		k0=1;
		niters=0;
		 do while (k0 and niters<=500);
            do xi = 1 to n;
			 if xi=1 and w[xi]>u[xi] then k0=1;
             if xi=n and w[xi]<u[xi] then k0=1; 
             if xi>1 and xi<n then k0 = abs(w[xi] - w[xi-1] - v) > eps1000;
                if k0 then do;
				   if xi=1 then leftLim=-1E12;
                   else leftLim  = w[xi-1] + v;
                   if xi=n then rightLim=1E12;
                   else rightLim = w[xi+1] - v;
                   w[xi] = max(min(u[xi], rightLim), leftLim);
                    moving = 1;
					*Note: when xi=n, the 1st while loop relying on moving=1 might break;
					*For debugging, comment out the following code to test the scenario;
					*if xi=n then moving=0;
					niters+1;
                end;
            end;
		 end;
        end;
    run;
/*proc print data=_old_;run;*/
/* %abort 255;*/
%if %totobsindsd(&out.new)=0 %then %do;
   %put failed to generate adjusted dataset &out.new;
   %put try to use the original input dataset &data without adjustment;
   OPTIONS NOSYNTAXCHECK;
   data &out;
   set _old_;
   run;
%end;
%else %do;
  data &out;
  set &out.new;
  run;
%end;
/*
proc print data=&out;run;
%abort 255;
*/

data &out;
set &out;
keep Col:;
proc transpose data=&out out=&out(rename=(col1=&newvar4adjnum) drop=_name_);
var Col:;
run;

*Now combine the adjust and original numbers;
proc transpose data=_old_ out=_old_(drop=_name_ rename=(col1=orig_num));
var _numeric_;
run;
data &out;
merge _old_ &out;
run;
proc datasets nolist;
delete _old_;
run;
%mend spaceAdjust;


/* Source companion/research/advanced_figures/sources/definitions/totobsindsd.sas */
%macro totobsindsd(mydata);
    %let mydataID=%sysfunc(OPEN(&mydata.,IN));
    %let NOBS=%sysfunc(ATTRN(&mydataID,NOBS));
    %let RC=%sysfunc(CLOSE(&mydataID));
    %if "&NOBS"^="." %then %do;
      &NOBS
    %end;
    %else %do;
       0
    %end;
%mend;


/* Source companion/research/advanced_figures/sources/definitions/varexist.sas */
%macro varexist
/*----------------------------------------------------------------------
Check for the existence of a specified variable.
----------------------------------------------------------------------*/
(ds=        /* Data set name */
,var=       /* Variable name */);

/*----------------------------------------------------------------------
Usage Notes:

%if %varexist(&data,NAME)
  %then %put input data set contains variable NAME;

The macro calls resolves to 0 when either the data set does not exist
or the variable is not in the specified data set.
----------------------------------------------------------------------*/

%local dsid rc ;

/*----------------------------------------------------------------------
Use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.
-----------------------------------------------------------------------*/

%let dsid = %sysfunc(open(&ds));

%if (&dsid) %then %do;
  %if %sysfunc(varnum(&dsid,&var)) %then 1;
  %else 0 ;
  %let rc = %sysfunc(close(&dsid));
%end;
%else 0;

%mend varexist;


%macro af_export(data=,name=);
 data work.af_export_copy;set &data;format _numeric_ best32.;run;
 proc export data=work.af_export_copy outfile="&AF_OUT/&name..csv" dbms=csv replace;run;
%mend;
data work.region;
length SNP $128;
infile datalines4 dlm='09'x dsd truncover;
input CHR BP SNP :$128. EUR_DIFF_P EUR_FEMALE_P EUR_MALE_P EUR_STD_Z EUR_FEMALE_Z EUR_MALE_Z LD_R2;
datalines4;
2	71769324	rs77106038	0.6207029	0.9632	0.4733	-0.494854270400946	-0.0471912478908189	0.718553582335329	0.0036477
2	71770667	rs75205546	0.76301	0.4611	0.1823	0.301530585319451	-0.734563952380952	-1.33846539596774	3.77833e-05
2	71771133	rs6546703	0.5310919	0.8156	0.2158	-0.626340033786053	0.231594970736842	1.24215444161491	0.000819609
2	71771299	rs6739452	0.5257272	0.8139	0.2091	-0.634541917856979	0.236834759210526	1.26102499006211	0.000796519
2	71771470	rs113820554	0.6471015	0.3977	0.7663	-0.457792493406557	-0.844735949618321	-0.296786505783866	0.000238512
2	71771792	rs4852804	0.9223195	0.9239	0.9676	0.0975122519512195	0.0960818028205128	-0.037603386593985	0.000141646
2	71771952	rs10191327	0.9107175	0.9111	0.9627	0.11213349795122	0.108881835641026	-0.0451263212030075	0.000141646
2	71772170	rs137988258	0.2549101	0.1002	0.7851	-1.13850391105954	-1.64425082397004	-0.273621151140065	0.000306315
2	71772549	rs114296573	0.314309	0.2277	0.898	-1.00622166086178	-1.20555601750663	0.12811913903481	0.000184761
2	71772774	rs75392876	0.3086511	0.2105	0.925	-1.01805653497068	-1.25135518696809	0.0933947096993671	0.000198158
2	71772859	rs77937453	0.129519	0.8878	0.03212	-1.5160012577587	-0.140635747556615	2.14321639154161	0.000184761
2	71772953	rs116544815	0.2634764	0.8115	0.04329	1.1182120899706	-0.238110993483146	-2.02130406871658	0.00552583
2	71773227	rs115789906	0.1334474	0.7716	0.008267	1.50064504766384	-0.291119251175407	-2.64200417052632	0.000225033
2	71773356	rs79856873	0.03059556	0.4992	0.008235	2.16229342813081	0.676373746559297	-2.64303340186916	0.000118179
2	71773740	rs4852805	0.774283	0.901	0.7651	0.286777172364243	0.125708429337748	-0.294356608372093	0.000226813
2	71774011	rs4852806	0.4648604	0.8359	0.1706	-0.730866992698102	0.205388200894737	1.3729129757764	0.000843194
2	71774381	rs80223134	0.9308487	0.7543	0.6019	-0.0867770126194783	0.313048745669291	0.520364757590361	0.00663519
2	71774527	rs143174356	0.1178494	0.2521	0.2873	-1.5638644696864	-1.14707890579065	1.06429374935733	0.00033363
2	71774613	rs114892815	0.9308487	0.7539	0.6018	-0.0867770126194783	0.313048745669291	0.520364757590361	0.00663519
2	71775345	rs752748	0.4576503	0.8423	0.1677	-0.742721469224385	0.200145280684211	1.38506257701863	0.000796519
2	71775735	rs78973746	0.8898549	0.7756	0.5705	-0.138487759238581	0.284956821218075	0.568658608433735	0.00663519
2	71775739	rs75671324	0.824635	0.8183	0.5264	-0.221587568994026	0.230206958928571	0.634123801707317	0.00633088
2	71776319	rs78933613	0.8814025	0.7751	0.558	-0.149191560368345	0.284956821218075	0.585597410120482	0.00663519
2	71776345	rs736096	0.763621	0.8907	0.7619	0.300729297853775	0.138013031710526	-0.302138428604651	0.000226813
2	71776346	rs934061	0.5152712	0.8452	0.2175	-0.650651941938831	0.193881409633508	1.23448682160494	0.000796519
2	71776366	rs115183182	0.8492757	0.8608	0.93	-0.190042648830921	-0.1749286821513	0.0880258539339752	0.000118179
2	71776649	rs114007258	0.9031068	0.7658	0.5774	-0.121737582477964	0.298700073477407	0.559007578313253	0.00663519
2	71777110	rs11896395	0.4366624	0.9276	0.1915	0.777841588505657	-0.0890990228082192	-1.30649376370968	0.00105712
2	71778068	rs2303592	0.272172	0.2175	0.8114	-1.0980745558233	-1.23404098659091	0.239899589946092	0.000347329
2	71778492	rs76509802	0.8970506	0.7722	0.5763	-0.129387972609842	0.288829132612967	0.559007578313253	0.00663519
2	71778829	rs35984374	0.112692	0.2334	0.2949	-1.58620847206847	-1.19030311880531	1.04854166317136	0.00033363
2	71779032	rs7582130	0.6073387	0.1861	0.4464	0.513875922956194	1.32017515333333	0.763998067795276	0.000211721
2	71779115	rs11690146	0.2254213	0.7936	0.1188	-1.2122379724848	-0.261115713828829	1.55520537748691	0.00201179
2	71779334	rs6546704	0.5967332	0.1918	0.4699	0.529104150085085	1.30644825	0.724218295590551	0.000219195
2	71779756	rs7599385	0.9376104	0.2918	0.2611	0.0782735335121951	1.05788923717949	1.12018531278195	7.19282e-05
2	71779853	rs7599496	0.7904399	0.3581	0.1341	-0.265739431469717	0.919250845341615	1.50003586470588	8.30644e-06
2	71780215	rs2303596	0.8563436	0.2462	0.2761	0.181030597410976	1.15995437628205	1.09059699090909	8.50527e-05
2	71780248	rs35721373	0.2934868	0.1959	0.9237	-1.05050320273815	-1.29347126207675	0.0963502564171123	0.000347329
2	71780489	rs116605656	0.261047	0.2471	0.7123	-1.12391986685075	-1.1580116394052	0.368102671840355	0.000279111
2	71780821	rs2303597	0.770109	0.8849	0.7797	0.292232371276645	0.146328601847134	-0.280062488181818	7.61902e-05
2	71780906	rs13424178	1	0.08595	0.03584	0	1.7165511961194	2.09870310474453	0.000485875
2	71782067	rs7566581	0.4249941	0.3142	0.9584	0.79778694112345	1.00670491468531	-0.0491950878688525	0.000107277
2	71782242	rs734248	0.3790934	0.1942	0.8635	0.879567960090007	1.30351660129032	0.17404235219697	0.000647555
2	71782418	rs72827541	0.1337924	0.2784	0.2997	-1.49931328163973	-1.08417227915743	1.03842928923077	0.00033363
2	71782447	rs115030664	0.7376819	0.2634	0.4021	0.33492475312848	1.11833072013605	0.838575608652246	9.17332e-05
2	71782671	rs77009704	0.6336778	0.4354	0.113	0.47655662694369	-0.780422616554054	-1.58379016365348	0.000416247
2	71783052	rs72827543	0.1369074	0.2881	0.2965	-1.48740672123396	-1.0641239710177	1.04338604066496	0.00033363
2	71783217	rs111389127	0.8565062	0.9009	0.675	0.180823438608391	-0.124131332795217	-0.419739870811744	0.000171391
2	71784219	rs72827544	0.3963193	0.2651	0.9955	-0.848213068521863	-1.11408665659955	-0.00530557036339523	0.000319959
2	71784645	rs114381220	0.8952068	0.7804	0.5815	-0.13171868609011	0.279244232421875	0.550320137799043	0.00663519
2	71784722	rs13024616	0.01133137	0.7106	0.0005287	2.53231002637782	0.372971074166667	-3.46933046443299	0.0114961
2	71784787	rs75663047	0.9103107	0.7603	0.597	-0.11264654297388	0.305471482777778	0.529827295783784	0.00208139
2	71785187	rs72827546	0.4842493	0.7911	0.1593	-0.699484494215938	0.26574189034375	1.4067286261194	0.0011464
2	71785793	rs72827547	0.1564466	0.3246	0.3044	-1.41712425425677	-0.984585514505494	1.02805869287532	0.00033363
2	71786153	rs6737150	0.615485	0.2211	0.5045	0.502259432339277	1.22304230963855	0.671122974285714	4.38397e-06
2	71786222	rs77110008	0.5957246	0.8491	0.5507	-0.53055864601192	-0.189080265756302	0.595888716748769	0.00175638
2	71786534	rs79565365	0.5506839	0.7637	0.5738	0.596735491296887	0.301115316850829	-0.563555685987261	0.000570383
2	71786559	rs67396654	0.166414	0.3661	0.2846	-1.38381877232293	-0.903444404605263	1.07099108375635	0.00033363
2	71786986	rs10189555	0.9414686	0.1017	0.03418	-0.0734240234535221	1.6351194727003	2.11989853127273	0.000485875
2	71787431	rs11896175	0.1956742	0.681	0.132	1.29397470550704	0.413927737655172	-1.51235352845528	0.00068523
2	71787452	rs116546110	0.26323	0.5726	0.2895	-1.11878948007729	-0.564034234297521	1.06016841610577	0.000252017
2	71788235	rs13415604	0.1464394	0.1713	0.5278	1.45222376323391	1.36865429375	-0.632121119558824	0.0037113
2	71788779	rs115616395	0.4830903	0.5698	0.6792	-0.701340764205839	-0.569964236411609	0.413286884802432	0.000627308
2	71791071	rs72827550	0.2051606	0.04315	0.6723	-1.26698514216145	-2.02249511986456	-0.4216357933687	0.000319959
2	71791332	rs34671418	0.2462956	0.7069	0.1783	-1.15939407074486	-0.377023233259424	1.34714748407311	0.000374812
2	71791577	rs17007067	0.5726842	0.7454	0.6219	-0.564102619734599	-0.322036274878049	0.491593646114286	1.39773e-05
2	71791760	rs55788735	0.9191509	0.2156	0.09364	-0.101503284172319	1.23917724577259	1.67850297	0.000457938
2	71792296	rs13029872	0.2805442	0.8637	0.1429	1.0790976602515	0.173958809548387	-1.46589366259542	0.00364502
2	71793069	rs72827551	0.1294647	0.01638	0.6474	-1.51621618340607	-2.40286094508009	-0.456431783113456	0.000306315
2	71793969	rs56058283	0.1609078	0.02045	0.5956	-1.40202508660501	-2.31738139954338	-0.531650192631579	0.000306315
2	71795460	rs34836829	0.8031115	0.2042	0.2437	0.24932233097496	1.26840825210526	1.16896125422078	0.000361057
2	71795527	rs150759843	0.1034561	0.4125	0.1238	-1.62832463318722	-0.819976843053173	1.53944247648221	0.000238512
2	71797176	rs10183967	0.4332731	0.5763	0.5815	-0.783602970916078	-0.558809565724138	0.552589349593496	6.59209e-05
2	71797712	rs3764971	0.9681054	0.7364	0.7374	0.0399845222577537	0.335440995780347	0.33547844260274	0.000292469
2	71797762	rs34211915	0.3032064	0.3033	0.701	-1.0295816573512	-1.02796714492441	0.3850199145	0.000361057
2	71799647	rs35790663	0.4332788	0.7087	0.4458	0.783593236272455	0.377042509178082	-0.766534678548387	0.0026442
2	71800609	rs72827562	0.1903973	0.1495	0.7474	-1.30940468154079	-1.44259593021077	0.323239566574586	0.000444013
2	71801022	rs12328124	0.5707512	0.3702	0.8573	0.566945457187697	0.896961623870968	0.182986610687023	0.00166232
2	71801099	rs115634094	0.4910741	0.4324	0.8953	-0.688601443472267	-0.78548530113852	0.130818874243119	0.00808538
2	71801564	rs75127120	0.5411288	0.8589	0.2469	0.611106898382294	-0.176409940511364	-1.15416274026846	0.000215938
2	71802434	rs185117753	0.9161747	0.9792	0.8932	-0.105253430176525	-0.026568604	0.133349153591398	7.85498e-05
2	71802540	rs6708393	0.2334473	0.3952	0.4007	1.19152565415414	0.852820538461538	-0.836218236065574	0.00191082
2	71802597	rs55981504	0.2643002	0.2268	0.7638	-1.11628485596044	-1.20901039600939	0.301115316850829	0.000416247
2	71802737	rs12329095	0.9344435	0.8944	0.7783	-0.0822554531215443	0.133541756855204	0.280906118897638	0.00033363
2	71802886	rs10190437	0.2000056	0.3339	0.3985	1.28153571219803	0.965334334265734	-0.843129130578512	0.00357372
2	71802951	rs11680124	0.3662697	0.9498	0.1848	0.903482780904719	0.0613190388404908	-1.32582335362319	0.000686778
2	71803180	rs745917	0.6950429	0.4092	0.7118	0.392020776182608	0.824612011688312	0.369112993230769	0.00156082
2	71803689	rs2042828	0.8036078	0.6543	0.884	0.24868068152227	0.4502493030625	0.148000197259259	0.0012577
2	71803817	rs934071	0.6443766	0.3635	0.7208	0.461588199278788	0.909189587012987	0.361457127384615	0.00154418
2	71804067	rs78477662	0.895216	0.6577	0.7521	0.131706989383822	0.443503264310954	0.316818219668737	0.000158048
2	71804825	rs113817325	0.6106384	0.9608	0.4599	-0.509162307519152	-0.0483575524396135	0.738504483139535	0.000670314
2	71805522	rs10169824	0.1618045	0.281	0.3717	1.39902834077063	1.07762816971831	-0.892404140495868	0.00351531
2	71806112	rs7568834	0.1493445	0.2821	0.3369	1.44185057141262	1.07762816971831	-0.958428582644628	0.00357372
2	71806132	rs62145893	0.7949875	0.6407	0.8777	0.259839650856895	0.467874085672515	0.153320712334495	0.000859832
2	71806615	rs115398625	0.2807415	0.7847	0.04481	1.07865520801475	-0.272957366839378	-2.00836722706612	0.000198158
2	71807096	rs10176282	0.1510531	0.2381	0.4098	1.43582175410687	1.18156976643357	-0.826432403140496	0.00315131
2	71807600	rs57433250	0.2436922	0.5376	0.2838	1.16580775701228	0.6188015423125	-1.0744212	0.000784786
2	71808629	rs17501640	0.7346841	0.3415	0.5356	0.338901251662063	0.951818337980769	0.619229750581395	0.000238512
2	71810891	rs17007074	0.744727	0.5091	0.7792	0.325600070717659	0.660687240117994	0.281617292640845	0.000889453
2	71811604	rs17429787	0.2134365	0.465	0.2928	1.24417147791318	0.734589695804196	-1.05798279669421	0.00266514
2	71811606	rs72827567	0.4070225	0.3574	0.8434	-0.829144687797307	-0.919545286761229	0.197902555153203	0.000430116
2	71812321	rs72827568	0.3963196	0.5561	0.5375	-0.848212567358897	-0.588026389484979	0.616913530099502	0.000361057
2	71812455	rs4852808	0.1126501	0.4031	0.1426	1.58639334115682	0.83700642585034	-1.46812134274194	0.00269698
2	71812750	2:71812750_C_A	0.5832998	0.746	0.6437	0.548571041243634	0.326193054130435	-0.464246966580645	
2	71813055	rs13413696	0.1612633	0.1056	0.7913	-1.40083557560154	-1.62002618553922	0.264861877635328	0.000416247
2	71814289	rs13401232	0.3837587	0.5393	0.5335	-0.870991693061929	-0.612480501298701	0.623797187878788	0.000374812
2	71814760	rs4852810	0.634635	0.9393	0.5195	0.475213125872064	0.0756227521081081	-0.647489883333333	0.0001465
2	71815183	rs72827572	0.3896142	0.4553	0.6527	-0.860317304200684	-0.74755998907767	0.448210362643678	0.000402407
2	71815362	rs72827574	0.1985943	0.1915	0.6531	-1.2855667494874	-1.30586840501253	0.44849067079646	0.000402407
2	71815404	rs17501682	0.8760177	0.8339	0.6259	0.156019488562846	-0.209225089402299	-0.487833363414634	0.000430116
2	71815407	rs17007083	0.2090256	0.1909	0.6882	-1.25624930369969	-1.30650267236181	0.40228220443787	0.000402407
2	71815766	rs13405368	0.6496349	0.6124	0.1931	0.454269439370307	-0.506663878767123	-1.29829795080645	0.00189571
2	71815830	rs78724767	0.8322366	0.4959	0.6363	0.21183400802014	0.680128585839161	0.473320612345679	0.000158048
2	71816112	rs72827577	0.5264109	0.5488	0.7846	-0.633494188747474	-0.600495565010799	0.274296395511222	0.000361057
2	71816419	rs72827579	0.5196108	0.591	0.7168	-0.643945331680279	-0.536907335930736	0.363516345864662	0.000361057
2	71816611	rs72827583	0.5118155	0.5731	0.7259	-0.656013290701287	-0.563882001735358	0.350915279197995	0.000361057
2	71816977	rs116071054	0.6119693	0.6892	0.7557	-0.507264380003809	-0.400014479805825	0.312350117948718	0.00135663
2	71817003	rs1473228	0.8436927	0.8225	0.9656	0.197172297430919	0.224798231836735	-0.040010003336	0.0050799
2	71818376	rs66954904	0.4146118	0.501	0.6394	-0.815804804947161	-0.672333267961165	0.468289884195402	0.000402407
2	71818775	rs115616020	0.8499709	0.5267	0.6491	0.189155538861834	0.632759343233743	0.454325076763485	0.000171391
2	71818820	rs9973420	0.6768778	0.9576	0.5593	0.416727361320078	0.0519272838051948	-0.584522913461539	0.00280839
2	71818882	rs78963369	0.5488759	0.6563	0.6872	-0.599445398503855	-0.445785689341085	0.401380442691415	0.00135663
2	71819017	rs12474121	0.9446947	0.8577	0.9167	0.0693703830521157	0.181545998787879	0.107832814676259	0.000874761
2	71819471	rs11126337	0.7004566	0.7947	0.3628	0.384704102373761	-0.260559300181818	-0.906405437410072	0.00193671
2	71820396	rs4852811	0.9380164	0.978	0.9312	0.0777630924084112	0.0272054436258503	-0.08804843552	0.00722671
2	71820424	rs10178480	0.9835763	0.9928	0.9668	0.0205854008466479	-0.00675709461486486	-0.0396924636269841	0.00547119
2	71820895	rs145117051	0.05560204	0.1312	0.2388	-1.91414174301224	-1.50914976993166	1.17825164721448	0.000104943
2	71821538	rs10205698	0.5872922	0.9018	0.4909	-0.542764058148651	-0.124243182965517	0.688927241018767	0.000347329
2	71821847	rs17616999	0.7826418	0.4258	0.6066	0.275878054170187	0.799017538505747	0.513583700878378	0.00129842
2	71822159	rs72827589	0.6103189	0.3374	0.7273	-0.509618276122329	-0.959196586700767	-0.350482454573171	0.000416247
2	71823397	rs72827594	0.7104495	0.349	0.5901	-0.371252414076553	-0.936099622193878	-0.53786165775076	0.000430116
2	71823716	rs11674138	0.7065845	0.3329	0.5739	0.376447075268521	0.972002645555556	0.562280314183007	0.000998224
2	71823762	rs1529406	0.8575174	0.859	0.9504	-0.179535320933592	-0.181453125771812	0.0634666802063492	0.00117309
2	71824465	rs10198119	0.6539519	0.3453	0.6724	-0.448278955610184	-0.94263771640625	-0.424255884210526	0.000457938
2	71825677	rs13421969	0.6004535	0.3047	0.6842	-0.523748332745808	-1.02617014308094	-0.40668855	0.000457938
2	71826008	rs2303600	0.7949694	0.5106	0.7063	-0.259863066932092	-0.66007152875	-0.377095606229508	0.00342893
2	71826077	rs934062	0.7551615	0.8872	0.753	0.311840800610072	0.139973474076433	-0.318091109621212	0.00152761
2	71826102	rs2303602	0.5593361	0.3112	0.7691	-0.583827781469585	-1.01361936275862	-0.292395082439024	0.00406553
2	71827385	rs17655927	0.8920168	0.9935	0.8405	0.135752699565072	0.00632879748924051	-0.203282073233083	0.00146211
2	71827555	rs13028056	0.5592383	0.1108	0.3324	-0.583973264486851	-1.58876244050633	-0.970461876119403	0.0080485
2	71828755	rs75726258	0.5563358	0.1797	0.4814	0.588292637044995	1.34325367764977	0.703905056424581	0.000171391
2	71829517	rs79134431	0.8839123	0.7096	0.5047	-0.14601147711262	0.372559919272727	0.666815415053764	0.000172604
2	71829821	rs1529408	0.8681656	0.7381	0.8931	0.165989020233113	0.335230230681818	0.135813808642384	0.000642093
2	71830538	rs72829407	0.5457506	0.3078	0.7848	-0.604139832501047	-1.02091248372703	-0.274099512647975	0.000471892
2	71830569	rs114901317	0.576101	0.3057	0.6965	0.559088915176884	1.02440272922222	0.389626095251397	0.000184761
2	71830689	rs1529409	0.6066678	0.3325	0.7303	0.514835627999073	0.969697588301887	0.346644650311111	1.80765e-05
2	71831021	rs72829411	0.5058363	0.2355	0.7067	-0.66533493485619	-1.18588374947644	-0.377038818380062	0.000471892
2	71831570	rs116517677	0.896874	0.9771	0.8686	0.129611190779197	0.0288288599759615	-0.165656046797753	0.000527998
2	71832504	rs11899995	0.7310459	0.3937	0.6345	0.343734552198521	0.853397951879699	0.473562970353982	1.42355e-05
2	71833015	rs7586988	0.8240538	0.6867	0.8963	0.222334213303941	0.404019559888579	0.130357699641694	0.000803216
2	71833325	rs4852264	0.9806729	0.8252	0.7674	0.0242252051277809	-0.221272421329114	-0.298356812462687	0.00159435
2	71833536	rs4852814	0.6061657	0.4162	0.8743	0.515554288213658	0.814674396457766	0.159155786942675	0.000803216
2	71833666	rs4852265	0.2332313	0.2373	0.6521	1.19207645052386	1.17884931324503	-0.452872566171875	0.00291533
2	71833779	rs62145897	0.8101869	0.9127	0.8075	-0.240184927116521	-0.108566375075758	0.244626271510574	0.000598786
2	71834123	rs11884233	0.5860921	0.5518	0.89	0.544507696952087	0.593351652466667	-0.141859995826772	0.000449759
2	71834241	rs141256503	0.505226	0.7924	0.4712	-0.666289503951347	-0.26297086015748	0.719806061410018	0.000184761
2	71834414	rs7600680	0.4410316	0.8252	0.3529	-0.770452309793183	-0.220351648068965	0.934812972131147	0.000108051
2	71834676	rs12472134	0.5039202	0.7125	0.5532	-0.668334249208235	-0.372729548896552	0.593761472357724	0.00241524
2	71834895	rs60027898	0.7335996	0.5762	0.8946	0.340341221885755	0.557185037151703	0.131996321978022	0.000527998
2	71835019	rs74736234	0.8694873	0.7276	0.4948	-0.164309761382922	0.348346227311828	0.681370880417755	0.000118179
2	71835646	rs72902671	0.9803927	0.846	0.7939	0.0245765608268443	-0.194331962685185	-0.262676742091153	0.000402407
2	71835788	rs4290680	0.9467976	0.8163	0.8641	0.066728746541611	0.232386737064516	0.172408445402299	0.000556225
2	71835856	rs1529405	0.978182	0.8562	0.863	0.0273481019684226	0.181367855016181	0.173071554807692	0.000556225
2	71836177	rs7607821	0.8249381	0.8099	0.9535	-0.221198253280326	-0.240833976524823	0.0583129261916667	0.00117078
2	71836525	rs13030767	0.9532085	0.9899	0.9146	-0.058678019359583	0.0139846155734266	0.10736824231405	0.00195361
2	71836766	rs11893178	0.9211317	0.7493	0.8191	0.0990082571685317	0.320415038090615	0.227020986653846	0.000556225
2	71836773	rs34464653	0.7609823	0.5779	0.8514	0.304191169829954	0.557198968789809	0.188584592830189	0.000527998
2	71836892	rs6718994	0.9957498	0.8832	0.8534	-0.0053269127745755	0.146699166573427	0.181618474628099	0.00193214
2	71836952	rs11893222	0.9034738	0.7189	0.812	0.121274200080241	0.359164617152104	0.238489832384615	0.000556225
2	71837137	rs11888860	0.9369335	0.7337	0.7788	0.0791245150148104	0.338859117741936	0.280894850384615	0.000556225
2	71837258	rs11899440	0.8976483	0.7156	0.8157	0.128632685982571	0.36556504012945	0.234667263769231	0.000556225
2	71837343	rs13408287	0.9093141	0.721	0.8063	0.113903697177399	0.355963930744337	0.246133830038462	0.000556225
2	71837354	rs12713759	0.9873229	0.7665	0.7027	-0.0158890654676693	0.300750947692308	0.377000532377049	0.00210809
2	71837413	rs13395087	0.9151503	0.7281	0.8035	0.106544491571425	0.349561608090615	0.249955259230769	0.000556225
2	71837849	rs11889141	0.9053952	0.7264	0.8182	0.118848703560587	0.349561608090615	0.230844315230769	0.000542097
2	71837912	rs17430004	0.833586	0.9455	0.8064	0.210104733610997	0.0687660096383363	-0.244213877087794	0.000499887
2	71838296	rs67190543	0.9829918	0.9438	0.909	0.0213181762444128	-0.0706943298823529	-0.115035688958904	0.000388595
2	71838443	rs11558179	0.7510234	0.6174	0.9218	0.317290231576389	0.498368599678457	0.0991078567557252	0.000556225
2	71838463	rs61742872	0.8879782	0.9412	0.7636	0.140863003516591	-0.0734505493563218	-0.299831463395225	0.000388595
2	71838597	rs2303606	0.8883568	0.9434	0.8943	-0.140383667001142	-0.0709574704964539	0.133226780333333	0.00123543
2	71838657	rs2303607	0.9390835	0.7102	0.5658	-0.0764217686920437	0.372032195268817	0.573258342931937	0.000118179
2	71838852	rs2016605	0.7847619	0.5365	0.7573	0.27311888601883	0.617853047770701	0.310466599393939	0.000527998
2	71838875	rs1814333	0.8661335	0.9651	0.8363	0.16857173426618	0.0448746402600473	-0.206557580633609	0.000416247
2	71839386	rs142627571	0.6514349	0.6915	0.8167	-0.451769587000396	-0.396349331907895	0.231047109902913	0.000225033
2	71839751	rs111935215	0.8201787	0.5081	0.6508	0.227315151902197	0.662380746121593	0.45254843059126	0.000118179
2	71840218	rs58806374	0.9351014	0.6919	0.5479	-0.0814281743558141	0.395313161461794	0.599027287698413	0.000670314
2	71841175	rs13409105	0.7452676	0.8957	0.7278	-0.324885690940868	-0.130273219348958	0.347704825	0.000542097
2	71842536	rs1863810	0.5861173	0.7755	0.6133	0.544471114555155	0.286715903466667	-0.503971589055118	0.00190422
2	71842826	rs11896727	0.617534	0.7093	0.7435	0.499348217817776	0.37447759414966	-0.330515074677419	0.00113365
2	71842936	rs112894243	0.9638321	0.5666	0.4336	-0.0453451235233382	0.572427986749117	0.782791125438596	7.85498e-05
2	71843622	rs6546705	0.1946218	0.2426	0.5291	1.29702745373243	1.16661729851852	-0.630638530434783	7.91956e-05
2	71843804	rs11898306	0.6606916	0.7359	0.7766	0.438958511939933	0.335402128187919	-0.283185788503937	0.00170363
2	71845911	rs77367656	0.9700469	0.977	0.9268	0.0375494069118912	-0.0281746493873239	-0.0909591276033058	9.43159e-05
2	71846146	rs12987340	0.3718919	0.8538	0.2418	0.892935230554275	0.184774606746575	-1.16658020121951	0.000987959
2	71847120	rs6546706	0.9700147	0.8882	0.9112	0.0375898042493728	0.140704412887324	0.108262977666667	4.87559e-05
2	71847943	rs12995778	0.5449284	0.6868	0.6415	0.605377068119423	0.400054672263158	-0.465238530188679	0.000445517
2	71848076	rs13001268	0.9271391	0.9526	0.9376	0.0914447428693501	0.056315504971831	-0.0750337702666667	8.5682e-05
2	71848143	rs11886623	0.5216086	0.5465	0.7796	0.640867727795697	0.600955866666667	-0.281498955628742	0.000260113
2	71848196	rs11897566	0.5277662	0.6693	0.6395	0.631419615662031	0.428419554867725	-0.471574853899371	0.000456729
2	71848412	rs11897583	0.5357954	0.6678	0.6512	0.61918360234542	0.428419554867725	-0.452567797610063	0.000456729
2	71848442	rs11897670	0.5276275	0.659	0.6501	0.631631796660775	0.444686896507936	-0.452567797610063	0.000456729
2	71848445	rs11897671	0.5276275	0.6583	0.6495	0.631631796660775	0.444686896507936	-0.452567797610063	0.000456729
2	71848696	rs6546708	0.5278487	0.6617	0.6451	0.631293393845782	0.438915186455026	-0.458902844842767	0.000456729
2	71848952	rs6546709	0.5251857	0.6608	0.6415	0.635372064681398	0.438915186455026	-0.465238530188679	0.000456729
2	71849011	rs6546710	0.5251443	0.6648	0.6385	0.635435580471051	0.433667630899471	-0.471574853899371	0.000456729
2	71849040	rs7580894	0.9444159	0.9927	0.9223	0.0697206652246288	0.00704190143169014	-0.0992331055371901	9.43159e-05
2	71849219	rs56336010	0.9836897	0.561	0.4701	0.0204432523593833	-0.58207824589372	-0.72220612722063	0.000430116
2	71849250	rs4852815	0.526224	0.6637	0.6371	0.633780615315972	0.433667630899471	-0.4686275110625	0.000490892
2	71849293	rs4852817	0.5183286	0.6625	0.6279	0.645923869797225	0.438915186455026	-0.481222857875	0.000456729
2	71850194	rs17583530	0.9786046	0.9786	0.9415	0.0268183205532226	-0.0281746493873239	-0.0744136564628099	9.43159e-05
2	71850541	rs13016200	0.5037815	0.6525	0.6097	0.668551678529788	0.447565289	-0.5064211689375	0.000445517
2	71850552	rs188199306	0.07114084	0.08321	0.4748	-1.8045773313614	-1.73146672241183	0.713933479562044	0.000238512
2	71850599	rs13016729	0.4999182	0.6516	0.611	0.674618395520216	0.455179301957672	-0.5064211689375	0.000456729
2	71850735	rs12713760	0.4998753	0.6537	0.6091	0.674685847960653	0.449933359312169	-0.5127223344375	0.00046803
2	71851855	rs934072	0.8338324	0.6215	0.799	0.209788960138897	0.492639050140845	0.25793374225	3.15732e-05
2	71852034	rs2419414	0.9550211	0.6214	0.4881	-0.0564024951481867	0.492661022453222	0.693795703826531	0.000118179
2	71852668	rs227774	0.6465266	0.5469	0.9975	0.458592788892372	0.601495981203008	-0.00292412281578947	0.000347329
2	71853240	rs2195192	0.943498	0.6329	0.4847	-0.0708739316035887	0.478240785031185	0.699008580357143	0.000118179
2	71853405	rs75713612	0.9726593	0.9125	0.8541	-0.0342731003139701	0.111205252972973	0.184927932633452	0.000830337
2	71853423	rs227773	0.7795467	0.5953	0.8397	0.279909814851309	0.535284420633803	0.199760383333333	3.15732e-05
2	71854893	rs79228880	0.9474215	0.6329	0.4895	-0.0659451029785244	0.478240785031185	0.689553940966921	0.000118179
2	71856229	rs227772	0.7470547	0.7111	0.9546	0.32252536706515	0.372954342183099	-0.0583537595333333	5.87439e-05
2	71856468	rs1736171	0.7183657	0.6927	0.9277	0.3606438276335	0.394666670422535	-0.0917171203333333	5.53109e-05
2	71856682	rs227771	0.6707606	0.737	0.7984	0.42510438293685	0.337920345915493	-0.258734579416667	9.43159e-05
2	71856762	rs12612922	0.8820742	0.9981	0.8192	0.148340274221595	0	-0.228678200551181	2.94377e-05
2	71857353	rs2559085	0.8659532	0.9881	0.8056	0.16880103670269	0.0134214766912752	-0.244473618346457	2.94377e-05
2	71858146	rs116660130	0.7739886	0.9291	0.5849	-0.287161617892883	0.0895607833333333	0.545951981589958	0.000238512
2	71858565	rs227769	0.7153086	0.768	0.8319	0.364735891827585	0.295856531338028	-0.215155857024793	9.43159e-05
2	71860893	rs847622	0.8141618	0.6759	0.8965	0.235060561462605	0.419716936783217	0.132125732561983	3.68874e-05
2	71861035	rs55964785	0.9315411	0.3681	0.3488	-0.0859059452356184	-0.900348509476309	-0.93780987032641	0.000444013
2	71861587	rs17718067	0.7984042	0.9771	0.715	0.255412908348472	0.026840269885906	-0.362249322519685	2.44672e-05
2	71861835	rs17656117	0.85818	0.8849	0.9162	0.178691415549547	0.147488828389262	-0.102428797874016	1.78918e-05
2	71862336	rs12614839	0.6240006	0.7676	0.6857	0.490188255240104	0.298004001655629	-0.40652459625	3.48821e-05
2	71862939	rs117885470	0.8609739	0.754	0.5095	-0.175134628488446	0.313116433333333	0.659267946419753	0.000118179
2	71864106	rs72829445	0.9350201	0.4018	0.2607	0.0815304138897774	-0.8372084329718	-1.12409993927649	0.000361057
2	71864377	rs227768	0.3144151	0.3513	0.6499	1.00600101905018	0.931650852991453	-0.457351326080402	1.22817e-05
2	71865287	rs13387541	0.8352166	0.6543	0.388	-0.208015886541999	0.447655225641026	0.865189582865169	0.000457938
2	71865568	rs4852818	0.7299566	0.965	0.5582	-0.345183313483168	0.0432259551675676	0.582124832531646	0.0011094
2	71866842	rs227782	0.5153178	0.9161	0.3778	0.650579728579086	0.103813075584416	-0.878559534090909	0.00164533
2	71867636	rs72829449	0.5494821	0.7107	0.6263	-0.598536365912794	-0.370138738754325	0.487763747983871	0.00105464
2	71868159	rs72829451	0.5311378	0.4649	0.9172	-0.626270095094008	-0.732920164655173	0.105949398080808	0.000126524
2	71868561	rs145401553	0.2952039	0.3879	0.5489	-1.04677388277675	-0.862983672081218	0.600561156456456	0.000865172
2	71869646	rs75786011	0.7567484	0.6973	0.3451	0.309753497197293	-0.388087830514096	-0.942892503944773	0.000171391
2	71871039	rs84181	0.9971311	0.6348	0.5837	-0.00359559913672218	-0.472001971028037	-0.549441322967033	0.000158688
2	71871236	rs84182	0.9547666	0.5895	0.5845	-0.0567219581118282	-0.541915226635514	-0.54643891136612	0.000168915
2	71871497	rs227780	0.9633795	0.6188	0.6114	-0.0459129770912234	-0.495137346261682	-0.508368323825137	0.000168915
2	71872154	rs227779	0.8980563	0.6276	0.7101	-0.128117110907164	-0.4856174125	-0.372979866384181	0.000121658
2	71872233	rs227778	0.7560482	0.9772	0.6596	0.310674380690273	0.0304801854695122	-0.442798231642857	3.3473e-06
2	71872256	rs2142488	0.5897266	0.5072	0.9579	-0.539232183534073	-0.662371754273504	0.05496977215	0.00146106
2	71875036	rs227777	0.9060706	0.7729	0.6021	0.117996277530045	-0.291041091220657	-0.522254396373626	0.000158688
2	71876316	rs227776	0.847357	0.8039	0.5578	0.192491862990801	-0.249016037183099	-0.587747777472527	0.000158688
2	71876488	rs227775	0.7358907	0.9933	0.5935	0.337300064912462	-0.00995124391542289	-0.53223926251462	0.000968883
2	71877781	rs72829459	0.3958084	0.4251	0.7062	-0.849130926571133	-0.797108655350554	0.376117775769231	0.00119273
2	71878017	rs847623	0.8109088	0.8275	0.5343	0.239253843965951	-0.215989032676056	-0.62107945989011	0.000148857
2	71879435	rs113401856	0.3246896	0.1884	0.9895	-0.984866535869765	-1.31404289913169	-0.0133832804481605	0.000184761
2	71880211	rs1736168	0.7433362	0.8717	0.753	0.32743860876155	0.163194784248366	-0.312853963816794	0.000502729
2	71881226	rs2472688	0.8953576	0.9495	0.7816	0.131528024926829	-0.0641346367948718	-0.27795675518797	0.000832334
2	71881650	rs3116669	0.8983841	0.8006	0.6237	0.127702813103775	-0.252550395280374	-0.491824163770492	0.000168915
2	71882533	rs227784	0.8690007	0.8761	0.6656	0.164927986169864	-0.153610523894231	-0.435003713333333	0.000130351
2	71885212	rs11892563	0.7307844	0.6696	0.9769	-0.34408225739487	-0.425993151304348	0.0306030648979592	0.000126524
2	71886100	rs62145939	0.2106585	0.4561	0.2915	1.25175673465233	0.745027164298725	-1.05556304059829	0.000319959
2	71886580	rs227786	0.909978	0.7188	0.5547	0.113066252919641	-0.358119336093023	-0.592346786413044	0.000179549
2	71887060	rs982415	0.8228411	0.7981	0.5208	0.223892330086492	-0.256778985140187	-0.644772634972678	0.000148857
2	71887586	rs114239741	0.1378857	0.8936	0.01441	1.48371080964864	-0.133092136280401	-2.44537601512605	0.000238512
2	71887978	rs75750524	0.3310406	0.1769	0.9474	-0.972019977429961	-1.3487695443314	-0.0665221511980033	0.000184761
2	71889101	rs3791825	0.6993893	0.8028	0.3752	0.38614496555628	-0.248972001531101	-0.887878176404495	0.000121658
2	71890199	rs55689153	0.5832065	0.3496	0.8008	-0.548706936824337	-0.93664345	-0.251537708814815	0.000120061
2	71891042	rs114488020	0.730536	0.5563	0.2247	-0.344412694476208	0.588937903968254	1.21448183585952	0.00311428
2	71891236	rs2303598	0.9219547	0.6746	0.737	-0.0979717724302138	-0.419424925290323	-0.338354159774436	0.000633454
2	71891361	rs2303599	0.7440383	0.7923	0.4206	0.326510377700116	-0.261670013428571	-0.810317664804469	0.00126369
2	71894826	rs148625860	0.2655185	0.7633	0.02212	-1.11344233495961	0.301703591634981	2.28749906540448	0.000225033
2	71895157	rs11674060	0.7579224	0.7235	0.9528	-0.308210181276422	-0.354327532291667	0.0605757777636364	3.7359e-06
2	71895241	rs141270739	0.8203472	0.4978	0.661	-0.227098529872023	-0.678283372166667	-0.438139149227799	0.000184761
2	71897075	rs3791829	0.8716166	0.5989	0.7118	-0.161605458617328	-0.52527628559322	-0.3698646315	0.000395355
2	71897951	rs3791830	0.7089057	0.9829	0.5464	0.373326204643054	-0.0227329564409091	-0.601257775	0.00188762
2	71898006	rs140663093	0.06443035	0.2103	0.1665	-1.84919017558158	-1.25291246395806	1.38466509466248	0.0353219
2	71899105	rs3791832	0.5808998	0.901	0.3213	0.552070789110565	-0.12345440977169	-0.994756598930481	0.0017536
2	71899180	rs3791833	0.7150471	0.1662	0.2887	-0.365086115100656	-1.38797063551913	-1.05713190509554	0.0028529
2	71900414	rs72829766	0.4788062	0.851	0.1849	0.708223962381765	-0.18861564718543	-1.32799009604743	0.0103136
2	71900685	rs7604764	0.3573475	0.2854	0.8721	0.920431115447906	1.06891472068966	-0.162764444796748	0.000296092
2	71900805	rs13024390	0.382743	0.2981	0.9023	0.87285340501863	1.0410681137931	-0.122042774471545	0.000296092
2	71900961	rs882973	0.4134487	0.8488	0.1347	0.817839665937787	-0.191999296995074	-1.4973701005848	0.000942675
2	71901142	rs2559080	0.6449362	0.1182	0.2637	-0.460808243029935	-1.56456689631902	-1.11436187357143	0.0019547
2	71901286	rs2559081	0.3964855	0.8505	0.1236	0.847914738733865	-0.187054199408867	-1.53818177894737	0.000942675
2	71901883	rs2589512	0.7326447	0.206	0.3419	-0.341609647156315	-1.26698110152672	-0.950991027111111	0.000964059
2	71903036	rs9677779	0.4634162	0.07355	0.3369	-0.733233186741327	-1.78727512068966	-0.959851322818792	0.00347464
2	71904644	rs115803108	0.2619082	0.2223	0.7775	-1.12189232729914	-1.21936413269514	0.283233855555556	0.00342755
2	71905414	rs72904672	0.9477289	0.7308	0.765	0.0655588977454381	0.342908534870317	0.298666939161074	0.000713591
2	71905762	rs13022201	0.9547949	0.2672	0.1651	0.0566864476198007	-1.11175403043478	-1.38415023913043	0.00226995
2	71905842	rs1863811	0.9496527	0.6876	0.5693	0.063142818184633	-0.401843264847162	-0.569302208717949	0.000359712
2	71906171	rs1863812	0.9841987	0.685	0.6115	0.0198051878724487	-0.406250669257642	-0.507632419435897	0.000359712
2	71906278	rs17718530	0.928812	0.2801	0.1624	0.0893395788240929	-1.08077730931677	-1.39818523043478	0.0022509
2	71906691	rs3981402	0.9233863	0.6078	0.647	-0.0961689295184599	-0.513014748695652	-0.456383753179487	
2	71906725	rs4436990	0.8454807	0.5608	0.7041	0.19488796108618	0.579626368551724	0.382027858211382	0.000361283
2	71907149	rs10187598	0.9865894	0.6211	0.5797	-0.0168084101401264	-0.493609003056769	-0.55374821025641	0.000359712
2	71907425	rs10198903	0.4949046	0.2187	0.6951	0.682528866269601	1.23052531513158	0.395115368837209	0.00161122
2	71907930	rs7558412	0.7912069	0.5089	0.2353	0.264743738564025	-0.65831047755102	-1.18691760722892	0.000503527
2	71909363	rs11897186	0.1105884	0.3848	0.1461	-1.59555422343659	-0.869594066880342	1.45328340284974	0.00125731
2	71909822	rs2559082	0.7398963	0.1967	0.3184	-0.331990739132008	-1.28739318023952	-0.993031426573426	0.00200903
2	71911526	rs6722297	1	0.9094	0.8986	0	0.110256645793103	0.129977346666667	0.000470584
2	71912637	rs1863809	0.3120802	0.9306	0.09499	1.01086678318553	-0.0870348766666667	-1.66870090342857	4.83296e-05
2	71914320	rs74344903	0.5008792	0.889	0.2285	0.673106918083284	-0.140014985984456	-1.20426683353659	0.000527998
2	71914438	rs1961080	0.9622103	0.676	0.5726	-0.0473799661879427	0.416802235833333	0.565259564590164	0.000178529
2	71914823	rs190127934	0.2122464	0.4976	0.2391	-1.24741212732186	-0.677611090668081	1.17751550539773	0.000184761
2	71915735	rs2559083	0.4823811	0.9288	0.2379	0.702477945525655	-0.0881120072955975	-1.18374224926471	0.0011093
2	71916661	rs11126341	0.506306	0.7928	0.4731	-0.664600497225084	-0.260339777746479	0.719175809421488	9.72491e-06
2	71917601	rs2162624	0.5829394	0.6359	0.1612	0.549096106877306	-0.473802287857143	-1.4044438129771	0.0014947
2	71917617	rs2162625	0.3601245	0.9399	0.1331	0.915127889342138	-0.0779688686363636	-1.50403299847328	0.000403603
2	71918796	rs114755356	0.1495294	0.9823	0.0309	1.44119560425882	-0.0228428155064194	-2.15881032398754	0.000171391
2	71919512	rs12713761	0.5229099	0.5706	0.09834	0.638866234462646	-0.56803770154321	-1.65202236811594	0.00242457
2	71920075	rs2900975	0.7546859	0.6951	0.3475	0.31246664931827	-0.390553328874172	-0.938212873643411	0.00176661
2	71920555	rs2114809	0.7337323	0.6935	0.3228	0.340164993790475	-0.394602092368421	-0.984737833846154	0.00167951
2	71920647	rs2114810	0.7703774	0.7328	0.3955	0.291881374005769	-0.344603631258278	-0.852735027906977	0.00178426
2	71921493	rs78960995	0.8861548	0.5761	0.3793	0.143171386208522	-0.559377150515464	-0.878677589090909	0.000485875
2	71922401	rs6745306	0.2957619	0.8577	0.06733	1.04556511544297	-0.182091455757576	-1.82250831134752	0.00219415
2	71923101	rs10176088	0.7128473	0.5962	0.9535	-0.368034713493736	-0.531414582608696	-0.0568466098863636	0.000796519
2	71923122	rs144016609	0.3470638	0.148	0.8132	-0.940299758042521	-1.44503874010989	-0.235582567834395	0.000613032
2	71923134	rs115776595	0.06357459	0.3216	0.08596	-1.85515152977178	-0.989818204251701	1.71548025958763	0.000198158
2	71923417	rs72829793	0.1888659	0.3066	0.409	-1.31394147255168	-1.0219768743025	0.825965073712256	0.0712146
2	71923487	rs79623654	0.08771699	0.3812	0.105	-1.70756549425526	-0.87540078047138	1.62110904826884	0.000198158
2	71924360	rs145975625	0.09453306	0.4485	0.08782	-1.67195566773324	-0.757537779765886	1.7056142796371	0.000184761
2	71924662	rs10173321	0.9611686	0.8667	0.9027	0.0486870868978233	0.168324314727273	0.122853425080214	0.00129674
2	71924731	rs116081174	0.08262723	0.4536	0.06985	-1.73564157935056	-0.750395995142379	1.81422505575758	0.000184761
2	71925491	rs34369500	0.3729259	0.8412	0.1075	0.891006096425875	-0.201798669282511	-1.61071304210526	0.00164012
2	71926186	rs146507155	0.1444593	0.5602	0.1191	-1.45938470964472	-0.582066536691542	1.55824743021583	5.2262e-05
2	71926299	rs80292841	0.6943207	0.5969	0.9869	0.392998345357051	0.529641182432432	0.0158690489428571	0.000670314
2	71927781	rs13428172	0.2299013	0.8688	0.03337	-1.20061330403958	0.16449012943038	2.1264428972332	0.000279111
2	71928202	rs114797327	0.1925352	0.9613	0.03536	1.30311602023776	-0.0483395095967742	-2.10586899185668	0.00237969
2	71928741	rs115634199	0.3179404	0.7145	0.267	0.998699230580367	0.366905978546713	-1.10972589186992	0.000684709
2	71928822	rs4852821	0.8002856	0.967	0.73	-0.252977481840372	-0.0390400083317073	0.34493978137931	0.000796519
2	71929118	rs934066	0.8412592	0.5915	0.3469	0.200283085866396	-0.53412892565445	-0.944410716770186	0.000369132
2	71929730	rs934067	0.9568362	0.7481	0.7679	-0.0541241137887576	-0.319786911116751	-0.29353264491018	0.000572577
2	71929775	rs750355	0.8470384	0.5646	0.3284	0.192898596601995	-0.578962203157895	-0.981629288198758	0.000369132
2	71930058	rs934068	0.7704237	0.6467	0.9285	-0.291820823756114	-0.457821431094527	-0.0877851535672515	0.000773913
2	71930138	rs750356	0.1708032	0.8801	0.03897	-1.36962762605712	-0.150715282266667	2.06306152889667	0.000158048
2	71930530	rs111395363	0.4835494	0.1309	0.4744	-0.700605189865098	-1.50970173961219	-0.714683418076285	0.000225033
2	71930664	rs751474	0.7675236	0.6473	0.9366	-0.295615673319178	-0.457821431094527	-0.0819287085380117	0.000773913
2	71930698	rs751473	0.2538864	0.8868	0.03668	-1.1409604238342	0.142477790932642	2.09157109499136	0.000158048
2	71930941	rs10170252	0.7879377	0.6565	0.9126	-0.268989639025189	-0.44778020880597	-0.111216800584795	0.000751782
2	71931494	rs62147861	0.0637577	0.1587	0.2294	1.85387042562948	1.41287840137615	-1.20025459405405	0.000142437
2	71932031	rs2114811	0.7616878	0.6402	0.9357	-0.303265202104872	-0.467864680348259	-0.0819287085380117	0.000751782
2	71932953	rs6736164	0.6643175	0.4866	0.8797	-0.433959932476572	-0.693711054271357	-0.148995846309524	0.000688153
2	71933735	rs6739914	0.7093166	0.5167	0.8566	-0.372774068139711	-0.64525449139785	-0.183810958670886	0.00141997
2	71936759	rs139727960	0.01653375	0.05785	0.1415	-2.39691521812024	-1.89705391313131	1.4689759	0.000252017
2	71937024	rs4852267	0.4276707	0.3121	0.9733	-0.793183926906883	-1.01035297216495	0.0363527316363636	0.00216277
2	71937590	rs4852268	0.3812768	0.2995	0.893	-0.87554618979751	-1.03611709845361	0.133186881393939	0.00216277
2	71938120	rs66824662	0.3279725	0.9442	0.1111	0.978206001551952	-0.0681071064397906	-1.59259107962963	0.000817002
2	71938188	rs1896496	0.4882015	0.33	0.9401	-0.69317211477681	-0.974157874479167	-0.0732146693292683	0.0018629
2	71938394	rs1896497	0.9302999	0.9134	0.9956	0.0874674819407135	0.108992844909091	-0.00709255321276596	0.000158624
2	71938990	rs62147871	0.1346373	0.6201	0.0829	-1.49606290014099	-0.496919105379747	1.73864690075758	
2	71939969	rs114377543	0.8535116	0.8069	0.9929	0.18463983937451	0.24425050504886	0.00803052251606426	0.000171391
2	71941150	rs7598653	0.7679971	0.983	0.6688	0.294995758598655	0.0211235921830986	-0.430042548099174	0.00463953
2	71941905	rs1559980	0.2251653	0.5639	0.231	-1.21290728464479	-0.577172311671924	1.1990930443609	0.000742593
2	71942638	rs80195178	0.1793786	0.4803	0.2133	-1.34267086906414	-0.704832544409938	1.24628253713235	0.000699135
2	71943026	rs10192575	0.02688792	0.3905	0.0161	-2.2131409939465	-0.857812744160584	2.40758537982833	0.00100921
2	71943247	rs2589513	0.8596568	0.9443	0.7202	-0.176811085383933	0.0728076452317881	0.359328632421875	0.00583105
2	71944847	rs57121650	0.1293567	0.6475	0.07033	1.5166434485213	0.45766455915493	-1.80130680743802	0.00268945
2	71945432	rs934069	0.03017495	0.4611	0.01279	-2.1677862482656	-0.734318978125	2.48458541595092	0.0293611
2	71946135	rs2004421	0.04297805	0.5204	0.0176	-2.02392319240957	-0.640911427179487	2.37584740606061	0.0321906
2	71947000	rs78756533	0.8479171	0.5403	0.6711	-0.191776810407899	-0.611805122377622	-0.423883656584362	0.000292699
2	71948791	rs10865386	0.2367828	0.8324	0.1152	1.18306657314111	0.210951336619718	-1.5832791675	0.00296609
2	71948947	rs75634192	0.4941585	0.7476	0.5006	-0.683709574189162	-0.323165236976744	0.673910975815217	0.000542097
2	71949044	rs61277409	0.4723173	0.8198	0.4008	-0.718713645357267	-0.227464486056911	0.842303059808613	0.0661865
2	71949888	rs10198353	0.8300028	0.8436	0.9176	-0.214698047493336	-0.194913634026846	0.102295726929134	0.00605108
2	71950376	rs4852822	0.2284099	0.6395	0.1896	1.20446516036822	0.467956314042553	-1.30855364416667	0.00354443
2	71950458	rs4852823	0.8819203	0.8055	0.606	-0.148535392199963	0.245031555218659	0.516968755136986	0.000513928
2	71951050	rs9789361	0.8604714	0.6624	0.8111	0.17577409884593	0.435695448717949	0.242792344621212	0.00463405
2	71951176	rs9789391	0.7534121	0.6512	0.9626	0.314143416048869	0.451320936258065	0.0454409145454545	0.00577683
2	71951208	rs147592731	0.2395873	0.4977	0.3075	-1.17601908324545	-0.678490993890675	1.01892442547529	0.000815636
2	71951942	rs74519122	0.1796593	0.3303	0.3531	1.34180477720714	0.972996654041204	-0.929035301919386	0.000279111
2	71952796	rs1365975	0.8323235	0.6008	0.7749	0.211722610988144	0.52578763551948	0.288087904015151	0.00477836
2	71953686	rs6749644	0.9127417	0.7161	0.7948	0.109580937225909	0.36629194248366	0.261861471846154	0.00494972
2	71954468	rs6760396	0.5104758	0.5259	0.7895	0.658096897576009	0.634846056756757	-0.269504688015873	0.00610689
2	71955636	rs115773931	0.18569	0.13	0.7862	-1.32343733089214	-1.51354450246914	0.271793739771102	0.336871
2	71955772	rs2217222	0.5714161	0.5731	0.8289	-0.565967154475535	-0.561107173243243	0.213996948253968	0.00616302
2	71955855	rs2195193	0.5241903	0.675	0.6249	-0.636899399069158	-0.41770948369863	0.492044262741936	0.00683301
2	71955995	rs2195194	0.2141151	0.5838	0.2013	-1.24232922126097	-0.546068491205674	1.27519333416667	0.00378341
2	71956043	rs12475748	0.6787466	0.7102	0.8423	-0.414174099856046	-0.373814304897959	0.19975041592	0.00639089
2	71956471	rs13018971	0.5801265	0.6038	0.8051	-0.553199853889819	-0.516749377583893	0.245651183095238	0.0060233
2	71956693	rs113960357	0.2512301	0.3718	0.4713	-1.14736668760669	-0.894109195505618	0.719471892748092	0.00135663
2	71957028	rs1961304	0.2498225	0.9074	0.09962	-1.1507805603087	-0.116222583482143	1.64201233368421	0.0462098
2	71957552	rs11126342	0.2347678	0.9023	0.08981	-1.18816652481315	-0.120698730982143	1.69453148526316	0.0462098
2	71958184	rs115203550	0.2943871	0.0714	0.6192	-1.04854607639009	-1.79926665605536	-0.496104424390244	0.000815636
2	71958303	rs4417739	0.6177517	0.6404	0.8242	-0.499039188604953	-0.46647137277027	0.221911690634921	0.00613492
2	71958405	rs150690598	0.1657965	0.03992	0.8258	-1.38583760064577	-2.05420841731266	-0.220043596816208	0.336871
2	71958437	rs2419759	0.6035522	0.6202	0.8336	-0.519298949954256	-0.499817069594595	0.213996948253968	0.00610689
2	71958449	rs4401226	0.4776808	0.6733	0.5498	-0.710037606225535	-0.421712601564626	0.6001432856	0.00665377
2	71958480	rs2900976	0.6107627	0.6216	0.8354	-0.508984997398763	-0.493010488716216	0.206081416428571	0.00610689
2	71958592	rs2419760	0.8330506	0.7979	0.9804	-0.21079069926682	-0.256567584324324	0.0238059530952381	0.00630481
2	71958862	rs6719862	0.4811363	0.6998	0.5235	-0.70447607830388	-0.383262079246575	0.636993773629032	0.00683301
2	71959139	rs2900977	0.292289	0.6898	0.2453	-1.05311346103263	-0.396852933120567	1.15857543083333	0.00360317
2	71959523	rs182885929	0.07678647	0.04477	0.719	-1.76964396528611	-2.00617916925466	0.358782569702602	0.262492
2	71960466	rs6727467	0.1081186	0.5044	0.08136	-1.60670735572128	-0.668154374545455	1.74240760324427	0.000158048
2	71960834	rs77970431	0.6456358	0.8366	0.6396	0.459833402329319	0.206182156247423	-0.46837090195122	0.000319959
2	71961307	rs12466122	0.449431	0.5193	0.681	-0.756363942290653	-0.642231757702703	0.412418643412698	0.00633342
2	71961663	rs61286460	0.658684	0.8946	0.5989	0.441730791912897	0.133078880923318	-0.524678291376147	0.000184761
2	71961721	rs11126343	0.407646	0.5916	0.5188	-0.828043223817149	-0.537954740206896	0.644994444435484	0.00726414
2	71962451	rs12987560	0.3900706	0.5772	0.5035	-0.859489287045645	-0.558809565724138	0.668991695483871	0.00739077
2	71962496	rs191485931	0.06445713	0.1519	0.2421	-1.84900470279691	-1.43230023064833	1.16950663952941	0.000238512
2	71963391	rs67333570	0.5415716	0.962	0.3164	0.610438063077802	-0.049616552768595	-1.00003619951456	0.00172297
2	71963800	rs112425331	0.1408981	0.09926	0.7414	-1.47245465832505	-1.64848119054653	0.330424117132867	0.000225033
2	71963875	rs1077833	0.07781862	0.08412	0.4925	-1.76348559821368	-1.72849320688935	0.684757111414392	0.000238512
2	71964764	rs115776853	0.09313452	0.1787	3.977e-05	1.67908990921572	-1.34390980657895	-4.10834397619048	0.000388595
2	71964796	rs60854572	0.3045476	0.6649	0.2841	-1.02673009372538	-0.435406858870968	1.07077290188679	0.0643116
2	71964918	rs6751566	0.2171672	0.5539	0.2267	-1.23409587438008	-0.594125099370629	1.2050330204918	0.00511801
2	71965629	rs4643567	0.4034677	0.5769	0.5308	-0.835444097318642	-0.561887489794521	0.628992309032258	0.0070771
2	71965759	rs4481011	0.8812725	0.8658	0.975	-0.14935630980545	-0.169130420135135	0.0317396842301587	0.00633342
2	71966065	rs145975519	0.8877423	0.8902	0.9542	0.141161566951453	0.136846296098191	-0.0572833521084337	0.000595526
2	71966933	rs6730964	0.2961327	0.8041	0.1805	-1.04476260571274	-0.247047952226721	1.33986886234719	0.000292699
2	71967886	rs62147875	0.4063852	0.8392	0.2956	0.830271740437685	0.20344546701005	-1.04458152551929	0.000598786
2	71967954	rs9750511	0.07600187	0.4179	0.06776	-1.77437055257938	-0.8110527994003	1.8273715945591	0.000158048
2	71968226	rs7575074	0.3174319	0.8875	0.1679	-0.999749199438061	-0.141127952409091	1.38155839193548	0.0431977
2	71968434	rs200121932	0.1781404	0.4672	0.2234	-1.34650292584314	-0.727193249086162	1.21681129262048	
2	71969584	rs6714267	0.3620994	0.7384	0.3119	-0.911372080417429	-0.334823913347107	1.01473793317073	0.0591933
2	71969854	rs12616254	0.1098704	0.6215	0.05896	-1.5987758240892	-0.495860350434783	1.88740177025641	0.051408
2	71970575	rs115105442	0.5511267	0.7246	0.6139	0.596072640667308	0.351936065805169	-0.505916863403263	0.000471892
2	71970658	rs75830243	0.3430106	0.7508	0.2757	-0.948233458831311	-0.31580339	1.09020766635071	0.061663
2	71971022	rs12328600	0.2417375	0.6724	0.1904	-1.17065510343325	-0.421564565289256	1.31078343203883	0.0599978
2	71972143	rs6725822	0.3391657	0.4008	0.6262	-0.955815026829268	-0.839446878846154	0.488634341353383	0.00453914
2	71972579	rs6726430	0.507326	0.5448	0.754	-0.663007060741798	-0.604100021168831	0.313097482519084	0.00494972
2	71972762	rs7576785	0.1013414	0.6022	0.05507	-1.63838490143524	-0.52181450173913	1.91803857179487	0.0507845
2	71973295	rs75629843	0.6293312	0.6115	0.1741	-0.482668407538098	0.508886970535714	1.35992668186667	0.000430116
2	71974813	rs11681627	0.3113768	0.8273	0.1901	-1.01233741024977	-0.215612149513889	1.31158145327869	0.00308692
2	71975453	rs11126344	0.6359351	0.842	0.6217	-0.473389776447899	-0.202929081895425	0.492267660076923	0.00527683
2	71975921	rs4123814	0.3882886	0.6877	0.3925	-0.862725183921414	-0.403235671146245	0.85638217037037	0.0498404
2	71976202	rs114752041	0.7766159	0.8784	0.5375	-0.28373191175187	0.153097597631579	0.616142797478992	0.000527998
2	71977046	rs1346394	0.3520628	0.6763	0.3472	-0.9305956673125	-0.420199386	0.943334269339623	0.0477005
2	71977197	rs1459265	0.4261212	0.7335	0.408	-0.795846590927736	-0.337946899072848	0.829652955813953	0.00537988
2	71977239	rs6724498	0.3671327	0.6022	0.4373	-0.901857314417966	-0.523779981360544	0.77622203688	0.00401199
2	71977554	rs6740021	0.3377977	0.5627	0.4251	-0.958525840146381	-0.57795843	0.79998676624	0.00401199
2	71978881	rs59211864	0.4270024	0.688	0.4523	-0.794331605690361	-0.40242399123506	0.75232249953271	0.0483968
2	71978904	rs114161369	0.7832113	0.9914	0.6834	-0.275136629360344	-0.0113982912051282	0.410133148666667	0.000556225
2	71979590	rs58818686	0.3772346	0.6459	0.4117	-0.883003162743796	-0.460557378346457	0.820305282488479	0.0521433
2	71979900	rs61690160	0.3887197	0.6709	0.4067	-0.861941463266433	-0.425121657480315	0.829358373271889	0.0521433
2	71980269	rs1427687	0.1876323	0.4404	0.2578	-1.31761593182493	-0.767547948591549	1.13309487583333	0.00366257
2	71980426	rs58364866	0.3821221	0.6707	0.3957	-0.873992892863696	-0.425121657480315	0.847911652073733	0.0521433
2	71980790	rs116252839	0.8443502	0.8396	0.9485	0.196332128190677	0.203009235362319	-0.0648633538873239	0.000430116
2	71981215	rs2081786	0.2380668	0.6448	0.2009	-1.17983256643262	-0.461660394055944	1.28093086363636	0.00288739
2	71981493	rs13425073	0.3289498	0.6938	0.2955	-0.976231446621261	-0.3919136992	1.04725037641509	0.0470205
2	71981688	rs13387923	0.332016	0.6912	0.3026	-0.970061284940123	-0.39595328716	1.03294663679245	0.0477005
2	71981845	rs13399896	0.3289655	0.6682	0.3157	-0.976199795227757	-0.427880382	1.00478789716981	0.0477005
2	71982787	rs146077968	0.9334167	0.9541	0.952	-0.0835468406052996	-0.0578903472061657	0.0608659491647856	0.000347329
2	71983048	rs75160952	0.7643118	0.5038	0.2142	0.299823555246824	-0.668851053846154	-1.24219970898438	0.00100921
2	71983351	rs17430545	0.9252238	0.8935	0.9894	-0.0938555840538021	-0.134960966339114	-0.0135480828893905	0.000306315
2	71985616	rs2052825	0.3103654	0.5685	0.3672	-1.01445566260462	-0.566625084125874	0.900857394214876	0.00285964
2	71986420	rs7570634	0.5294135	0.793	0.5032	-0.628901549188305	-0.2598390486	0.664354725859375	0.00574983
2	71986941	rs78323037	0.2740877	0.5417	0.3333	-1.09369757676491	-0.610583085496183	0.968874180357143	0.0623314
2	71987236	rs6546717	0.2879209	0.515	0.3833	-1.06269366509496	-0.650569253566433	0.876329155371901	0.0027775
2	71988230	rs72831917	0.09557037	0.08475	0.5801	-1.66671857953142	-1.72512211292962	0.553811568241966	0.000292699
2	71988382	rs11687375	0.2641247	0.4499	0.403	-1.11669523353192	-0.754525656712963	0.836615192915531	0.000361057
2	71988942	rs6728798	0.7469758	0.854	0.781	-0.322629590791542	-0.185690551854305	0.279341053488372	0.00540582
2	71989267	rs6746698	0.2834423	0.4945	0.3908	-1.07261854361378	-0.678102306223776	0.859155056198347	0.00283208
2	71989410	rs12613744	0.2018571	0.3964	0.3312	-1.27627850176797	-0.848411973705179	0.972062038785047	0.050589
2	71989443	rs149902889	0.7082433	0.9264	0.4941	-0.374216370534322	0.0933582731339713	0.684286916201117	0.000527998
2	71990605	rs13012656	0.7019312	0.7987	0.7726	-0.382714843860097	-0.258118260198676	0.287064722790698	0.00543183
2	71990836	rs73945403	0.2136194	0.4127	0.336	-1.24367450376684	-0.817489909126984	0.957973479069767	0.0498404
2	71990861	rs73945404	0.2235607	0.4371	0.3344	-1.21711453201361	-0.7758763844	0.966908659433962	0.0483968
2	71990994	rs72485380	0.2188905	0.4	0.3648	-1.22948382291522	-0.842413311417323	0.907255729166667	0.0521433
2	71991002	rs72485381	0.2590791	0.524	0.3224	-1.12857033707687	-0.638280538132296	0.99099459543379	0.0555014
2	71991030	rs13013195	0.3330293	0.5342	0.4418	-0.968030176274922	-0.622341481608392	0.76202064795082	0.00323526
2	71991192	rs35269799	0.724516	0.8193	0.7782	-0.352429763848554	-0.224884706556291	0.279341053488372	0.00548409
2	71991196	rs3925118	0.720704	0.8106	0.7827	-0.357518139012706	-0.238176126754967	0.271616614496124	0.00548409
2	71991626	rs6711543	0.4889071	0.6282	0.6192	-0.692048040652419	-0.486663988815789	0.496083688449612	0.00527683
2	71992865	rs58257059	0.1533749	0.4774	0.1723	-1.42771148504951	-0.712711523622047	1.36576611666667	0.0529504
2	71993206	rs10186221	0.5706284	0.9327	0.4383	-0.567126263758487	-0.0865106210699589	0.773009358937198	0.0463562
2	71993330	rs10175361	0.1924699	0.4089	0.2957	-1.30330730608425	-0.825128616783217	1.04090368688525	0.00348318
2	71993518	rs10210115	0.1871038	0.4073	0.2888	-1.31919535313811	-0.832204983216783	1.05708866721311	0.00361222
2	71993619	rs13033187	0.4610518	0.5823	0.627	-0.737115980900718	-0.552311893947368	0.488380817674419	0.00266423
2	71993723	rs13033431	0.2636866	0.3678	0.508	-1.11772005401133	-0.902344492857143	0.664276892671756	0.00252329
2	71993963	rs6748598	0.4857671	0.5258	0.7399	-0.697057033344957	-0.631308794276316	0.333390585426357	0.00512439
2	71994499	rs10779955	0.1633872	0.3763	0.2669	-1.39376971093987	-0.888133467132867	1.10643312704918	0.0037113
2	71994566	rs11126345	0.4855814	0.5389	0.7201	-0.697353710013852	-0.612048705657895	0.356543139147287	0.00270508
2	71995396	rs1968776	0.1749496	0.4079	0.2633	-1.35647013117292	-0.832204983216783	1.11451955	0.0038124
2	71995406	rs1968777	0.1649083	0.3999	0.2508	-1.38875153477076	-0.846359865034965	1.14766554426229	0.00367805
2	71995586	rs1903146	0.1765812	0.4046	0.2709	-1.35135677370182	-0.839282065734266	1.09834590655738	0.00377847
2	71995936	rs11126347	0.1978473	0.4386	0.2801	-1.28770904136196	-0.776321193706294	1.07407945737705	0.00354726
2	71997292	rs112670128	0.2434079	0.9428	0.05853	-1.16651094655515	0.0697047263953488	1.88988638761468	0.00462033
2	71997634	rs4852826	0.1961144	0.4489	0.2722	-1.29270122678411	-0.76218048041958	1.09834590655738	0.00361222
2	71997970	rs75098881	0.2685302	0.6236	0.2605	-1.10645376439121	-0.49214982734375	1.12866072752294	0.0546286
2	71999008	rs12623780	0.1031249	0.5106	0.08174	-1.62988920655387	-0.661044497520661	1.73793264368932	0.0463562
2	71999802	rs2419770	0.4670405	0.5388	0.6887	-0.727302745700363	-0.612048705657895	0.402827512170543	0.00509923
2	72000000	rs61573637	0.07156254	0.473	0.05288	-1.80189107230951	-0.717791061410788	1.94096288529412	0.0444523
2	72000635	rs6546719	0.161892	0.5267	0.1576	-1.39873665014887	-0.629397356433567	1.42158738181818	0.00332667
2	72001304	rs141017998	0.9964729	0.3588	0.2694	0.00442063347892067	0.917105486046512	1.10391657764084	6.53928e-05
2	72001706	rs1459267	0.158754	0.579	0.1271	-1.40927443763655	-0.552526706013986	1.52874833719008	0.00320519
2	72003083	rs13016025	0.422139	0.5893	0.5471	-0.802715846802998	-0.539707720460526	0.604612762170543	0.00517492
2	72003097	rs116327908	0.7366414	0.4626	0.7368	0.336304278849093	0.734089456476684	0.336635636873747	0.00596838
2	72003559	rs58951681	0.293834	0.6961	0.2459	-1.04974792541931	-0.390618440546875	1.16042696192661	0.0529504
2	72004535	rs145895693	0.1036328	0.2205	0.0001007	1.62749132658719	-1.22578104906716	-3.89043100429185	0.000388595
2	72004871	rs138428562	0.7023931	0.6132	0.9926	0.382091988113822	0.505612802506964	0.0100304359866221	0.000292699
2	72005343	rs6711634	0.2480589	0.6355	0.2176	-1.15507696528495	-0.472436709722222	1.22926073852459	0.00348318
2	72005585	rs6754058	0.1834494	0.5825	0.1604	-1.33020913152493	-0.552526706013986	1.40187769672131	0.00348318
2	72005731	rs115719207	0.9001922	0.8089	0.9272	0.125418515547556	0.24330497756691	0.0907892053541077	0.000457938
2	72006016	rs930932	0.2129761	0.6314	0.1759	-1.24542368035041	-0.479428910902778	1.36077299180328	0.0037113
2	72006376	rs930933	0.1750221	0.5384	0.1694	-1.35624214269683	-0.611013496944445	1.37689494098361	0.00348318
2	72006384	rs1870448	0.2014858	0.624	0.1621	-1.27732994306399	-0.486421816180556	1.40187769672131	0.00348318
2	72007464	rs11678378	0.2125798	0.6453	0.1657	-1.24650287776197	-0.458454419097222	1.38248770894309	0.00367805
2	72007751	rs12713763	0.1700267	0.5521	0.1567	-1.37211813052444	-0.597003279583333	1.41799156393443	0.00348318
2	72008967	rs7574894	0.1587408	0.559	0.1377	-1.40931924383641	-0.582995888055555	1.49207457786885	0.003296
2	72009758	rs1459268	0.2053221	0.6433	0.1592	-1.26653352242985	-0.4654452125	1.40993502622951	0.003296
2	72009917	rs13022473	0.2982834	0.6117	0.3146	-1.04012161849221	-0.509677084012739	1.00750526766917	0.00463405
2	72010747	rs6546721	0.1540064	0.6484	0.0977	-1.42552181326713	-0.458454419097222	1.66413953606557	0.00332667
2	72011314	rs11684597	0.1365943	0.5819	0.09791	-1.48859403969345	-0.551857256482759	1.65060994634146	0.00326553
2	72012027	rs111909175	0.09687704	0.1112	0.4907	-1.66018600647887	-1.59219024255952	0.689432162631579	0.00201215
2	72013503	rs114068982	0.8139033	0.7427	0.9834	-0.235393642084091	-0.329159112376238	-0.0199500032592593	0.000457938
2	72013562	rs34506036	0.4386066	0.4722	0.04105	-0.774548297039646	0.720420433333333	2.04446882151899	0.00300884
2	72013617	rs1809265	0.345207	0.7181	0.06024	-0.943926853614781	0.360556504262295	1.87798922820513	0.00314781
2	72013622	rs1809266	0.3429891	0.7134	0.05798	-0.94827581532827	0.365984778579235	1.89106077692308	0.00314781
2	72013658	rs898238	0.3409208	0.7494	0.06543	-0.952347546729436	0.317110886721311	1.84000436730769	0.00314781
2	72013662	rs114345919	0.7318102	0.5437	0.8597	-0.342718608622112	-0.606069980896226	-0.17762530989071	0.000457938
2	72013685	rs898239	0.05874019	0.5553	0.02708	-1.89013285284022	-0.591681340340136	2.21406574761905	0.00584371
2	72013838	rs74810697	0.9470899	0.863	0.9208	-0.0663615735351237	-0.173051484780488	-0.098481810056338	0.000457938
2	72014603	rs6712021	0.894047	0.517	0.5612	-0.133185074377029	-0.648147292734226	-0.581714568925234	0.000279111
2	72014622	rs6712030	0.9089632	0.5549	0.5902	-0.114346310223717	-0.590314403846154	-0.538701207728337	0.000279111
2	72014686	rs12468770	0.4833477	0.232	0.01278	-0.700928387594439	1.19825191584158	2.48842065813953	0.0022941
2	72014695	rs3849391	0.01082539	0.4386	0.002559	-2.54828513661417	-0.776744899324324	3.00794981259843	0.00699162
2	72016314	rs76949068	0.9303342	0.7753	0.8433	-0.0874243177711438	-0.284681985	-0.197978267335025	0.000388595
2	72016916	rs11684409	0.008631857	0.03381	0.1231	-2.62630049920281	-2.12916779494382	1.54993230331126	0.0280807
2	72017335	rs36026246	0.02394293	0.1009	0.1204	-2.25804368657861	-1.63893910666667	1.55901284078947	0.028583
2	72018462	rs6728086	0.02600387	0.05466	0.2416	-2.22615387636724	-1.92213938083832	1.17604079014084	0.0185336
2	72019313	rs115888859	0.5421866	0.7325	0.5896	0.609509773874692	0.340739864037855	-0.538369258608059	0.000815636
2	72019932	rs75413827	0.8108604	0.7475	0.9915	-0.23931618845728	-0.322041201424501	-0.0101025255555556	0.000613032
2	72019988	rs11126348	0.05073968	0.6432	0.01362	-1.95367483825262	-0.4654452125	2.46312148211382	0.0110548
2	72022087	rs2419777	0.05416012	0.663	0.01387	-1.92555366956938	-0.433508758251748	2.45865574098361	0.0107666
2	72022842	rs6744336	0.0561737	0.6753	0.01431	-1.90968560807259	-0.419437189090909	2.45070084836066	0.0107099
2	72022880	rs12623153	0.04004609	0.6035	0.01056	-2.05327310395301	-0.517293190909091	2.55723232295082	0.010881
2	72023218	rs12713764	0.03851288	0.5898	0.01043	-2.06935396239622	-0.53843116965035	2.55723232295082	0.010881
2	72023225	rs12713765	0.03847453	0.5785	0.0109	-2.06976310585663	-0.552526706013986	2.54134089016393	0.010881
2	72024580	rs6730998	0.5093202	0.1677	0.5269	-0.659896485799382	-1.37865421514423	-0.633226603347889	0.000252017
2	72024853	rs1459260	0.568257	0.2925	0.0341	-0.570620362796555	1.0543796576087	2.11481788726115	9.93444e-05
2	72024970	rs1459259	0.05214767	0.7097	0.01073	-1.94191263299495	-0.370911999440559	2.55723232295082	0.0112314
2	72025090	rs1459258	0.5360717	0.3647	0.04335	-0.618764090642085	0.906762203296703	2.01904245032258	0.000152934
2	72025335	rs11695965	0.05283689	0.1505	0.1967	-1.93625155319073	-1.44367231404494	1.29130195562914	0.0280807
2	72025378	rs7584251	0.6255957	0.4846	0.1147	-0.487935213432037	0.700674988622754	1.57727446760563	0.000594028
2	72025796	rs17007375	0.6366116	0.2849	0.04662	-0.472441632153071	1.07090126467391	1.99367316025641	0.000104808
2	72026348	rs73942838	0.3800666	0.8483	0.258	0.877773584776446	0.189887825046296	-1.13070268641304	0.00227614
2	72027252	rs10205629	0.2652725	0.204	0.8218	-1.11401555262293	-1.266623334	0.228015993070866	0.00694222
2	72027474	rs76585217	0.05851763	0.1979	0.1543	-1.89179998192167	-1.28837236517007	1.42477332587413	0.000171391
2	72027649	rs137902643	0.7127925	0.9268	0.6477	-0.368108215904377	-0.0911102242125237	0.456333277510917	0.000184761
2	72027858	rs10206242	0.8160866	0.2802	0.1015	-0.232581304791071	1.08060727826087	1.63966966838235	0.00101
2	72029547	rs1870446	0.3046853	0.9176	0.14	-1.02643776982386	-0.102633428639053	1.47535203788235	0.000485875
2	72030314	rs1077959	0.4080418	0.5297	0.0434	-0.82734459283618	0.629327538251748	2.02458442975207	0.00671842
2	72030471	rs6726307	0.06681245	0.07945	0.4412	-1.832933548218	-1.75005483666667	0.771248635294118	0.0290983
2	72030760	rs2419778	0.2288485	0.02586	0.4338	1.20333032360943	2.23394801843972	0.781231252521008	0.00479617
2	72031086	rs755510	0.1284982	0.01851	0.6669	1.52005069818006	2.35851776413793	0.430565175528455	0.00339205
2	72031172	rs898234	0.1155524	0.02753	0.8617	1.57371906568787	2.20826455208333	0.171950662459016	0.0036653
2	72031201	rs78467927	0.898733	0.9734	0.8761	-0.127262007645698	-0.0336135848320413	0.156050297507507	0.000457938
2	72031828	rs2125637	0.2289478	0.0373	0.5398	1.2030737914501	2.09223745531915	0.61371984117647	0.00507037
2	72032700	2:72032700_G_A	0.06135431	0.2489	0.1156	-1.87093335637254	-1.15313142971204	1.57296199331046	
2	72032935	rs898232	0.1968828	0.02768	0.5427	1.29048362213724	2.20388436478873	0.608605509166667	0.00488646
2	72033405	rs17007404	0.869533	0.9844	0.7843	-0.164251692151654	0.0184631956279683	0.273854608830769	0.000457938
2	72033515	rs6710050	0.8983231	0.9703	0.8801	-0.127779985677519	-0.0379669624932249	0.152332346412698	0.000513928
2	72033801	rs7588101	0.07112962	0.07551	0.4842	-1.80464900252433	-1.77917099668508	0.69686798	0.0296272
2	72034000	rs149212270	0.01883352	0.01349	0.4549	-2.34880978235122	-2.46948468544601	0.747301813235294	0.562011
2	72034662	rs72841431	0.8813434	0.5451	0.6321	0.149266403315836	0.601148519869281	0.476979664769231	0.00109995
2	72034704	rs17556723	0.3034709	0.4043	0.5453	1.02901861553837	0.834401140797546	-0.604568679657795	0.000184761
2	72035050	rs62143873	0.3918734	0.7806	0.3189	-0.856224858427755	-0.279579110979021	0.99151975	0.00964082
2	72035671	rs17007417	0.9597109	0.3505	0.2346	0.0505163040202972	-0.934189966981132	-1.19119144101124	0.00139702
2	72035866	rs17485056	0.1378028	0.504	0.1318	-1.48402312740143	-0.671041515594406	1.50440577272727	0.00719331
2	72035939	rs75208031	0.4028541	0.4757	0.6471	-0.836534876915445	-0.712422377823409	0.456800087412587	0.000184761
2	72037487	rs11684170	0.2020357	0.8489	0.02844	1.27577315681124	-0.188585269285714	-2.19067732442748	0.003841
2	72038036	rs115604141	0.8600625	0.5165	0.6304	-0.176294565636819	-0.648949264892086	-0.48092706921797	0.000184761
2	72038130	rs74977546	0.1428918	0.227	0.4025	-1.46510686522105	-1.21029350182927	0.838004192446043	0.000728077
2	72038203	rs11679843	0.5781551	0.0937	0.2531	-0.556081424103579	-1.67563854133333	-1.13815415478723	0.00130201
2	72038219	rs11679762	0.421375	0.04646	0.2569	-0.804038093409196	-1.99562815991189	-1.13155084789474	0.0012863
2	72038428	rs114070798	0.03685321	0.1361	0.1397	-2.08738642786244	-1.49119335119617	1.4780161568	0.000238512
2	72038937	rs10178231	0.5770186	0.07473	0.2062	-0.55774480648792	-1.77863671460177	-1.26601118031915	0.0012863
2	72039714	rs35548551	0.545849	0.08416	0.2615	-0.603991830168079	-1.72598377652174	-1.12508565416667	0.00116181
2	72039835	rs10181419	0.5371814	0.08775	0.2804	-0.61708076482835	-1.70657119111111	-1.0800400712766	0.0012863
2	72040506	rs3981391	0.5614155	0.0923	0.2665	-0.580740272176295	-1.67979242222222	-1.11256307112299	0.00131776
2	72040820	rs750009	0.1242049	0.391	0.174	-1.53736122931884	-0.859809656643357	1.36389025619835	0.00715772
2	72042095	rs898231	0.3004349	0.6982	0.03958	1.03550126287576	-0.390553328874172	-2.0621337	0.00413653
2	72044472	rs79315805	0.9407649	0.6688	0.5338	-0.0743084820501831	0.428191085185185	0.621928370410959	0.000542097
2	72044788	rs6546722	0.5222678	0.08532	0.2882	-0.639853565882973	-1.71809415638767	-1.0635276037037	0.00122378
2	72044808	rs6546723	0.5005617	0.08235	0.3042	-0.673606212782941	-1.73550345814978	-1.03168642486772	0.00122378
2	72044930	rs72841442	0.5430128	0.9856	0.3423	0.608263247586338	0.017740836908284	-0.950255403505535	0.000158048
2	72045108	rs898230	0.6257433	0.101	0.2278	-0.487726882553392	-1.64426620844444	-1.20721318776596	0.00123936
2	72046057	rs1459257	0.1062109	0.2332	0.273	-1.61546102441999	-1.19236757994543	1.09772563647469	0.000131442
2	72046479	rs1037776	0.5643037	0.0957	0.2742	-0.576460759310335	-1.66225645555556	-1.09035475957447	0.00125497
2	72046750	rs112353742	0.4609026	0.5711	0.6368	-0.737361353817233	-0.565599207159905	0.473081564305949	0.000238512
2	72047059	rs7570930	0.5550463	0.08821	0.2629	-0.590215305909418	-1.70241480711111	-1.11696503191489	0.00134936
2	72047819	rs763957	0.02972381	0.1383	0.1067	-2.17375137679498	-1.48335490916667	1.61125221176471	0.000613032
2	72047841	rs956321	0.4501924	0.06785	0.3134	-0.755094204418368	-1.82287897566372	-1.01060372393617	0.00127062
2	72048244	rs72841444	0.1228636	0.2193	0.3487	-1.54286478358146	-1.22879057174888	0.937112852879581	0.000279054
2	72049767	rs71416721	0.3455543	0.8518	0.09117	-0.943247602134082	0.186396030931677	1.68633502767528	0.000430116
2	72050664	rs1459269	0.4230185	0.08084	0.4001	-0.801195406225541	-1.74778549292035	-0.841040709523809	0.00131776
2	72051290	rs72841447	0.9519653	0.7975	0.8368	-0.060238836860162	-0.257211219602122	-0.206864538888889	0.00108172
2	72053196	rs56089430	0.2433173	0.6822	0.02238	1.166735376753	-0.410541406821192	-2.2886669578125	0.00215397
2	72053970	rs74566695	0.253712	0.2463	0.6933	1.14137963313609	1.1591046122449	-0.394173300973236	0.000347329
2	72054837	rs35668054	0.2007037	0.8238	0.08612	1.27954916764649	0.223408246382979	-1.71544324393305	0.00141297
2	72055034	rs6759774	0.7295613	0.138	0.2164	-0.345709169022365	-1.48505565622318	-1.23579689128205	0.00113103
2	72055936	rs78516991	0.09452445	0.1479	0.3799	-1.67199931104067	-1.44818585823171	0.878045577060932	0.000728077
2	72056774	rs10153553	0.778055	0.1577	0.2133	-0.281854586103395	-1.41019278888889	-1.24465085867347	0.00110038
2	72057409	rs78363466	0.07962844	0.8461	0.01434	1.75284600679549	0.194478150321543	-2.44733093530499	0.000457938
2	72058087	rs930931	0.8254548	0.1671	0.1913	-0.2205347174364	-1.38210279141631	-1.30781745692308	0.00110038
2	72058171	rs1870447	0.6751894	0.1005	0.1895	-0.419036585241329	-1.64183538951965	-1.31426421780105	0.00122378
2	72058856	rs189955791	0.3517607	0.08285	0.5198	0.931179601232189	1.73517526168224	0.643855061742424	6.53928e-05
2	72059504	rs11679946	0.1910624	0.6537	0.011	1.30744272600153	-0.446827404	-2.55112066535433	0.00423763
2	72060220	rs75862430	0.1058906	0.2223	0.2882	-1.61694269189009	-1.22006222416268	1.06113785055556	0.000485875
2	72060635	rs13386598	0.05285153	0.3048	0.07524	-1.93613199251194	-1.02788769788732	1.78328258416667	0.00687765
2	72060652	rs72841451	0.1242818	0.8662	0.01003	1.5370468353406	-0.167995316644295	-2.56657546220472	0.00421223
2	72061561	rs60729468	0.06743298	0.4788	0.04642	-1.82877724653	-0.704213526619718	1.9999741375	0.00650556
2	72062531	rs6705555	0.1109484	0.766	0.00499	1.59394478772268	-0.295279486241611	-2.81768516190476	0.00418691
2	72062897	rs41387253	0.07764806	0.4578	0.06398	-1.76449860930453	-0.739787651408451	1.85829229083333	0.00653878
2	72063472	rs6724915	0.6951563	0.1366	0.2439	-0.391867262004287	-1.48505565622318	-1.16387732974359	0.00111568
2	72063741	rs77116902	0.104348	0.3192	0.1821	-1.62413011388998	-0.9972948	1.33526724085366	0.000374812
2	72063812	rs62147664	0.0776805	0.4491	0.06602	-1.76430584916823	-0.753310531690141	1.84199157583333	0.00660559
2	72063879	rs6710254	0.7148579	0.1451	0.2417	-0.365339653831051	-1.45485422360515	-1.16912352205128	0.00116181
2	72064847	rs75463369	0.09613409	0.1915	0.3024	-1.66389159215298	-1.30626087885463	1.03313118061224	0.000347329
2	72064887	rs12467626	0.1541909	0.6906	0.007687	1.42488330532808	-0.395795655436242	-2.67472791031746	0.00431433
2	72065257	rs59451710	0.0902318	0.4793	0.07345	-1.6941762376093	-0.704213526619718	1.79143908416667	0.00653878
2	72065473	rs36093687	0.1778161	0.754	0.01391	1.34750976814116	-0.315505540872483	-2.45995505555556	0.00421223
2	72065860	rs12993387	0.3590951	0.4787	0.5596	-0.917090732907357	-0.707829720665083	0.583216381971831	0.000265551
2	72066246	rs12713766	0.6669817	0.1271	0.2496	-0.430294075240141	-1.52625024298246	-1.1518450408377	0.00125497
2	72066430	rs6729007	0.1710035	0.7685	0.0138	1.36898660820744	-0.295279486241611	-2.4568307984252	0.00416168
2	72066576	rs13414494	0.05186287	0.3479	0.05784	-1.94427021044323	-0.943122563120567	1.89169879333333	0.00687765
2	72066795	rs78968029	0.5773414	0.6117	0.1412	-0.557272224417141	0.509729432026144	1.46909058333333	0.000570383
2	72066907	rs1471219	0.05724612	0.3696	0.05998	-1.90142688258188	-0.900731104964539	1.87540461166667	0.00687765
2	72067570	rs138684770	0.938077	0.428	0.4205	-0.0776868951932343	-0.79357682005772	-0.805026240672269	0.000198158
2	72067950	rs116083797	0.2194781	0.1887	0.7261	-1.2279171822614	-1.3126574	0.349475467848101	0.000265551
2	72067961	rs13007748	0.5632719	0.1095	0.3104	-0.577988396229738	-1.60373047973568	-1.01552400947368	0.0012863
2	72068465	rs13014079	0.5680871	0.1136	0.3152	-0.570870857686434	-1.58591648634361	-1.00533017368421	0.0012863
2	72070005	rs56374521	0.09535175	0.4685	0.08567	-1.6678185319432	-0.725555845070422	1.72534846333333	0.00650556
2	72070524	rs72841458	0.9013226	0.8639	0.9935	-0.123990727027835	-0.172054816693548	-0.00931816798136646	0.00135663
2	72070633	rs113211223	0.3678186	0.5244	0.52	-0.900567041147839	-0.6354189114241	0.643206719778189	0.010054
2	72071266	rs62147667	0.5938787	0.08563	0.2219	-0.533223714370974	-1.71625836157205	-1.22521969528796	0.00127062
2	72071267	rs62147668	0.06831723	0.3871	0.07186	-1.8229086070356	-0.865864654225352	1.79959478666667	0.0068089
2	72071510	rs62147669	0.07589613	0.4204	0.07285	-1.77501064193896	-0.803154088732394	1.79959478666667	0.00650556
2	72072695	rs57300461	0.6235571	0.09748	0.2248	-0.490815159535256	-1.65768989035088	-1.21450165445026	0.00127062
2	72072937	rs13385492	0.7024663	0.1054	0.1809	-0.381993306178011	-1.61554540131004	-1.34057741989529	0.00125497
2	72073715	rs13427905	0.7796791	0.1745	0.2363	-0.279737275303619	-1.35640311716738	-1.18486531897436	0.00113103
2	72074476	rs10192419	0.0903478	0.4932	0.0693	-1.69356589686047	-0.682877674577465	1.80979080165289	0.00647245
2	72075475	rs17485355	0.04661344	0.2794	0.07308	-1.98979570434471	-1.08436212535211	1.79959478666667	0.00694691
2	72075885	rs7581051	0.7796151	0.1717	0.2316	-0.279820673938761	-1.3692510304721	-1.20008698358974	0.00113103
2	72075926	rs7581066	0.1664289	0.7615	0.01258	1.38376993986508	-0.300007355	-2.4958336015748	0.0021927
2	72076958	rs62147671	0.08048237	0.4584	0.06631	-1.74789407733714	-0.739787651408451	1.82676850495868	0.00405771
2	72077530	rs12990522	0.2815927	0.6286	0.2712	-1.07674846168817	-0.482885275106383	1.10212135969388	0.000198158
2	72077960	rs11895277	0.55196	0.1151	0.3415	-0.594825667608485	-1.57441421052632	-0.953125897905759	0.00123936
2	72078329	rs115404663	0.1416335	0.1929	0.4748	-1.46973502498477	-1.30326753784153	0.714053360611511	0.000144732
2	72079126	rs11688625	0.3491481	0.6686	0.05121	0.936243064831416	-0.425662307364865	-1.94425647619048	0.00441777
2	72079212	rs6746345	0.08653709	0.3347	0.1304	-1.71395441569586	-0.965374124475525	1.51252075785124	0.00617972
2	72079732	rs6732044	0.437854	0.1113	0.4889	-0.775822094271741	-1.59150296030534	-0.694292810045662	0.0009192
2	72079771	rs13005245	0.1951724	0.9	0.03165	1.295428556142	-0.129374645578231	-2.1518835096	0.00436588
2	72081049	rs77509305	0.07076285	0.1536	0.2671	-1.8069962790377	-1.42740351818182	1.11152443171429	0.000499887
2	72081225	rs59045478	0.1182163	0.1303	0.5243	-1.5623045224157	-1.51375089917582	0.635803888498403	0.000613032
2	72082014	rs72910709	0.04340577	0.06796	0.3319	-2.0197842565602	-1.82546038952381	0.970098783520599	0.000815636
2	72082194	rs77478419	0.03359581	0.07673	0.2304	-2.12488970863234	-1.76778922724458	1.20082918540146	0.000800965
2	72082776	rs6715499	0.06776995	0.07423	0.4707	-1.82653339946885	-1.78293533584906	0.722172575185185	0.000815636
2	72083272	rs2169027	0.744821	0.1416	0.2112	-0.325475824146531	-1.46981819393939	-1.24874783665158	0.000874627
2	72083275	rs138144627	0.4088952	0.4167	0.7498	0.825839439873273	0.811757004634831	-0.318990149169435	0.000171391
2	72083517	rs10186241	0.04648261	0.1749	0.1384	-1.99098430653963	-1.35642724545455	1.4792442553719	0.00650556
2	72083673	rs56249752	0.2405578	0.5332	0.2833	-1.17359366601104	-0.626724168098592	1.07398309834711	0.00869061
2	72083780	rs7596753	0.5438597	0.1072	0.3273	-0.606986690226532	-1.61189349333333	-0.97648718271028	0.00102432
2	72083803	rs7596953	0.5343852	0.08885	0.2885	-0.621325868430676	-1.70078028779528	-1.06119935258216	0.00102432
2	72085112	rs4490212	0.3018279	0.34	0.6387	1.03252140295157	0.954075791017964	-0.469115054285714	0.000471892
2	72085616	rs12469485	0.1210029	0.8756	0.02721	1.55057792065281	0.157353359520548	-2.2003850496	0.00468242
2	72085791	rs10206237	0.8458977	0.1846	0.2027	-0.194355314108343	-1.32546335833333	-1.27364507075472	0.00106985
2	72086013	rs56173451	0.06877275	0.2993	0.1124	-1.81990972144971	-1.04237452198582	1.58319853416667	0.00500857
2	72086622	rs77392176	0.06471607	0.1363	0.2697	-1.84721440905061	-1.48762986576355	1.10313178080229	0.000513928
2	72086971	rs12165184	0.05658342	0.2175	0.1359	-1.9065149513852	-1.23407905531915	1.49157129083333	0.00513268
2	72087537	rs55804538	0.03518008	0.1789	0.09413	-2.10627949852869	-1.34747163191489	1.66655720916667	0.0053227
2	72088761	rs11687017	0.04336475	0.6735	0.008472	2.02017970048415	0.417900606712329	-2.62867002983871	0.00261942
2	72089937	rs10208677	0.0208	0.1125	0.08793	-2.31159517255212	-1.58858120141844	1.70004064666667	0.00687765
2	72090334	rs10211376	0.01772659	0.09562	0.08806	-2.37128010658548	-1.66695526170213	1.70004064666667	0.00427679
2	72090576	rs10175577	0.9564678	0.1219	0.07843	-0.0545864750835763	-1.54876183646617	-1.76243571659193	0.0009192
2	72090842	rs13382420	0.03292554	0.1303	0.1324	-2.13299007998537	-1.51753887304965	1.50794068916667	0.00670669
2	72091011	rs7584979	0.05028275	0.6082	0.01577	1.95755068182697	0.513821306164384	-2.41898367258065	0.00468242
2	72092235	rs10181809	0.03200415	0.1466	0.1103	-2.14435874398812	-1.45380634609929	1.60036743166667	0.00726488
2	72092652	rs7565433	0.960938	0.1439	0.09541	-0.0489763758770346	-1.46070177340824	-1.67250962959641	0.0009192
2	72092996	rs11126351	0.905566	0.1341	0.1096	-0.118633057582461	-1.49449006	-1.59922671351351	0.000934121
2	72093265	rs181337139	0.734232	0.2508	0.0557	-0.339501489527854	1.14780653582996	1.91455849121951	0.000171391
2	72093589	rs2061452	0.08489644	0.6659	0.03103	1.72295623428586	0.431514558082192	-2.15349861532258	0.00535472
2	72093827	rs1975845	0.8394677	0.1284	0.133	-0.202574383283584	-1.52080365169811	-1.49992276576577	0.000934121
2	72093859	rs1975846	0.2485412	0.9014	0.1001	1.15390004269117	0.123176845273973	-1.63748010806452	0.00683297
2	72093906	rs1563739	0.04179258	0.5706	0.01364	2.03557966906786	0.568184727671233	-2.47551201612903	0.00484547
2	72094616	rs1459261	0.02593298	0.1433	0.08519	-2.22721382685894	-1.45794594084507	1.72534846333333	0.00797198
2	72094815	rs72622635	0.3845367	0.3254	0.857	-0.86956762830883	-0.98195360972973	0.179556212640693	0.000225033
2	72095154	rs1585328	0.06350382	0.6011	0.02439	1.85564745975429	0.524209570551724	-2.24217295645161	0.00521015
2	72095567	rs72841471	0.8424143	0.8241	0.5731	0.198806255551097	-0.222042410802139	-0.563952420560748	0.00158308
2	72096377	rs6737513	0.3528841	0.8468	0.2293	0.929009637071178	0.196907556478873	-1.19639387786885	0.0046481
2	72096946	rs10201864	0.1821757	0.2396	0.4989	1.33408583824324	1.17604079014084	-0.67522822525	0.00964082
2	72096992	rs113617864	0.1795253	0.2195	0.5307	1.34221807694772	1.22607036630435	-0.626955536528497	0.000402407
2	72097013	rs77082165	0.739348	0.6699	0.3079	-0.332716841016606	0.425852263875598	1.0199435305949	0.000444013
2	72097442	rs149214121	0.6289265	0.9463	0.4115	-0.483238359603396	0.0668934009716599	0.822296179620853	0.000457938
2	72097591	rs13425927	0.7838366	0.1665	0.2308	0.274322778138383	1.38429701921569	1.19708737247706	0.00111568
2	72097640	rs10205054	0.1201437	0.223	0.3379	1.55417079762155	1.22519557605634	-0.958428582644628	0.0111629
2	72097650	rs10170253	0.1711638	0.7364	0.08566	1.36847402222979	0.337668358783784	-1.71441623492063	0.00818492
2	72097933	rs6742335	0.2130818	0.8013	0.1032	1.24513594262235	0.250211819189189	-1.62687853015873	0.00801443
2	72098009	rs6742247	0.2129811	0.7933	0.1062	1.24540989120702	0.263674041689189	-1.61148836031746	0.00801443
2	72099121	rs7597769	0.3068968	0.8335	0.1818	1.02175525044117	0.209135466689189	-1.3358919696	0.0080823
2	72099440	rs1459262	0.2673956	0.8069	0.1556	1.10908025645123	0.245136026530612	-1.4237951224	0.00818492
2	72099609	rs56193513	0.934087	0.1752	0.1443	0.0827037903973408	1.35660004573643	1.46345901	0.00105464
2	72099750	rs116998110	0.1013259	0.1622	0.3762	1.63845936242474	1.39683275506073	-0.884100136231884	0.000416247
2	72099895	rs75220819	0.1469623	0.3289	0.2765	-1.45034515894052	-0.977476594161959	1.08761558380744	0.00033363
2	72100027	rs17007524	0.915554	0.1641	0.1432	0.106035728108761	1.39139112403101	1.46830033545455	0.00105464
2	72100055	rs78223235	0.1894373	0.3641	0.3402	-1.31224564926646	-0.908833649239544	0.955822064159292	0.00033363
2	72100088	rs114955646	0.1845155	0.3693	0.3214	-1.32697942440241	-0.897557364705882	0.991234491629956	0.00033363
2	72100090	rs77486577	0.1874252	0.3739	0.3226	-1.31823449000608	-0.888010427893738	0.988918081057269	0.00033363
2	72100164	rs76073923	0.1846111	0.3492	0.3452	-1.32669063383041	-0.937172846387833	0.944830801766004	0.00033363
2	72100450	rs72910744	0.1954631	0.3842	0.3303	-1.29458587622892	-0.870446637142857	0.973437833481153	0.00033363
2	72100861	rs10865388	0.4775707	0.9502	0.2401	0.710215097616986	-0.061671592	-1.16973275806452	0.00919295
2	72101123	rs17007526	0.98953	0.4482	0.3818	0.0131225274855644	0.75849303	0.87387272398374	0.000670314
2	72101321	rs72622637	0.6596983	0.7853	0.3031	-0.440329642751043	0.272236967563025	1.03090633175258	0.000347329
2	72101633	rs1380263	0.4959764	0.4895	0.8171	0.68083416183823	0.695163473191489	-0.233660611083333	0.0120904
2	72101672	rs11892224	0.9323147	0.1834	0.09171	-0.0849329030250183	1.32684770807692	1.68476361036036	0.00103947
2	72101974	rs116095967	0.7173612	0.9898	0.5779	0.361987747483036	0.0124367056080871	-0.555881158633776	0.000211582
2	72102094	rs6761639	0.4311856	0.3392	0.9287	0.787164448098706	0.957747072027972	-0.0902135609836065	0.0111629
2	72102210	rs78479673	0.1614856	0.224	0.4662	1.40009255378044	1.22091733506493	-0.725574810229008	0.00695431
2	72102211	rs79606011	0.1393992	0.2181	0.4037	1.47803206027624	1.23203198	-0.831998539694657	0.00689347
2	72102325	rs17557755	0.5949984	0.7602	0.2364	-0.531606680787129	0.303716237651822	1.1819315138756	0.00103947
2	72102466	rs147453033	0.9027955	0.5147	0.546	0.122130627794797	0.652131765774648	0.604076369018933	0.000265551
2	72102665	rs11678520	0.1486868	0.2741	0.3441	1.44418543151272	1.0914888379085	-0.945790622307692	0.00636211
2	72102703	rs7570746	0.2177265	0.2432	0.5985	1.23259602797384	1.16346312244898	-0.532398680241935	0.00882215
2	72104285	rs76998327	0.7063983	0.8892	0.6757	-0.376697639665119	-0.139693811498973	0.416855351325301	0.000457938
2	72104528	rs144012216	0.8100592	0.4611	0.6077	-0.240349649444845	-0.737604530057803	-0.513233587726639	0.000198158
2	72104573	rs35580256	0.245467	0.1244	0.9918	-1.16143021204608	-1.53878099698276	-0.0100512564170854	0.00173966
2	72104581	rs62147698	0.8862567	0.9093	0.7229	-0.143042436088583	0.115191215811518	0.353732644207317	0.000570383
2	72105349	rs35600361	0.216154	0.1056	0.9887	-1.23681987313303	-1.61364937424893	0.0150731160301508	0.00175638
2	72105601	rs6710683	0.0938185	0.1483	0.3748	1.67559012398665	1.44492522534247	-0.88711950483871	0.00926862
2	72106482	rs62147700	0.9366695	0.839	0.7193	-0.0794564650963474	0.204175513926702	0.359759271951219	0.000556225
2	72107582	rs59662921	0.2641347	0.7421	0.1829	-1.11667169636829	-0.329198999095841	1.33052896610526	0.000388595
2	72107760	rs75853099	0.14487	0.5048	0.1453	-1.45789315020239	-0.6660172275	1.45685662139918	0.000388595
2	72107761	rs72841476	0.5878461	0.767	0.2318	-0.541959902733844	0.29534610511811	1.19168415934579	0.00117725
2	72107776	rs113705274	0.3493147	0.4604	0.5646	-0.935919350928538	-0.738722690544872	0.576677159704251	0.000252017
2	72107826	rs881455	0.726801	0.9571	0.5421	-0.349384026627168	0.0533407873309609	0.608395944680851	0.000742593
2	72108222	rs17007555	0.05026971	0.2413	0.1012	1.95766178086851	1.17317315192308	-1.64422980606061	0.00591296
2	72108786	rs9784072	0.07936265	0.1476	0.3143	1.75439614069762	1.44492522534247	-1.00784718211382	0.00919295
2	72108825	rs17007558	0.9968362	0.7863	0.7557	0.00396524125265421	0.271683521899736	0.310733374769231	0.00058457
2	72109459	rs12618982	0.04212423	0.2279	0.08341	2.03229068848822	1.2024292664557	-1.72424430746269	0.00621949
2	72109818	rs78043713	0.02682797	0.2938	0.02953	2.21401178360684	1.0561862621118	-2.1751555649635	0.00540582
2	72109913	rs75473375	0.1174653	0.5629	0.0836	-1.56550176501652	-0.579333699047619	1.73096601038961	0.000279111
2	72109914	rs6740570	0.8296334	0.7149	0.4439	-0.215171772737233	0.365328300928793	0.765570113919414	0.000527998
2	72110659	rs115850543	0.3095574	0.1178	0.7808	1.01615129638504	1.56563460072816	0.278815386810345	0.000471892
2	72111155	rs6546730	0.03607595	0.1082	0.1735	2.09607032187251	1.59997931	-1.35409644330709	0.00739077
2	72111402	rs114474699	0.5942466	0.1543	0.3988	-0.532692194669246	-1.42444780276753	-0.844791237068966	0.000265551
2	72111530	rs7584466	0.01398657	0.2051	0.02095	2.45760803789978	1.26890639625	-2.30183278161765	0.00545792
2	72111651	rs7584587	0.01722201	0.2257	0.02353	2.38193332979631	1.20500532298137	-2.26466702573529	0.00540582
2	72111653	rs11904148	0.2176745	0.6827	0.1555	-1.23273556595411	-0.408174815992647	1.41838372467811	0.000374812
2	72111683	rs2901028	0.5522858	0.6337	0.1399	-0.594338295779013	0.476743592831541	1.47465701848739	0.000934121
2	72111942	rs17007563	0.8381372	0.9974	0.7567	-0.204276892492947	-0.00263865436147757	0.310733374769231	0.000570383
2	72112069	rs11685502	0.03513063	0.09597	0.198	2.10684937549946	1.66698393266667	-1.29163856929134	0.00732726
2	72112443	rs116804470	0.1962514	0.3064	0.4307	-1.2923054247556	-1.0242984986014	0.790304904526749	0.00075714
2	72112623	rs13409839	0.199538	0.6693	0.1401	-1.28286905622638	-0.426415102941176	1.4741522304721	0.000374812
2	72114039	rs60579855	0.8576721	0.4923	0.5921	0.179338285204725	0.688977194920635	0.535479576779026	0.00058457
2	72114564	rs72841483	0.8738818	0.5508	0.3435	-0.15872969839781	0.596289282262997	0.949497271480145	0.000513928
2	72114817	rs7562146	0.02096831	0.1086	0.09176	2.30855454697022	1.59887164076433	-1.68413495789474	0.00650686
2	72115974	rs115908441	0.2238107	0.6772	0.1657	-1.2164575734864	-0.417461864895636	1.38441142644444	0.000184761
2	72116933	rs6546731	0.05675553	0.1273	0.2496	1.90518881703734	1.52059833378378	-1.1522584248	0.00804831
2	72119577	rs1459264	0.586961	0.9371	0.3493	-0.54324506735254	0.0778765779322034	0.939223259109312	0.000641613
2	72119614	rs60050043	0.003151863	0.08128	0.0122	2.95252525643325	1.73964049272727	-2.51764410071942	0.00605108
2	72120357	rs72841485	0.4770755	0.955	0.2974	-0.711014107913363	-0.0554076597577855	1.04131409173554	0.000670314
2	72120520	rs61118079	0.458439	0.6233	0.5689	-0.741419613408928	-0.489862586947791	0.56833286509434	0.000471892
2	72120970	rs57567034	0.1101441	0.4417	0.1207	-1.59754583302303	-0.770538067793594	1.55024655030801	0.000374812
2	72121259	rs57516841	0.1252441	0.4348	0.1497	-1.53312872313717	-0.7806623885918	1.44121912123711	0.000374812
2	72121811	rs139130924	0.2792884	0.6252	0.02743	1.08191938323717	-0.487444593248945	-2.20276956956522	0.000499887
2	72122789	rs13024079	0.8289765	0.4825	0.6145	-0.216014427686549	-0.703622711636364	-0.503188321041215	0.000306315
2	72122938	rs10171418	0.4028358	0.911	0.2394	-0.836567390009271	-0.110175824034483	1.17366919504132	0.000670314
2	72126127	rs13421667	0.4095887	0.7488	0.3713	-0.824617554063351	-0.321124634545455	0.893537179432624	0.000444013
2	72126203	rs744026	0.1989899	0.5355	0.2108	-1.28443478587148	-0.620275313944954	1.25101308175966	0.000361057
2	72126420	rs744027	0.02544286	0.1953	0.05424	2.23461151365854	1.29516072564103	-1.92519012932331	0.00671316
2	72127817	rs75083127	0.3296202	0.5664	0.4085	-0.974879270991072	-0.574174012331407	0.826349397550111	0.000457938
2	72128326	rs10207832	0.1093721	0.4219	0.1269	-1.60102181025989	-0.802594645960503	1.52520362205882	0.000374812
2	72128536	rs13403583	0.2465503	0.8762	0.1058	-1.15876924100592	-0.155563474202335	1.61591277824074	0.00120824
2	72128745	rs28590026	0.1486904	0.8072	0.05114	-1.44417258060973	-0.245227554827586	1.94984731590909	0.00111568
2	72128779	rs28599993	0.1470005	0.8042	0.05042	-1.45020807845644	-0.24908376789272	1.95463711545455	0.00111568
2	72129297	rs17007572	0.269017	0.7815	0.1643	-1.10532918143769	-0.278444628969072	1.39103758888889	0.000699135
2	72129882	rs10164472	0.2104623	0.7845	0.1037	-1.25229523003208	-0.274669108576271	1.62598602276423	0.000684709
2	72130359	rs1380267	0.1382127	0.7445	0.05584	-1.48247957549116	-0.326768804653846	1.9132334913242	0.00111568
2	72130654	rs11681075	0.8939781	0.9338	0.7639	-0.133272144333088	0.0821009259151194	0.301328430465839	0.000627308
2	72131032	rs6712232	0.2725207	0.7773	0.1682	-1.09727615767405	-0.281909187319588	1.37432471687243	0.000699135
2	72131521	rs77314028	0.1341252	0.4248	0.1705	-1.49803115380349	-0.797513769723183	1.37017715030181	0.000374812
2	72133675	rs79794431	0.1538716	0.4255	0.2079	-1.42598885006644	-0.796829034548611	1.25999619415323	0.000374812
2	72134829	rs11695632	0.8023769	0.9219	0.7859	-0.25027215080643	-0.0972848643157895	0.271640615833333	0.000598786
2	72136328	rs9973384	0.3933839	0.9157	0.1484	-0.853496740631981	0.105383442614679	1.44326226108108	0.00190858
2	72137515	rs78686800	0.6759744	0.4303	0.7778	-0.417962594734499	-0.78781489431988	-0.281147220386643	0.000211582
2	72137643	rs60841192	0.4873134	0.429	0.9134	-0.694588195680028	-0.790538489670014	0.109081376447368	0.000131442
2	72137700	rs56856250	0.4884187	0.4296	0.9154	-0.692826007922837	-0.789405913037249	0.107212460845865	0.000131442
2	72137973	rs61446965	0.4884187	0.4299	0.9153	-0.692826007922837	-0.789405913037249	0.107212460845865	0.000131442
2	72138044	rs60879465	0.4495927	0.4793	0.75	-0.756094174254571	-0.707642386403509	0.31930744206501	0.000131442
2	72138056	rs72841499	0.2714935	0.9825	0.09286	-1.09962963452205	-0.0211554415226586	1.68109927204301	0.000542097
2	72138197	rs10188836	0.4720292	0.6879	0.523	-0.719181348830832	-0.400847367460317	0.639434063934426	0.000444013
2	72138330	rs9973794	0.4899657	0.714	0.5258	-0.690363335524404	-0.367229819361277	0.633853021126761	0.000444013
2	72138359	rs73944706	0.486319	0.4286	0.9125	-0.69617533160646	-0.790768416475645	0.110950106259398	0.000131442
2	72138461	rs55910505	0.2714935	0.9824	0.09274	-1.09962963452205	-0.0211554415226586	1.68109927204301	0.000542097
2	72138528	rs61506489	0.476365	0.4273	0.8945	-0.712161157912516	-0.793645238108883	0.133547025	0.000131442
2	72138797	rs60119376	0.4461357	0.4783	0.7438	-0.761873210979735	-0.709023495467836	0.327015447418738	0.000131442
2	72138965	rs79458364	0.2404814	0.4023	0.4095	-1.17378454555014	-0.837923921801802	0.825392242203742	0.000388595
2	72138976	rs56094975	0.2228008	0.7601	0.1232	-1.21911447634374	-0.304066966114865	1.5384134854251	0.000684709
2	72139790	rs1599093	0.1391694	0.7545	0.05388	-1.47889105671573	-0.311922332737643	1.9232179518018	0.00110038
2	72140580	rs55804332	0.1947943	0.79	0.0888	-1.29652598595889	-0.267834979525424	1.7032444495935	0.000684709
2	72142002	2:72142002_C_T	0.9874442	0.8996	0.8621	0.0157369152670113	-0.125513315730337	-0.173727031915367	
2	72142455	rs150580898	0.3264295	0.368	0.6606	-0.981331062868837	-0.900246259090909	0.438995835114504	0.000131442
2	72142670	rs73944707	0.2967144	0.3235	0.6694	-1.04350527498247	-0.986892847813411	0.427848960836502	0.000131442
2	72143119	rs77766390	0.1527118	0.3901	0.2328	-1.43001818265079	-0.860097988773748	1.1919642578	0.000374812
2	72143157	rs73944708	0.3739116	0.3973	0.7192	-0.889170245245614	-0.846078181804734	0.359505295602294	0.000131442
2	72143440	rs56240073	0.3320726	0.9622	0.1178	-0.969947559435017	0.0478659091017964	1.56020377588653	0.000527998
2	72144068	rs112353712	0.1600329	0.4225	0.2212	-1.40496106062179	-0.801382086873921	1.22284188253012	0.000374812
2	72144230	rs73944710	0.4051362	0.4498	0.7018	-0.832483263493594	-0.75557909808542	0.383524841603053	0.000131442
2	72144925	rs113217231	0.1874657	0.4722	0.2347	-1.31811353929959	-0.71853943481717	1.187805666171	0.000265551
2	72145004	rs75811698	0.08058855	0.126	0.3733	1.74728130139948	1.53107453541147	-0.892616756716418	0.000641613
2	72145170	rs1380268	0.2239034	0.865	0.09206	-1.21621400693606	-0.170529625775194	1.68672361474654	0.00117725
2	72146784	rs116542181	0.9855394	0.8751	0.8258	0.0181246557893067	-0.157269623943662	-0.219970602571429	0.000144732
2	72147963	rs144336470	0.05014197	0.097	0.2845	1.95875079542553	1.65995198438287	-1.06895165285285	0.000655949
2	72148446	rs7602885	0.2442206	0.7604	0.1456	-1.16450220851044	-0.303736627542662	1.45501105901639	0.000713591
2	72149222	rs12713767	0.5757648	0.3682	0.842	0.559581575939654	0.901798802518892	0.19933099547619	0.000485875
2	72149428	rs13429096	0.1624344	0.7092	0.08384	-1.39693066752891	-0.371933863294574	1.72802195483871	0.00119273
2	72149521	rs77095752	0.2385906	0.564	0.2495	-1.17851699707344	-0.57535747240566	1.14972845	0.000513928
2	72149527	rs78958565	0.3646112	0.39	0.711	-0.906613473009213	-0.86000835	0.369749504716981	0.000131442
2	72149758	rs73944711	0.3856705	0.4473	0.6627	-0.867495608692242	-0.760459279790419	0.435910827533461	0.000131442
2	72150855	rs6750030	0.2515057	0.7693	0.1526	-1.14669985741371	-0.295673069066148	1.43044959861111	0.00116181
2	72150898	rs6735281	0.2476974	0.7739	0.1439	-1.15596029237093	-0.286716768604651	1.45827162314815	0.00116181
2	72151756	rs17007589	0.5104509	0.605	0.6836	-0.658135741437506	-0.515918579706601	0.408908975588235	0.000542097
2	72151945	rs17558168	0.7106728	0.5212	0.8343	-0.370952690183076	-0.6414405	-0.209888809069264	0.000198158
2	72152148	rs6742118	0.2851565	0.9891	0.1001	-1.06880726087729	-0.0151095178761329	1.64387335431655	0.000542097
2	72152575	rs908613	0.9511603	0.1205	0.0579	-0.0612496500589515	1.55155867264574	1.89594441536458	
2	72153350	rs115310988	0.2087334	0.734	0.1299	1.25705581625716	0.340296209453781	-1.51429273190476	0.000144732
2	72153526	rs75789398	0.4838161	0.5031	0.7669	-0.700178002896979	-0.669713507462687	0.295805251187905	0.000402407
2	72154316	rs10194579	0.262087	0.7385	0.1769	-1.12147211952456	-0.331924603320463	1.35007520552995	0.0011464
2	72154399	rs75723938	0.5232985	0.5081	0.8327	-0.638269016994685	-0.661667744859813	0.211245796810345	0.000402407
2	72154439	rs78118490	0.5340661	0.541	0.8063	-0.621810994329999	-0.61119302728972	0.243973212526998	0.000416247
2	72154481	rs72842911	0.2528451	0.7798	0.1468	-1.14346607770974	-0.279984892525597	1.450659875	0.000699135
2	72154584	rs79454938	0.5237525	0.5063	0.8366	-0.637571622687667	-0.664106157462687	0.206977072047414	0.000416247
2	72155101	rs111545975	0.5455517	0.542	0.8258	-0.604439045072691	-0.608916703165736	0.219780710775862	0.000402407
2	72155152	rs908614	0.2609253	0.6958	0.2031	-1.12420681362641	-0.393157017733333	1.27544091102362	0.0111183
2	72155287	rs6733211	0.243079	0.7592	0.1446	-1.16732528946056	-0.306135448877551	1.45896628032787	0.000684709
2	72156126	rs75272359	0.5779385	0.5574	0.8642	-0.556398414391144	-0.58743852472119	0.171629422982833	0.000402407
2	72156187	rs115665001	0.5622982	0.2138	0.5762	-0.579431199753167	-1.24308205693312	-0.558895725855513	0.000347329
2	72156415	rs73944715	0.7087554	0.6755	0.9426	-0.373528160250822	-0.418758958123953	0.0722759901061571	0.000198158
2	72156426	rs7600734	0.378841	0.9422	0.1999	-0.880033893976104	-0.0721297913063063	1.27657923670213	0.00190858
2	72156702	rs7587256	0.5666033	0.9463	0.4179	-0.573061083711532	-0.0681864877708978	0.808687421691177	0.000598786
2	72157699	rs13425819	0.3521758	0.4564	0.575	-0.930377311291946	-0.744647832748538	0.560582874141876	0.000198158
2	72160175	rs6724478	0.4224808	0.9338	0.2517	-0.802124765911099	-0.0828564161146497	1.14314539398496	0.00302006
2	72160193	rs908615	0.567826	0.5708	0.8306	-0.571256142428599	-0.565772540163934	0.214648997268293	0.00127062
2	72160412	rs6753449	0.6097229	0.9056	0.3542	-0.510468963372217	0.117141836965517	0.927212866666667	0.00562123
2	72160956	rs114240926	0.5968128	0.2105	0.4994	-0.528989282944151	-1.25145163387978	-0.67543428557377	0.000499887
2	72161465	rs4852275	0.3146062	0.8543	0.18	-1.00560388426599	-0.180898537612903	1.34382701908397	0.00306322
2	72161863	rs55771006	0.6349536	0.4096	0.8051	0.474766121725657	0.825238873563218	0.247916909008264	0.000292699
2	72162252	rs62147704	0.5157568	0.2903	0.8019	-0.649899941355549	-1.05691900568182	-0.251608592857143	0.000613032
2	72162697	rs76478132	0.2649574	0.3111	0.5955	-1.11475046696341	-1.01360142818533	0.529501759728507	0.000225033
2	72163054	rs55705834	0.5990587	0.9258	0.3573	-0.525754502716996	0.0895969470344828	0.918370710569106	0.00589611
2	72164160	rs72912649	0.3574965	0.5741	0.447	-0.92014602314661	-0.561033158458244	0.760689514609572	0.00033363
2	72164293	rs7570117	0.5770557	0.9382	0.4379	-0.557690480004356	-0.0762466577152318	0.77577099488189	0.000830337
2	72164818	rs75963583	0.2386595	0.3223	0.5123	-1.17834398276633	-0.990496264176245	0.654697632286996	0.000225033
2	72165306	rs72842919	0.6478157	0.5477	0.9942	0.456798706885104	0.601463231367925	0.0084973090368272	0.000306315
2	72165714	rs67873479	0.6326027	0.9259	0.3936	-0.478066683762814	0.0937153110679612	0.853911845384615	0.000771718
2	72166324	rs17499335	0.6800662	0.3239	0.611	-0.412372800140826	-0.98691012317757	-0.508539091810345	0.000292699
2	72167136	rs12052842	0.2262096	0.1108	0.9856	-1.21018058229354	-1.59729356111111	-0.0164641984074074	0.000934121
2	72167424	rs34842669	0.130391	0.3699	0.2053	-1.51256197560672	-0.896188496357013	1.26689510264766	0.000556225
2	72168003	rs17558466	0.05536723	0.05552	0.5016	-1.91598323350635	-1.91358467096774	0.672560237925446	0.000184761
2	72168280	rs13011657	0.4330495	0.2755	0.887	0.783983902680394	1.09019303810598	0.141649582921013	7.85498e-05
2	72169353	rs7588891	0.2273085	0.5688	0.2306	-1.20732124411258	-0.569327630860927	1.19549375078125	0.00341865
2	72169646	rs72842923	0.6107702	0.4883	0.9762	0.508974259317093	0.691533561682243	0.0304541673961219	0.000306315
2	72169817	rs59290755	0.1374612	0.134	0.595	1.48531203475612	1.49720828066298	-0.529590764901961	0.00110041
2	72170193	rs72912652	0.9528737	0.7583	0.7903	-0.0590983806601192	-0.306703010799136	-0.266900231989924	0.000416247
2	72170462	rs80245701	0.6819545	0.6194	0.9583	0.409797414344816	0.49561165826087	-0.0529523448866499	0.000292699
2	72171416	rs11684040	0.1756726	0.1851	0.5991	1.35420000649154	1.32789201555556	-0.526442777565789	0.00113018
2	72172684	rs144231450	0.2076499	0.395	0.344	-1.2600539544313	-0.849753859240069	0.945390116396761	0.000158048
2	72173427	rs6546733	0.09389223	0.07795	0.6076	1.6752140863484	1.75815494269663	-0.513304381733333	0.00123637
2	72173760	rs10169677	0.1327499	0.1301	0.5905	1.50334576062859	1.51393686480447	-0.539707720460526	0.00116021
2	72173986	rs74421403	0.6171855	0.5294	0.9683	0.499843080011913	0.628120805672269	-0.0387719459322034	0.000238512
2	72174410	rs186911652	0.8697398	0.9956	0.8068	0.163989000353128	0.00617160526697531	-0.244641914028777	0.00033363
2	72174600	rs115203841	0.7138972	0.4423	0.7301	0.366627097411571	0.768948534137931	0.344450096065574	2.70733e-08
2	72175481	rs11693181	0.422586	0.3571	0.8778	0.801942898436017	0.91908931969112	-0.15505749173516	0.000119367
2	72175955	rs72842925	0.5990077	0.4714	0.9699	0.525827920404514	0.721329019906323	0.0387540419390582	0.000292699
2	72176317	rs76013758	0.0907003	0.2734	0.1866	-1.6917151101931	-1.09308155633075	1.32141628869048	0.000934121
2	72176897	rs17007634	0.245618	0.3747	0.4566	1.1610587974545	0.887969861764706	-0.748042625874126	0.00162339
2	72177707	rs17558577	0.9029423	0.8635	0.6977	0.121945316040474	-0.171931009001637	-0.388979949042146	0.000347329
2	72178287	rs908611	0.1617654	0.2948	0.3494	-1.39915865448102	-1.04180339722222	0.934812972131147	0.00547216
2	72178989	rs75045232	0.1637023	0.3334	0.3115	-1.39272711598325	-0.967066022222222	1.01217842987805	0.000158048
2	72179782	rs17007638	0.2009908	0.3397	0.3938	-1.27873390114844	-0.953930868262411	0.852124819166667	0.000158048
2	72180062	rs74647762	0.8280249	0.9332	0.6416	0.217235481598547	-0.0842059137117347	-0.465251077980132	0.000306315
2	72180282	rs79826401	0.233674	0.3533	0.4538	-1.19094799269545	-0.927381766489362	0.747872729166667	0.000158048
2	72180763	rs6734723	0.3465938	0.4169	0.6187	0.941216802215878	0.812921418064516	-0.496266132977099	0.00278759
2	72180856	rs57419340	0.1246045	0.201	0.3855	-1.53573028071609	-1.27826264563636	0.867812092324094	0.000198158
2	72181187	rs61220700	0.5224134	0.739	0.5508	-0.63962952514241	-0.333408169940476	0.5970476204947	0.000513928
2	72181659	rs1607194	0.1281928	0.2537	0.3137	-1.5212672638144	-1.14104443589744	1.00638293704497	0.000198158
2	72181714	rs1607195	0.1577031	0.3042	0.3316	-1.41283882871715	-1.02764534834559	0.972067824678111	0.000198158
2	72181965	rs1607196	0.1264349	0.2369	0.3332	-1.5283127316448	-1.18319639542125	0.967939717987152	0.000198158
2	72182062	rs72842929	0.5328603	0.7491	0.5546	-0.623645630944027	-0.318363379464286	0.59009820565371	0.000513928
2	72182422	rs189179050	0.4777888	0.1806	0.6236	0.709863451915552	1.33858060200861	0.490667831282051	6.53928e-05
2	72182751	rs185863508	0.2153999	0.3835	0.3753	-1.23885321526828	-0.871825128422877	0.886574200404858	0.000131442
2	72182758	rs13426792	0.130359	0.2402	0.3394	-1.5126877418922	-1.17362424223035	0.955041695289079	0.000198158
2	72182804	rs72842930	0.5990559	0.4458	0.9292	0.525758553828898	0.763529474004684	0.0887772562049862	0.000292699
2	72182946	rs112937432	0.9258483	0.7997	0.8731	-0.093069508883812	-0.253504428787879	-0.158465637491749	0.000830337
2	72183011	rs149890934	0.7546673	0.4847	0.7278	0.312491210950082	0.698263449353448	0.347899076030928	0.000211582
2	72183283	rs77483803	0.140496	0.2796	0.315	-1.47394660178258	-1.08052331153846	1.00433982205567	0.000198158
2	72183854	rs10185463	0.9836083	0.3914	0.2946	-0.0205453554556789	0.857116160377358	1.04780429456869	0.000598786
2	72184776	rs55864236	0.3497603	0.5286	0.4796	0.935054356346907	0.63005035461039	-0.702458837022901	0.00293458
2	72184815	rs55833856	0.354862	0.449	0.5911	0.925199812544044	0.759822877272727	-0.534692683435114	0.00291338
2	72185083	rs62147710	0.4386829	0.08478	0.4042	-0.774419285307832	-1.72648103547297	-0.833291373015873	0.000742593
2	72185848	rs111340438	0.03097039	0.05352	0.288	-2.15745291375174	-1.93012951657941	1.06320529796334	0.000144732
2	72185861	rs72622638	0.1453331	0.1571	0.5588	1.45621521531397	1.41678005611111	-0.581665567777778	0.00110041
2	72186263	rs977132	0.3415348	0.4139	0.6079	0.951137044891216	0.812921418064516	-0.511634432061069	0.00278759
2	72187212	rs13010378	0.1785504	0.3773	0.2991	-1.34523170775651	-0.881051439160839	1.04134561818182	0.00521015
2	72188364	rs6752766	0.1049107	0.338	0.1695	-1.62149866009036	-0.9586701375	1.37689494098361	0.00518153
2	72188433	rs114238345	0.291413	0.9713	0.1182	1.0550269422322	0.0350596790350877	-1.55992040575	0.000171391
2	72189250	rs1517397	0.1683953	0.3796	0.2746	-1.37737831529188	-0.881051439160839	1.09111261818182	0.00532561
2	72189489	rs981389	0.7411038	0.3607	0.5822	-0.330391985544404	-0.914234127744511	-0.550770140092166	0.000265551
2	72189602	rs981390	0.1910998	0.1119	0.8754	-1.30733258935367	-1.58937256033994	0.157844372105263	0.000527998
2	72189807	rs954163	0.07532707	0.2187	0.1967	-1.77846770030432	-1.23148793877551	1.2983630233871	0.00408647
2	72190463	rs11678046	0.1683554	0.4131	0.2431	-1.37750746505711	-0.819398556944444	1.16382945901639	0.00535472
2	72190584	rs11683875	0.9060884	0.5526	0.3755	-0.117973759319722	0.593072007712766	0.88648044511041	0.00058457
2	72191439	rs6707806	0.21256	0.1717	0.7697	-1.24655695568878	-1.36663305337423	0.292235229222011	0.000131442
2	72191462	rs6723028	0.2913834	0.1214	0.847	-1.05509161005247	-1.55076640572687	-0.190557981649485	0.00172297
2	72191570	rs6736528	0.09588561	0.08305	0.5957	-1.6651360861626	-1.73842914899329	0.527363893543307	0.00674298
2	72191662	rs6736570	0.08616056	0.0854	0.5328	-1.71600807108617	-1.72465551610738	0.621946676614173	0.00671316
2	72191973	rs73944721	0.1857547	0.3118	0.3935	-1.32324253192356	-1.0119572009901	0.852948578733032	0.000499887
2	72192369	rs4852828	0.163553	0.2983	0.3555	-1.39322105180369	-1.04237452198582	0.924848889166667	0.011711
2	72193998	rs112779787	0.6394834	0.2342	0.5081	-0.468421177384695	-1.18939537178947	-0.661073602195122	0.000319959
2	72194611	rs991136	0.149516	0.1117	0.7279	-1.44124312724579	-1.59029304791667	0.352519553442623	0.00856986
2	72195993	rs7569239	0.3436303	0.3835	0.6625	-0.947016758988631	-0.871726345714286	0.436678563613445	0.0115255
2	72196680	rs72842943	0.2802909	0.814	0.1658	-1.07966620266253	-0.233353079810726	1.38604144044118	0.0009192
2	72197252	rs10153788	0.3344436	0.3836	0.6387	-0.965202049481194	-0.865543889361702	0.470946783193277	0.0115716
2	72197313	rs112675042	0.6789172	0.1534	0.2972	-0.413941124724209	-1.42725647525424	-1.0439039648	0.000771718
2	72197419	rs17007655	0.6809529	0.1561	0.3006	-0.41116314151057	-1.41700477559322	-1.0361037728	0.000771718
2	72198580	rs2420046	0.3024641	0.3823	0.5713	-1.03116360364317	-0.872005538297872	0.566404083333333	0.0116644
2	72198746	rs2138785	0.2617056	0.1355	0.9788	-1.12236898309979	-1.49631455314685	-0.0245938531967213	0.00923072
2	72199472	rs62147738	0.4866683	0.08807	0.3516	-0.695617586441617	-1.7063518965035	-0.933975634979424	0.000889453
2	72200809	rs62147739	0.4950757	0.08835	0.3407	-0.68225806793668	-1.7063518965035	-0.954608296296296	0.000889453
2	72200879	rs6738559	0.660393	0.4488	0.8364	-0.43937055900857	-0.756991412383178	-0.206489072690217	0.000499887
2	72201133	rs6726726	0.6885725	0.5074	0.8743	-0.400793086841031	-0.664390686946387	-0.156669428297297	0.000499887
2	72201187	rs72842945	0.337769	0.8299	0.2214	-0.958582829295413	-0.214608473817035	1.21975715750916	0.000934121
2	72202335	rs11694497	0.07973371	0.07784	0.5328	1.75223322381303	1.76850402969432	-0.625854812307692	0.00170633
2	72203754	rs116242475	0.7876975	0.9631	0.6382	0.269301755559374	-0.0460468136809816	-0.471166273188406	0.000815636
2	72203991	rs7558552	0.8513588	0.1003	0.1009	-0.187384989008119	-1.64469007890625	-1.64235591605505	0.00123936
2	72204930	rs138353274	0.6875596	0.6081	0.9852	-0.402169024437642	-0.512111860107817	0.0189816478481013	0.000800965
2	72206006	rs6722569	0.04657741	0.08419	0.2974	-1.99012280189272	-1.72518532394366	1.04179410166667	0.0135687
2	72206150	rs114669536	0.5712384	0.1059	0.325	-0.566228562303952	-1.61576129901961	-0.984432561521253	0.000238512
2	72206690	rs10865389	0.02177782	0.03074	0.3103	-2.29422074913007	-2.15246067361111	1.00852413606557	0.0171152
2	72207201	rs60152289	0.01974997	0.02313	0.3538	-2.33106433070349	-2.27075187222222	0.925898339344262	0.0178243
2	72210707	rs138013078	0.5548912	0.122	0.3859	-0.590446697738937	-1.54610897740668	-0.865755014317674	0.000225033
2	72211390	rs7594591	0.09115357	0.1648	0.3348	-1.68934373010548	-1.39470614788732	0.9668692275	0.0122356
2	72211877	rs146282585	0.8593246	0.8652	0.9405	-0.177233971396149	-0.170043751650246	0.0741893099142857	0.000471892
2	72213541	rs115321343	0.5324304	0.9246	0.2634	-0.624300237152285	0.0939272644131455	1.11992057897839	0.000198158
2	72213696	rs58979157	0.7144897	0.9132	0.6583	-0.365832926892724	-0.108633687530864	0.440782978106509	0.000527998
2	72214102	rs13012092	0.1520724	0.177	0.5359	-1.43224971821093	-1.3518452970339	0.620138336	0.00189151
2	72214109	rs78310459	0.3983388	0.8293	0.2905	-0.844591766881785	-0.21465309879717	1.05926823661972	0.000361057
2	72217656	rs75780903	0.7339787	0.8521	0.757	-0.33983775214372	-0.18547257971831	0.308792477903683	0.000513928
2	72218544	rs144823683	0.1117078	0.3916	0.1458	1.59056390577905	0.85672547358209	-1.45285808703375	0.000118179
2	72218636	rs78593043	0.1588421	0.244	0.4226	1.40897659346925	1.16482112382763	-0.802437500765697	0.000252017
2	72219476	rs17007663	0.6542768	0.9079	0.5747	-0.447828733290913	-0.116362192054455	0.56125752119403	0.000627308
2	72220565	rs4144821	0.1220721	0.2471	0.3058	-1.54613453178378	-1.15909106887417	1.0237319828125	0.00636211
2	72221075	rs74353611	0.7374696	0.8462	0.7719	-0.335206081796798	-0.193382785274463	0.291366428	0.000513928
2	72221139	rs6707101	0.6746807	0.9814	0.528	-0.41973264722035	-0.022342561866005	0.629728605671642	0.000655949
2	72221149	rs11899600	0.7772592	0.4265	0.609	0.282892638797338	0.795227824269006	0.512380960701754	0.0009192
2	72221228	rs6722636	0.7890575	0.3713	0.5116	0.267534690850823	0.894651987719298	0.658591013732394	0.0009192
2	72221408	rs62147740	0.5696675	0.5793	0.8201	0.56854111344944	0.554460566475645	-0.227632309966777	0.000158048
2	72222356	rs6740100	0.1872531	0.146	0.7458	1.31874884111273	1.45422804924761	-0.324204382419355	0.000252017
2	72222724	rs143071380	0.3983217	0.06464	0.4026	-0.844622308114601	-1.84708584057971	-0.836965378703704	0.000144732
2	72223865	rs35090850	0.0624528	0.1269	0.2789	-1.86306727808748	-1.52418268321678	1.08295614710744	0.0146351
2	72224112	rs79164671	0.3510205	0.3844	0.6772	0.932611610346757	0.869818572481573	-0.415624518604651	0.000252017
2	72225048	rs72842953	0.2504245	0.02748	0.4434	-1.14931903615265	-2.20608578741866	-0.765975051724138	0.00033363
2	72225437	rs77138433	0.2388709	0.3257	0.5086	1.17781372343673	0.983778560216998	-0.660136537634409	0.000319959
2	72226769	rs77470717	0.7219046	0.8668	0.7243	-0.355914560193342	-0.168393282673267	0.354134707142857	0.000513928
2	72226925	rs74758079	0.4880105	0.5765	0.6786	-0.693476505119258	-0.558428708262108	0.413401142372881	0.000627308
2	72228008	rs1517396	0.1449444	0.1282	0.6507	-1.45762330940975	-1.52843897464789	0.44961820975	0.0124815
2	72228899	rs78592785	0.5261043	0.5029	0.85	-0.6339639514093	-0.669631600854701	0.189333335135135	0.000641613
2	72229939	rs79865610	0.5340346	0.5341	0.8198	-0.621858847610041	-0.620963315384615	0.228850134680135	0.000641613
2	72230980	rs17007667	0.5331577	0.5021	0.8642	-0.623192893851833	-0.671351892817679	0.170376226459016	0.000598786
2	72231725	rs72842956	0.2412468	0.002801	0.09128	-1.17187620863311	-2.98984603905724	-1.69297051732283	0.000655949
2	72231987	rs76660899	0.5099669	0.4898	0.8402	-0.658889230399654	-0.691442391714286	0.20276865527027	0.000627308
2	72232580	rs76415892	0.1867636	0.2969	0.4182	1.32021391839851	1.04330611043257	-0.809878961360124	0.000252017
2	72233950	rs11126353	0.278483	0.1225	0.8786	-1.08373349063717	-1.54562726643357	-0.148894375785124	0.0104266
2	72234144	rs116462009	0.5122738	0.5014	0.8285	-0.655301227914618	-0.674177538857143	0.216931511220339	0.000641613
2	72234166	rs115096298	0.7764335	0.845	0.8342	-0.283969817268516	-0.195397321505882	0.209111116299435	0.000499887
2	72234390	rs74712796	0.7394061	0.7476	0.8939	-0.332639957823954	-0.322324417535545	0.133114522832861	0.000499887
2	72234634	rs56926529	0.2639028	0.3301	0.5649	1.11721423214125	0.973660182345191	-0.576206027460317	0.000252017
2	72234860	rs17559295	0.6510202	0.4783	0.8927	0.452345283090695	0.710793690909091	0.135076681256039	0.00172297
2	72235058	rs3860462	0.08675686	0.03404	0.8842	-1.71275911728936	-2.12075612411348	0.142735851764706	0.0100546
2	72235206	rs1105118	0.09299215	0.03762	0.8833	-1.67982097750143	-2.0776551106383	0.142735851764706	0.0100546
2	72235444	rs7572229	0.1447233	0.06269	0.9563	-1.45842555749324	-1.86411422285714	0.0588029507815126	0.0125812
2	72235494	rs7598575	0.1432217	0.05856	0.9701	-1.46389830038904	-1.892713665	0.0336067244789916	0.0122356
2	72235688	rs4405788	0.09944076	0.03901	0.9117	-1.64757085092271	-2.06378069716312	0.109172750588235	0.0101772
2	72235757	rs79901993	0.5262695	0.5092	0.8421	-0.633710888191931	-0.660139249142857	0.200086293322034	0.000641613
2	72235774	rs1543165	0.1478421	0.06238	0.9764	-1.4471958172645	-1.86411422285714	0.0338915272288136	0.0122844
2	72235935	rs77442886	0.4473822	0.4388	0.788	-0.759786467015118	-0.774549973728814	0.268044290873786	0.000211582
2	72236033	rs112683395	0.5310031	0.01957	0.07509	-0.626475445244151	-2.33235892052117	-1.78461626269231	0.000556225
2	72236202	rs2420045	0.1462865	0.06513	0.9484	-1.4527741336251	-1.84285539214286	0.0677695059830509	0.0122844
2	72236597	rs4852831	0.143311	0.06191	0.9557	-1.46357169382474	-1.86411422285714	0.0593012808728814	0.0126314
2	72236698	rs4852832	0.1374672	0.05946	0.9467	-1.48528916178224	-1.88537938285714	0.0677695059830509	0.0125812
2	72236929	rs4852833	0.1388486	0.06118	0.9391	-1.48009254437401	-1.87144632142857	0.0762368849830509	0.0126314
2	72236979	rs6726291	0.1433515	0.06306	0.9459	-1.46342347672123	-1.85678287714286	0.0677695059830509	0.0126314
2	72237360	rs955788	0.1017157	0.04706	0.8549	-1.63659229355581	-1.98569648439716	0.184670885966387	0.0104266
2	72237368	rs955789	0.1432717	0.06391	0.9422	-1.46371566299035	-1.85678287714286	0.0755962388907563	0.0125812
2	72237571	rs7580030	0.5509318	0.4873	0.9188	-0.596364290581516	-0.694918555649717	0.10052043557047	0.000641613
2	72238632	rs17007672	0.5622827	0.5196	0.8921	-0.579454127932164	-0.643975675498575	0.135202073614865	0.000641613
2	72238903	rs79165422	0.5845492	0.5161	0.9387	-0.546751770047843	-0.649789309887006	0.0770925855369128	0.000641613
2	72238904	rs74931303	0.4567634	0.01143	0.06868	-0.744186804503015	-2.52911294512987	-1.82460495992366	0.000556225
2	72239068	rs143023416	0.2275078	0.1397	0.8838	-1.20680368177733	-1.47705881706161	0.145894226792793	0.000118179
2	72239125	rs908612	0.1031996	0.03397	0.9823	-1.62953619879513	-2.11235193943662	0.02499625075	0.00981304
2	72239132	rs76116281	0.5572012	0.5388	0.8556	-0.587003650644298	-0.613683084090909	0.182277652601351	0.000627308
2	72239352	rs115203996	0.4595453	0.0113	0.06668	-0.739595696634459	-2.53262291071429	-1.83581692709924	0.000556225
2	72239453	rs114471660	0.5673328	0.5284	0.8909	-0.571983940242974	-0.630815624715909	0.13856679125	0.000627308
2	72239692	rs883313	0.1478938	0.1947	0.4747	-1.44701100673567	-1.29564886971831	0.708645040916667	0.0163061
2	72239762	rs883312	0.1636777	0.05376	0.8902	-1.39280840274336	-1.93611751347518	-0.134561459411765	0.00985294
2	72239809	rs883311	0.1635948	0.05578	0.905	-1.39308271601745	-1.92227075815603	-0.117729488739496	0.00981304
2	72239845	rs184589554	0.6539049	0.9218	0.5495	-0.448344039314457	-0.0984182813870246	0.598338020226308	0.000104943
2	72239953	rs17007677	0.9274299	0.9734	0.8544	-0.091078805342696	0.0330737804728132	0.182842273742857	0.000499887
2	72240527	rs12713768	0.244918	0.3975	0.427	-1.16278196738546	-0.846359865034965	0.80031134525	0.0157904
2	72240957	rs17007681	0.7886166	0.7877	0.9236	-0.268107523704607	-0.269697345348837	0.0950893612849162	0.000499887
2	72241082	rs79710551	0.8065354	0.7642	0.9821	-0.244898047557334	-0.300067101395349	0.0223374349329609	0.000485875
2	72241164	rs72845572	0.2372962	0.003752	0.1169	-1.18177195122656	-2.90187959527027	-1.5669953496063	0.000670314
2	72241295	rs10208040	0.224664	0.405	0.3747	-1.21421930387508	-0.836832568794326	0.891057376470588	0.0142324
2	72241361	rs17559498	0.2340209	0.004005	0.1241	-1.19006480963799	-2.87754224047619	-1.53766170358566	0.000684709
2	72241466	rs7594506	0.776259	0.7946	0.8964	-0.28419756893515	-0.260523593255814	0.131255381452514	0.000485875
2	72241504	rs7568074	0.6424638	0.05628	0.1252	-0.464256701207379	-1.90908050727273	-1.52914261390374	0.00172297
2	72242013	rs2176407	0.1572676	0.04963	0.8969	-1.41432118104552	-1.96447086760563	-0.133440113916667	0.0112076
2	72245750	2:72245750_T_C	0.7658236	0.5262	0.7556	0.297842274781251	0.633885334821429	0.311270474965422	
2	72248907	rs145668607	0.8595999	0.8569	0.9538	-0.176883457974673	-0.180740979483568	0.0592598328248588	0.000485875
2	72248922	rs7601439	0.2726099	0.4177	0.4566	-1.09707197101229	-0.809565106338028	0.741689565583333	0.0144611
2	72249039	rs12472351	0.1253416	0.05531	0.9104	-1.53273324039694	-1.91524610492958	0.108262977666667	0.0102598
2	72249411	rs4852276	0.07996827	0.05956	0.633	-1.75087015500428	-1.88657317730496	0.479302766134454	0.0116179
2	72249501	rs72915311	0.07923104	0.1896	0.243	1.7551652841702	1.31096503646113	-1.16833464326923	0.000252017
2	72249551	rs114862613	0.8461532	0.8108	0.9871	-0.194028983481193	-0.238361272897196	0.0168488784269663	0.000485875
2	72249814	rs72915313	0.7954581	0.8375	0.8729	-0.259229615967087	-0.205134804316038	0.158761096883853	0.000485875
2	72250097	rs4852836	0.4274484	0.5635	0.5859	-0.793565514602261	-0.577715306408451	0.546120734453781	0.012432
2	72250489	rs13417153	0.5090333	0.5401	0.7673	0.660343688753735	0.611943579813665	-0.297469524869888	0.00100921
2	72250940	rs139205793	6.949377e-07	8.063e-07	0.05323	-4.96277304850125	-4.93344045399516	1.93251694197031	0.922148
2	72250973	rs4852277	0.07814249	0.02997	0.8722	-1.76156691907255	-2.17046438297872	0.159512376722689	0.0136227
2	72251458	rs114391331	0.7062365	0.6567	0.9588	-0.376915302960867	-0.445261977372263	0.0515267457651246	0.000252017
2	72251751	rs1878503	0.0871685	0.04882	0.7492	-1.71052679419414	-1.97171270633803	0.316896694416667	0.0157904
2	72252223	rs13412195	0.7478025	0.7025	0.9668	0.321538304871666	0.383302008099689	-0.0413761445112782	0.0009192
2	72252605	rs10180343	0.1067627	0.1008	0.5858	1.61291629452588	1.64044841734104	-0.544988768539326	0.000238512
2	72253553	rs13416099	0.6162315	0.6987	0.751	0.501198295370524	0.388049476970954	-0.317202356091371	0.000402407
2	72254126	rs4852837	0.06294748	0.07848	0.4285	-1.85956227818914	-1.75922829219858	0.798713194453782	0.0138965
2	72254230	rs114456185	0.4444941	0.5724	0.6051	-0.764626309856688	-0.565105526363636	0.516570406433824	0.000252017
2	72254272	rs4852838	0.115065	0.1496	0.4551	-1.57582995223254	-1.43638054014084	0.741689565583333	0.0106384
2	72254608	rs6755787	0.06376565	0.08476	0.4046	-1.85381485248272	-1.72361266099291	0.832002073697479	0.0138413
2	72255097	rs6759217	0.06376565	0.08434	0.4072	-1.85381485248272	-1.72361266099291	0.832002073697479	0.0138413
2	72256347	rs11679009	0.07116268	0.06962	0.513	-1.80443789652379	-1.81137023216783	0.65278700768595	0.0161755
2	72256400	rs10175878	0.2118092	0.2758	0.5193	-1.24860613221897	-1.0881835789272	0.64527813180778	0.00033363
2	72256523	rs10175844	0.1361427	0.1762	0.4809	-1.49031023214413	-1.35233851971831	0.708645040916667	0.0105958
2	72257858	rs10202944	0.6072903	0.7412	0.6848	0.51394520894133	0.331289725258799	-0.406537742171717	0.000402407
2	72258676	rs80229570	0.9595902	0.7045	0.714	0.0506676915518611	0.379101300371747	0.365416623652174	0.00165661
2	72258959	rs10195394	0.627157	0.7538	0.7014	0.485732161869636	0.313184391078838	-0.383964963131313	0.000402407
2	72261735	rs75431442	0.8677086	0.8693	0.9483	-0.166569813968006	-0.163481817419355	0.0638155291388889	0.000499887
2	72262583	rs116790536	0.5276458	0.4369	0.9573	-0.631603795657383	-0.776477708575804	0.053428101697417	0.000198158
2	72263225	rs34155263	0.4189208	0.9642	0.2273	-0.808294948699887	-0.0416791716666667	1.20684771735537	0.0177519
2	72263628	rs13382212	0.1364132	0.11	0.6789	-1.48928184835572	-1.60141397832168	0.413015843801653	0.0105532
2	72264192	rs13028486	0.2988273	0.6054	0.3196	-1.03895160740223	-0.517293190909091	0.999811535833333	0.0169088
2	72264608	rs4852278	0.3633359	0.5056	0.534	-0.909027044507799	-0.666381505069444	0.619982733057851	0.0180436
2	72264864	rs4852279	0.3548895	0.6859	0.3373	-0.925146882973208	-0.401140320070422	0.958631615	0.0164379
2	72264924	rs35667135	0.3548415	0.6852	0.3417	-0.92523913962854	-0.408223158239437	0.950393188333333	0.0164379
2	72265247	rs10187917	0.9672017	0.6422	0.5406	0.0411180716580961	-0.46460832972973	-0.611481055776892	0.000292699
2	72266448	rs62150064	0.5334405	0.1756	0.5402	-0.622762637682958	-1.35557945742905	-0.611544472115385	0.000118179
2	72266909	rs10204373	0.2136156	0.1505	0.8216	-1.24368476737404	-1.44061158811189	0.222839797355372	0.0106384
2	72266954	rs34243964	0.3064193	0.6183	0.316	-1.02276435748658	-0.49616159972028	0.999811535833333	0.0154153
2	72267484	rs1400683	0.305339	0.02975	0.3247	-1.02505121579686	-2.16995217312253	-0.985865849765258	0.00125497
2	72269028	rs185665940	4.321342e-07	2.45e-06	0.02057	-5.05422840098506	-4.71459972905759	2.31592584570597	1
2	72269420	rs4852839	0.2865086	0.297	0.6829	-1.06581205977097	-1.04705142483221	0.412418643412698	0.0158538
2	72269451	rs4852281	0.2437777	0.293	0.578	-1.16559623113432	-1.053615436	0.559425333070866	0.0159176
2	72269484	rs4852282	0.2193254	0.1063	0.9892	-1.22832389397349	-1.6213247	-0.016001600216	0.000103368
2	72269584	rs71416732	0.8012324	0.5502	0.752	-0.251752516054076	-0.596204239901478	-0.314219677848837	0.00277606
2	72269720	rs72845583	0.8370703	0.2637	0.3148	-0.205642376851512	-1.11422133885714	-1.00673241564626	0.00431593
2	72269897	rs6738168	0.4137269	0.9066	0.16	0.81735267178527	-0.119610521383648	-1.4102565	0.00109378
2	72270281	rs4852841	0.08064762	0.3191	0.1242	-1.74694070247149	-0.996293400361011	1.53476408652174	0.00113103
2	72270549	rs149118119	0.2778707	0.04263	0.4986	-1.08511515481932	-2.02729464044944	-0.677031461070111	0.000211582
2	72270601	rs77072827	0.5392124	0.292	0.7653	0.614004323469998	1.05343188744856	0.29817441809291	0.000238512
2	72270790	rs1400682	0.2183186	0.8296	0.09575	-1.231011488571	-0.214136412839506	1.66811207227723	0.00133354
2	72270883	rs74675801	0.03639876	0.1543	0.1209	-2.09244460827243	-1.4245895260274	1.5523477375	0.000211582
2	72270951	rs1400681	0.0647419	0.3241	0.08798	-1.84703611415829	-0.985532741516245	1.70441226956522	0.00106985
2	72271607	rs11126355	0.375155	0.2671	0.9496	-0.886858628026792	-1.10587083576159	0.0629669425669291	0.000787829
2	72272403	rs4852842	0.3252366	0.1387	0.8212	-0.983753882611514	-1.47652619328859	-0.22253391531746	0.0176081
2	72273058	rs6750558	0.9275416	0.3984	0.391	-0.0909382767168924	-0.843795378125	-0.859035988888889	0.0349748
2	72275005	rs11884312	0.5130822	0.2465	0.7167	0.654045955976593	1.15736834892241	0.362471063753213	0.000252017
2	72275225	rs114413957	0.5165205	0.3068	0.8349	0.648718221880096	1.02300834395833	0.208034216435644	0.000238512
2	72275634	rs139217109	0.358921	0.4904	0.5453	-0.917423153786269	-0.690320076923077	0.604331830322581	0.000499887
2	72275635	rs144028478	0.5092514	0.3137	0.8627	0.660003717100876	1.0063155406639	0.17315530970297	0.000238512
2	72275801	rs115422621	0.44585	0.2468	0.8425	0.762351810688115	1.15946563395445	0.197968591856436	0.000238512
2	72278093	rs13384263	0.9441215	0.3851	0.2563	0.0700905602805484	-0.865874963414634	-1.13787273405797	0.0366072
2	72279097	rs74677193	0.4625457	0.2881	0.8992	0.734661443437764	1.064342206639	0.126163075693069	0.000238512
2	72279195	rs74403040	0.4596593	0.2877	0.9059	0.739407984782716	1.064342206639	0.118773982970297	0.000238512
2	72279514	rs6728109	0.6572901	0.08853	0.1812	-0.443657643454349	-1.70674030509554	-1.34057943484848	0.030809
2	72280792	rs4852844	0.1082571	0.402	0.1337	-1.60607633686982	-0.838158407352941	1.50228479911894	0.00116181
2	72281114	rs11894560	0.4577879	0.288	0.9107	0.742494290829656	1.06217406078838	0.111382683787129	0.000238512
2	72282144	rs10179750	0.403988	0.8958	0.1456	-0.834519967936599	0.129506481464435	1.455119371	0.00142897
2	72282366	rs145311111	0.06001336	0.2956	0.09241	1.88069541762886	1.04537045079365	-1.68394927547684	0.000430116
2	72282418	rs181401030	0.4608168	0.1666	0.6225	0.737502524992626	1.38300841692308	0.492717634181818	7.85498e-05
2	72282449	rs13398798	0.3577499	0.9135	0.1175	-0.91966111370041	0.10864543292887	1.56775046934673	0.00142897
2	72282568	rs150401825	0.08533227	0.3508	0.1178	-1.7205513346271	-0.934155326373626	1.56558225087719	0.0011464
2	72282608	rs13398998	0.5650692	0.08112	0.2398	-0.575328287279622	-1.7453522133758	-1.18189895681818	0.0309558
2	72282880	rs57611840	0.5453186	0.08635	0.27	-0.604789841550746	-1.71982646496815	-1.1057579780303	0.0309558
2	72283086	rs13427365	0.3661926	0.9202	0.1263	-0.903628192080243	0.10029810041841	1.5326686758794	0.00142897
2	72283137	rs13402066	0.3661926	0.9203	0.1266	-0.903628192080243	0.10029810041841	1.5326686758794	0.00142897
2	72283210	rs35184851	0.4659324	0.3218	0.9606	0.729113139594904	0.991764242619543	0.0497015587810945	0.000238512
2	72284187	rs11126358	0.4415	0.2104	0.7723	-0.769662599527028	-1.25157918027211	-0.290037057580645	0.0198338
2	72284285	rs11126359	0.411214	0.1832	0.7574	-0.821759096539016	-1.33339099727891	-0.306225826451613	0.0198338
2	72284717	rs13420618	0.4298639	0.2536	0.8904	0.789424562747045	1.14203554602151	0.136493599458763	0.000238512
2	72285273	rs151027744	0.4601542	0.3009	0.933	0.738592860086054	1.03532596153846	0.0842623548019802	0.000238512
2	72285842	rs113598404	0.9491234	0.9845	0.9395	0.0638074693279267	0.0194376420638889	-0.0759950185808581	0.000728077
2	72285949	rs6546737	0.5305137	0.4125	0.9993	-0.627221953647702	-0.82332966462585	0	0.0209399
2	72286372	rs12469515	0.3292495	0.9766	0.1372	-0.975626729443417	-0.0292989587615063	1.4852211355	0.00142897
2	72287604	rs116548616	0.7867514	0.9122	0.5754	-0.270531498187388	0.110806339749702	0.560077388422576	0.000252017
2	72288598	rs12327958	0.9962225	0.3727	0.2876	0.00473440606571962	-0.890000323780488	-1.06503483768116	0.0364204
2	72289137	rs138008900	0.4777507	0.2782	0.8501	0.70992482690241	1.08341753645833	0.189552089102244	0.000252017
2	72289902	rs79485896	0.09904969	0.361	0.1383	-1.64947827990438	-0.911535521771218	1.48241026769912	0.0011464
2	72292178	rs376565921	0.2877783	0.2516	0.7847	1.06300817493863	1.14626869125189	-0.273696103538175	
2	72298373	rs6713569	0.1022612	0.373	0.1397	-1.63398886359941	-0.892029946468402	1.48226075133929	0.0011464
2	72298731	rs6742239	0.4344671	0.1908	0.732	-0.781570357984453	-1.30523842272727	-0.341059251550388	0.00112969
2	72298863	rs6714141	0.6265479	0.4214	0.8355	-0.486591424099016	-0.808223101986755	-0.204991013385827	0.000909126
2	72298966	rs76113582	0.1519102	0.2104	0.4568	-1.43281690062077	-1.25264718078947	0.743968407981928	0.000158048
2	72299696	rs4852846	0.6121424	0.4514	0.9135	-0.507017686291625	-0.755283977483444	-0.110313457952756	0.000862397
2	72300447	rs13433052	0.5357807	0.3435	0.8759	-0.619205936353879	-0.945777678378378	-0.16016021368	0.000625051
2	72300987	rs143548133	0.7829146	0.9592	0.6238	-0.275522827189781	0.0511992684761905	0.490028983096591	0.000292699
2	72300996	rs59828640	0.07147563	0.276	0.1317	-1.80244365823203	-1.08859424059041	1.50893207699115	0.0011464
2	72301337	rs77056183	0.08011896	0.2834	0.1491	-1.74999621321541	-1.07361271360294	1.44476979823789	0.0011464
2	72301587	rs72904426	0.07424492	0.2792	0.1358	-1.78510105239443	-1.08099398745387	1.49096742743363	0.0011464
2	72301620	rs77398548	0.07374409	0.2764	0.1367	-1.78819782298866	-1.08859424059041	1.48668905442478	0.0011464
2	72301759	rs72904430	0.08186085	0.2951	0.1438	-1.73998954831664	-1.04795108929889	1.46015390530973	0.0011464
2	72301903	rs59496509	0.07469039	0.2789	0.1372	-1.78236091262663	-1.08099398745387	1.48668905442478	0.0011464
2	72302190	rs28464218	0.8915107	0.2749	0.2774	-0.136392898611245	-1.0951317827381	-1.08436212535211	0.00384395
2	72302711	rs10195125	0.3510507	0.9858	0.1411	-0.932553269772373	0.0168742625021097	1.47472294949495	0.00144499
2	72303267	rs140220548	0.690046	0.3717	0.6716	0.398792589629421	0.893858091504425	0.42339839591002	0.000131442
2	72303326	rs17007725	0.1080874	0.3621	0.1565	-1.60684937902838	-0.910222416479401	1.41684132690583	0.00117725
2	72303473	rs17007727	0.08114026	0.2903	0.1453	-1.74410799018093	-1.05564298037037	1.45761219644444	0.0011464
2	72303819	rs56808687	0.07361615	0.2791	0.1352	-1.78899167774976	-1.08499766888889	1.49096742743363	0.0011464
2	72304266	rs10183844	0.3836458	0.9619	0.1572	-0.87119838516102	0.0463879933755274	1.4143533540404	0.00142897
2	72304347	rs112970851	0.05878812	0.2599	0.1092	-1.88977452117552	-1.12440838827839	1.60349909162996	0.00113103
2	72304528	rs10183910	0.6423255	0.4632	0.8784	-0.464449749328289	-0.733352124	-0.150937086507937	0.000893382
2	72304747	rs72904452	0.06803071	0.2785	0.1207	-1.82480333688463	-1.08099398745387	1.55295739115044	0.00113103
2	72305463	rs13406776	0.1008167	0.3558	0.1455	-1.64090697892276	-0.922505896678967	1.45587255221239	0.00113103
2	72305807	rs10187628	0.4632465	0.2338	0.7867	-0.733511549597164	-1.19063096190476	-0.273851537822581	0.000663666
2	72305934	rs10200160	0.6979727	0.1251	0.2216	-0.388058489914061	-1.53118018024691	-1.22036550808824	0.00295872
2	72306479	rs7601186	0.4571407	0.211	0.7433	-0.743563345078414	-1.25157918027211	-0.330515074677419	0.000650643
2	72306767	rs17665497	0.1862279	0.476	0.2256	-1.32182067730329	-0.711637716423358	1.20972540786026	0.00111568
2	72306971	rs7575648	0.553017	0.08782	0.2675	-0.593245166295065	-1.70837348571429	-1.10308595	0.00292287
2	72307781	rs4852847	0.1243432	0.3729	0.1824	-1.53679609922522	-0.890822967272727	1.33030860782609	0.00113103
2	72308674	rs11126361	0.94169	0.3575	0.3294	-0.0731457979533497	-0.917403204458599	-0.977491315151515	0.00230408
2	72309757	rs6737062	0.7229998	0.1462	0.2364	-0.354452476749453	-1.45655641111111	-1.18374224926471	0.00310566
2	72310763	rs17007729	0.6646171	0.6491	0.2199	-0.433547477934077	0.456401886307054	1.22411959502488	0.00147715
2	72311295	rs4852850	0.4205007	0.8862	0.2773	-0.805552799589766	-0.141127952409091	1.08688513641304	0.00189151
2	72311359	rs78235628	0.5446175	0.762	0.5601	0.605845200038886	0.302202795930233	-0.580826050859107	0.000771718
2	72311400	rs1010551	0.6798234	0.3209	0.5901	-0.412704076018076	-0.993073024324324	-0.5361928848	0.000483817
2	72312513	rs77151932	0.032212	0.1856	0.07956	-2.14176984680896	-1.32205889322034	1.75725739311741	0.000934121
2	72312682	rs77849249	0.3420392	0.1468	0.794	0.950143885590644	1.44997742160356	0.26082729733871	0.000306315
2	72313140	rs79587799	0.02927488	0.1804	0.07306	-2.17976500471384	-1.33999756802721	1.79368119676113	0.000934121
2	72313155	rs112619001	0.3191725	0.351	0.6587	-0.996159758814021	-0.931334513744076	0.440903598595506	0.000542097
2	72313631	rs75320950	0.03335652	0.1646	0.09749	-2.12776563440816	-1.38779460544218	1.65595106558704	0.000934121
2	72313886	rs112916437	0.03423884	0.1701	0.0966	-2.11724761422143	-1.37079240714286	1.65983720769231	0.000934121
2	72314641	rs11899565	0.3613108	0.12	0.6567	0.912870251888438	1.55381257688787	0.444743135082873	0.000306315
2	72314837	rs4852284	0.2322928	0.8823	0.09365	-1.1944735674558	-0.149669022024291	1.68103785217391	0.00125497
2	72315060	rs10200295	0.2379506	0.101	0.8991	1.18012471782333	1.64021244683258	0.128036584632153	0.000306315
2	72315712	rs4852852	0.02394698	0.1367	0.08154	-2.25797880125512	-1.48643317244898	1.74097232955466	0.000904311
2	72316385	rs11902394	0.02516208	0.1344	0.08936	-2.23890532010964	-1.49828130682594	1.69634872307692	0.000904311
2	72316479	rs11902358	0.02464688	0.1278	0.093	-2.24689270151537	-1.52575159658703	1.67615493319838	0.000904311
2	72316637	rs11902497	0.02671822	0.1397	0.09139	-2.21560994987223	-1.4779603894198	1.68431132995951	0.000904311
2	72317871	rs10210129	0.738346	0.1163	0.1874	-0.334044467704216	-1.56670622485549	-1.31749144797297	0.00357949
2	72318085	rs59317730	0.2886384	0.8901	0.1373	-1.06111336653307	-0.137480124251012	1.48795889613527	0.00125497
2	72318220	rs75586283	0.2881773	0.1071	0.7791	1.06212863266042	1.61117329123595	0.27904621897019	0.000306315
2	72318621	rs17007733	0.7503469	0.09426	0.1411	-0.318182019090214	-1.6744645122093	-1.46949962993197	0.00360062
2	72318964	rs9677147	0.2582594	0.0923	0.7962	1.13051469584646	1.68241499774775	0.258279538423913	0.000306315
2	72318969	rs74794698	0.04316132	0.1896	0.1136	-2.02214544339283	-1.31233782986111	1.5803733037037	0.000949074
2	72319034	rs17722207	0.0498624	0.2003	0.1276	-1.96114251444608	-1.28134034895833	1.52251394609054	0.000964059
2	72319253	rs10168803	0.7505645	0.1045	0.1593	-0.3178951312067	-1.6218306	-1.40835594285714	0.0036218
2	72319451	rs148951410	0.09519567	0.319	0.158	-1.66860508603106	-0.996862206539075	1.41320448378378	0.000225033
2	72319487	rs72904482	0.3408503	0.1292	0.7363	0.952486628548524	1.51580836454545	0.338021825824176	0.000319959
2	72319957	rs115970792	0.2345857	0.2448	0.63	-1.18862889225326	-1.1642165026694	0.481605298165138	0.000499887
2	72320113	rs10172066	0.8631877	0.1462	0.1514	-0.172317787875221	-1.45348312790698	-1.43544693265306	0.00366433
2	72320225	rs143779497	0.2593112	0.103	0.8426	1.12802078888939	1.62779579394619	0.197920490785908	0.000319959
2	72320853	rs7568849	0.7547947	0.324	0.4999	-0.312323449944756	-0.9867856	-0.674241527364341	0.00605108
2	72321264	rs186025928	0.6133977	0.5915	0.88	0.505229374824464	0.536629081357759	-0.151286825875	9.17332e-05
2	72323034	rs2215801	0.6398116	0.5745	0.9483	0.467962170499026	0.560506555675676	-0.0635174738730159	0.00735897
2	72324600	rs189289334	0.3382176	0.459	0.5433	-0.957692903840089	-0.739794798030942	0.608180428694158	0.000238512
2	72324681	rs9309461	0.2806627	0.3042	0.6465	1.07883186023722	1.02545869363057	-0.458538230225564	0.00553663
2	72324875	rs145106692	0.3781321	0.3227	0.8351	-0.881343181880421	-0.988874780313199	0.209089750612245	0.000542097
2	72324938	rs139037225	0.6022519	0.5746	0.881	0.521164812411532	0.561097360432767	-0.149114401207815	0.000292699
2	72324948	rs1400684	0.7591742	0.6865	0.9994	0.306565389506359	0.402815583624161	0	0.00710804
2	72325074	rs12613235	0.8203314	0.9463	0.6669	0.227118768021889	-0.0671100880487805	-0.428425128857143	0.0046819
2	72325404	rs10194900	0.6285126	0.8726	0.5788	0.483821366227454	0.160285546111111	-0.557939545362319	0.00490042
2	72325810	rs76627247	0.292904	0.4301	0.4872	-1.05177239717907	-0.788562243003413	0.69640515465587	0.000845069
2	72325863	rs7606711	0.5854522	0.5484	0.8934	0.545438025528484	0.601369918040541	-0.135035447619048	0.00732726
2	72326097	rs10174578	0.6642491	0.9208	0.5796	0.43405415938728	0.0980810652760736	-0.553925591798561	0.00487588
2	72326227	rs10174713	0.548855	0.4873	0.9113	0.599476722904886	0.691060770469799	-0.111188961587302	0.00710804
2	72326653	rs10198511	0.5471686	0.5007	0.8927	0.602008246201422	0.675664498513513	-0.135035447619048	0.00735897
2	72326692	rs10187549	0.5470888	0.5065	0.8782	0.602128173692766	0.66228411972973	-0.150937086507937	0.00735897
2	72327256	rs115079355	0.1502873	0.2348	0.4107	1.4385173248195	1.18811588167203	-0.822207478776291	0.000306315
2	72327683	rs13410633	0.9960257	0.998	0.9946	0.00498104773229969	0	-0.00769269233076923	0.00639089
2	72327768	rs141292985	0.889144	0.9241	0.9177	0.139387406953159	0.094325498548951	-0.104142819918367	0.000265551
2	72328144	rs12477050	0.9285261	0.9283	0.9752	-0.089699250051802	-0.091567380130719	0.0307630785615385	0.00656536
2	72328497	rs115698382	0.3074841	0.8606	0.1707	1.02051548008521	0.17582808251046	-1.36939113546798	0.000238512
2	72329362	rs56860991	0.5830283	0.7644	0.6221	0.548966649297644	0.298657637926829	-0.496674555179856	0.00482699
2	72329603	rs10208443	0.5118607	0.4577	0.8923	0.655943096859971	0.74484474295302	-0.135035447619048	0.00729565
2	72329685	rs10185019	0.508563	0.4562	0.8887	0.661076782717951	0.74484474295302	-0.142985868809524	0.00729565
2	72329838	rs10208630	0.9483391	0.9319	0.9992	-0.064792507064583	-0.0850225969281046	0	0.0064487
2	72329996	rs11689429	0.6164104	0.7942	0.6424	0.500944181004379	0.262240155609756	-0.464363310142857	0.0048514
2	72330200	rs77920418	0.0936059	0.3394	0.1403	-1.67667574927463	-0.955490667834395	1.47503362038462	0.000198158
2	72330334	rs11696009	0.4699378	0.4209	0.871	0.722580277766426	0.805217344295302	-0.166841912063492	0.00732726
2	72330712	rs75006501	0.3150679	0.4394	0.5232	-1.00464486478909	-0.774594127303754	0.63985624048583	0.000859832
2	72331116	rs10167320	0.5098517	0.4379	0.9208	0.659068557144524	0.778686626174497	-0.102428797874016	0.00729565
2	72331616	rs2420195	0.7624305	0.6585	0.9583	0.302290631542041	0.439955789759036	0.0492785291760563	0.00482699
2	72331940	rs141714604	0.06003138	0.1448	0.2337	-1.88056304616192	-1.45783283801296	1.19002865385714	0.000225033
2	72332246	rs80131756	0.1095081	0.0335	0.9605	1.60040797366586	2.12729081179245	0.0508017497457627	0.00033363
2	72333505	rs186903246	0.2638631	0.4481	0.4039	-1.11730695774635	-0.757618361952862	0.835426812449799	0.000845069
2	72333654	rs191443747	0.3088135	0.4547	0.4883	-1.01771493378404	-0.747372733788396	0.692425421052631	0.000845069
2	72333843	rs77393077	0.1376248	0.1002	0.7289	1.48469420484171	1.64410677021792	-0.345945676162791	0.000347329
2	72334091	rs140091351	0.8696311	0.7706	0.9365	0.164127101294111	0.291101695924309	0.0800324389215686	5.2262e-05
2	72334559	rs6716351	0.8739588	0.3528	0.3985	0.158632008759299	0.930468534810126	0.844793945185185	0.00545792
2	72334904	rs114816804	0.5317725	0.3972	0.9765	0.625302434874323	0.846531083994709	0.0294751130900621	0.000104943
2	72334996	rs4852854	0.3671797	0.5698	0.4661	-0.901768885264576	-0.566055919322034	0.728626587044534	0.000874627
2	72335284	rs148391065	0.3710508	0.7547	0.3078	0.894506780507262	0.311788121505376	-1.01928891151386	0.000279111
2	72335487	rs115224388	0.1182635	0.03842	0.9646	1.56210410251105	2.07062870047059	0.0451616204519774	0.00033363
2	72336196	rs75007247	0.168029	0.07621	0.9779	1.37856465606435	1.77365546253041	-0.0262508817259475	0.00033363
2	72336219	rs10166467	0.7575163	0.3051	0.4632	0.308744053268975	1.02519617531646	0.731477982985075	0.00569608
2	72336656	rs7575090	0.1728841	0.07619	0.999	1.36299502741546	1.77350572610837	0	0.00033363
2	72336974	rs7575536	0.1950349	0.08178	0.9504	1.29582753282094	1.73841843105134	0.0615190053372434	0.00033363
2	72337770	rs147777559	0.726656	0.3741	0.6194	0.349577212574078	0.889137010035211	0.496979397137014	0.000131442
2	72338203	rs10209307	0.9015426	0.4936	0.3164	-0.123712898674509	0.68745534125	0.999789596323529	0.00540582
2	72338649	rs55908542	0.7397199	0.871	0.4821	-0.332224358326708	0.159335584042553	0.699817380625	0.0033711
2	72339073	rs7585598	0.1818292	0.04429	0.7503	1.33514402952753	2.00940231124122	0.318567549162011	0.00033363
2	72339212	rs146347046	0.1975723	0.04456	0.6968	1.28849903952708	2.00703789672131	0.388349306424581	0.00033363
2	72339417	rs189060662	0.769505	0.3962	0.5907	0.293022488325759	0.848933776625659	0.536756620816327	0.000118179
2	72339430	rs114734862	0.3224876	0.4574	0.5129	-0.989358952131338	-0.744152655813954	0.652295339920949	0.000845069
2	72339432	rs115020949	0.3267971	0.4476	0.5329	-0.980585672284097	-0.757405603986711	0.622863813888889	0.000845069
2	72340133	rs148763035	0.7348053	0.8532	0.462	-0.338740396871782	0.185521519330784	0.733840964301552	0.000292699
2	72340293	rs12476747	0.01581353	0.01198	0.4325	-2.41319094799404	-2.51319793946731	0.784956148324022	0.164751
2	72340402	rs10203930	0.4218651	0.8839	0.2855	-0.803189762216308	-0.143885306347305	1.07069251690141	0.00473
2	72340493	rs10203870	0.7113409	0.9043	0.4764	-0.370055842015508	0.122853425080214	0.71279489125	0.0033917
2	72341155	rs1861025	0.550553	0.9862	0.345	-0.596931556689804	0.0180695788554217	0.943343704964539	0.00482699
2	72343098	rs62150070	0.7103217	0.8935	0.464	-0.371424049777374	0.135948997225131	0.734501614814815	0.00333004
2	72343437	rs80128564	0.6054005	0.4317	0.08201	0.516649903290153	-0.786707408917197	-1.73853607537879	0.000713591
2	72343827	rs76808625	0.2181277	0.0564	0.7187	1.23152212355756	1.9109700234192	0.359233474651811	0.000319959
2	72345643	rs1861023	0.8413358	0.6224	0.3715	-0.200185179366619	0.493779584761905	0.894297533802817	0.00423756
2	72345674	rs6546738	0.9192899	0.7128	0.551	-0.101328168118251	0.369546358128079	0.592896801162791	0.00256851
2	72345739	rs7589043	0.8702719	0.6079	0.3895	-0.163313196361104	0.512076714702381	0.858826316901408	0.00423756
2	72346235	rs116453105	0.2049962	0.05233	0.7345	1.26744504913615	1.93921344626168	0.339702888579387	0.00033363
2	72346484	rs77451590	0.08598776	0.09615	0.4935	-1.71695296704643	-1.66555257974277	0.684639408846154	0.00075714
2	72346553	rs74844908	0.8064139	0.4248	0.5823	0.24505498036083	0.797952257469244	0.551064055102041	0.000131442
2	72346982	rs78696834	0.08202591	0.09872	0.4632	-1.739050294865	-1.65268691607717	0.734480603461538	0.00075714
2	72347041	rs12477733	0.1035358	0.1196	0.5027	-1.62794862560706	-1.55857056168831	0.673132182101167	0.00075714
2	72347224	rs72845602	0.8555249	0.4376	0.2303	0.182073701632365	-0.776553681702128	-1.20150526146096	0.000542097
2	72347801	rs144288928	0.1143801	0.09459	0.6785	1.57880812712404	1.671978792	-0.414990001388889	0.000184761
2	72347860	rs2192332	0.6736575	0.7449	0.2988	-0.421133574128495	0.328941096832298	1.03640287591241	0.00525124
2	72347966	rs10209950	0.6770663	0.7413	0.3013	-0.416469667937414	0.328941096832298	1.02920615912409	0.00525124
2	72347970	rs148324385	0.1944698	0.04949	0.745	1.29746913712268	1.96486825807963	0.324090243854749	0.000319959
2	72348543	rs6546739	0.6463838	0.7817	0.3012	-0.458791609973102	0.279494436335404	1.03640287591241	0.00525124
2	72348697	rs6546740	0.6109382	0.8265	0.2965	-0.508734651436571	0.216287304135802	1.04359888321168	0.00522573
2	72348725	rs6546741	0.6475034	0.7913	0.3056	-0.457233165878838	0.265477688395062	1.02200873284672	0.00522573
2	72348883	rs6546742	0.8130038	0.6519	0.3698	-0.23655279603645	0.453619013043478	0.89810178540146	0.00522573
2	72349181	rs6546743	0.6476422	0.819	0.3309	-0.457040109063784	0.228588575555556	0.978089055474452	0.00514962
2	72350176	rs74997150	0.07786013	0.1126	0.3947	-1.76323934693686	-1.58885795598706	0.84927791003861	0.000771718
2	72351347	rs6721368	0.1237163	0.1178	0.5944	-1.5393603806101	-1.56392652065574	0.531138223046875	0.000786326
2	72351696	rs7584750	0.822656	0.4656	0.6038	0.224130228861462	0.731413077114428	0.517715056058824	0.00269995
2	72352119	rs2420199	0.089792	0.08532	0.5563	-1.6964959156562	-1.71707130065789	0.588872120948617	0.000786326
2	72352478	rs141169982	0.2188129	0.05207	0.6904	1.22969100059502	1.94138387775176	0.39825361281337	0.00033363
2	72352766	rs13411648	0.8137629	0.4718	0.6298	0.235574463055072	0.718521984422111	0.482144614497041	0.000388595
2	72353138	rs4852856	0.8348556	0.6301	0.3737	-0.208478281413847	0.479120093905326	0.894297533802817	0.00416942
2	72353573	rs2041666	0.5458775	0.2084	0.5798	0.603948981679157	1.25800296210526	0.5562671741875	0.00300884
2	72354740	rs116547657	0.8356937	0.7442	0.9464	-0.207404878097326	-0.327138411041667	-0.0670881283870968	0.000542097
2	72355470	rs79976551	0.1928043	0.1265	0.8395	-1.30232804382171	-1.52988034984227	0.202835282593985	0.000684709
2	72355518	rs7606254	0.2350828	0.2411	0.6494	-1.18736726527376	-1.17082078643216	0.455637670177515	0.00273792
2	72356195	rs887844	0.9060072	0.3769	0.2237	-0.118076286421909	0.883598911612903	1.21967435530303	0.00521015
2	72356303	rs7583202	0.5757753	0.9688	0.3453	0.559566270725709	-0.0394118305247813	-0.943709220909091	0.000279111
2	72356370	rs2420201	0.3467049	0.1302	0.7381	-0.940999989818738	-1.51499692053571	-0.334684155422535	0.000627308
2	72356449	rs707718	0.9157493	0.6403	0.4738	-0.105789551078654	0.470650050962567	0.71279489125	0.00326884
2	72356627	rs887842	0.1965966	0.03833	0.6596	1.29130902690749	2.07502260115607	0.439110590540541	0.00461023
2	72357336	rs61138718	0.07572905	0.01069	0.7886	1.77602345913733	2.55065566515152	0.26945272005988	0.00254992
2	72358275	rs10181341	0.01097715	0.001976	0.7861	2.54342543413787	3.09023637148014	-0.271543196077586	0.00123936
2	72358959	rs55707322	0.1413958	0.0408	0.8812	1.47061286759299	2.05007005979899	0.148623821369048	0.00251285
2	72359312	rs2241059	0.1197738	0.02767	0.8388	1.55572367205072	2.20712353888889	0.203844259520958	0.00258716
2	72359518	rs12478279	0.1964941	0.03174	0.5902	-1.29160458932689	-2.14573635742857	-0.537015858445946	0.00058457
2	72360795	rs6721986	0.3586529	0.1214	0.6783	-0.917934916973857	-1.54860117121212	-0.413518867266187	0.000641613
2	72361505	rs3768644	0.01585755	0.0004723	0.6786	2.41217774196811	3.50008773232759	0.415237414717949	0.00172297
2	72361699	rs3768643	0.1771918	0.02546	0.5834	-1.34945203672669	-2.23388679830986	-0.548016695348837	0.000556225
2	72361865	rs2241058	0.1181137	0.0267	0.8392	1.5627401761834	2.21623146281407	0.202630900833333	0.00249438
2	72361960	rs2241057	0.09407454	0.02201	0.9035	1.67428530251255	2.29602275102041	0.120361606204819	0.00258716
2	72362735	rs570357444	0.9728152	0.3476	0.2397	-0.0340776574926278	0.938625294162826	1.1742706412844	7.85498e-05
2	72363148	rs77927580	0.02089026	0.1655	0.05285	-2.30996198542642	-1.38661405666667	1.9353806445098	0.000402407
2	72363537	rs191064414	0.9639529	0.4577	0.4334	0.0451936546501577	0.743223589212329	0.783952309037328	0.000131442
2	72364335	rs75193861	0.2848099	0.568	0.3249	-1.06957666183779	-0.571287889312977	0.983370422913505	0.000238512
2	72365567	rs72908315	0.6619641	0.4812	0.869	0.437203010719075	0.70466816689038	0.164456842533693	0.000374812
2	72366166	rs72908317	0.9129988	0.7076	0.7777	0.10925673823814	0.375393684897025	0.280931817630854	0.000388595
2	72366863	rs142911153	0.7548049	0.8753	0.7655	0.312310020318821	0.157303754737733	-0.297414422355289	0.000238512
2	72368665	rs139298747	0.4763265	0.1194	0.5605	-0.712223265015571	-1.55647469816273	-0.581887024898512	0.000158048
2	72369348	rs3768639	0.07375818	0.006156	0.6284	1.78811050213628	2.7412613	0.482852660836502	0.000859832
2	72369555	rs3768638	0.03728591	0.004271	0.8705	2.0826195681636	2.85359922898089	0.163526180684411	0.000830337
2	72369839	rs114857151	0.3984022	0.5195	0.04342	0.844478201712707	-0.644178128850325	-2.01998268610422	0.000306315
2	72369876	rs10166057	0.05470349	0.002518	0.5287	1.92122382145624	3.02628460339623	0.629090731674208	0.00122378
2	72372029	rs531445698	0.06481789	0.2234	0.1588	-1.84651202617256	-1.21679381753555	1.40839702371542	0.134968
2	72372986	rs9309462	0.05116723	0.0035	0.6584	1.95007450777302	2.92099056447368	0.44124842734375	0.0009192
2	72377384	rs28503372	0.7460533	0.4762	0.1775	-0.32384778535901	0.712771397666068	1.34688050361702	0.000131442
2	72378898	rs62150093	0.03613113	0.004105	0.8806	2.09544858220615	2.86914186134185	0.15159020375	0.000800965
2	72379723	rs6546745	0.04078656	0.003381	0.7654	2.04569325076788	2.92579249193548	0.298831595095785	0.000800965
2	72380823	rs6546747	0.04306541	0.003142	0.7122	2.02307501572664	2.95476240809061	0.369374467038462	0.000815636
2	72381484	rs13407599	0.04819928	0.004438	0.7513	1.97560716807306	2.84738550422078	0.316460163088803	0.000830337
2	72381522	rs62150094	0.03470829	0.004306	0.9162	2.11174534478268	2.85628916485623	0.105512728377359	0.000800965
2	72382278	rs6738598	0.0365968	0.003158	0.7966	2.09023383026354	2.94846951516129	0.256610017164751	0.000815636
2	72382373	rs6710373	0.02990357	0.002834	0.8608	2.17136525974379	2.98707981897106	0.175549866221374	0.000815636
2	72382589	rs6738942	0.05221831	0.004136	0.6989	1.9413295838213	2.86395170097087	0.388416718461538	0.000830337
2	72382928	rs2901091	0.03465624	0.003101	0.8175	2.11235227712561	2.95494573774194	0.229959854252874	0.000815636
2	72383868	rs6546748	0.06056568	0.02223	0.8345	1.8766528871719	2.28742694444444	-0.207232720540541	0.00122378
2	72384327	rs7557210	0.06286892	0.0222	0.8558	1.8601173653334	2.28624630572519	-0.183784167085202	0.00122378
2	72385182	rs62150096	0.1255437	0.01036	0.5064	1.53191373948776	2.56358994757576	0.665390463309353	0.00075714
2	72385492	rs10202129	0.05404718	0.02388	0.7542	1.92645823736149	2.26070829808429	-0.315516853738739	0.00122378
2	72386287	rs114744664	0.9160414	0.8507	0.9509	0.105421329196391	0.188323235212766	0.0612049606122449	0.000158048
2	72387539	rs10174010	0.05851021	0.01999	0.8517	1.89185569771901	2.32204694621212	-0.187446546741071	0.00122378
2	72389334	rs975612	0.7646071	0.4286	0.6381	-0.299436375086156	-0.790416041216216	-0.47178842128	0.013802
2	72390460	rs12613322	0.4319751	0.7464	0.4021	0.785816378306889	0.322084294252874	-0.836413475510204	0.0265508
2	72392446	rs66872550	0.2055145	0.1468	0.8073	1.26599619297577	1.45163324771574	-0.245412390778443	0.000573554
2	72392754	rs10865390	0.4486833	0.7178	0.4591	0.757611965347014	0.364168355375723	-0.741440875510204	0.0265508
2	72392916	rs62150097	0.2139001	0.02422	0.4576	1.24291239453758	2.25087337125382	0.745398675636364	0.00075714
2	72393138	rs11126362	0.7904269	0.843	0.8609	0.265756354908534	0.197072959210526	-0.178499927364341	0.0188862
2	72393143	rs11681572	0.4595056	0.7619	0.4317	0.739661231142648	0.306124373352601	-0.782028878231293	0.0265508
2	72393355	rs60977474	0.6995383	0.8507	0.4126	0.385943782443071	-0.188826795922747	-0.818208215656566	6.25266e-05
2	72393424	rs34172703	0.6705897	0.8916	0.4137	0.425338759738188	-0.137128708025751	-0.818208215656566	6.25266e-05
2	72393799	rs11681809	0.568042	0.8267	0.5297	0.570937384065677	0.218549444425287	-0.626000732312925	0.0265508
2	72394028	rs1387	0.6707381	0.8811	0.4045	0.425135156168867	-0.150047393004292	-0.833096087373737	6.25266e-05
2	72394068	rs77198765	0.7813411	0.1453	0.1922	-0.277571779402031	-1.45397474068241	-1.30418651598746	0.000655949
2	72394674	rs17007906	0.2242924	0.03643	0.5503	1.21519321152642	2.09166713829114	0.597852491729323	0.000964059
2	72394749	rs194243	0.7790242	0.8193	0.8717	-0.280590930572879	-0.230006859013158	0.162620006356589	0.0188862
2	72394893	rs194242	0.7790027	0.8115	0.8752	-0.280619012125947	-0.236609178552632	0.154883927364341	0.0188862
2	72395464	rs72835204	0.6019052	0.5509	0.1339	0.521662698525606	-0.594969382481752	-1.49994956581197	1.06615e-06
2	72395722	rs67235968	0.6723264	0.8452	0.3797	0.422957257364617	-0.19397027262931	-0.878813872727273	6.25266e-05
2	72396566	rs194240	0.802324	0.8618	0.5571	0.250340649277418	-0.174429133806452	-0.590935131287879	0.0166191
2	72396597	rs194239	0.4270539	0.3838	0.846	0.794243047136318	0.87216077114094	-0.198661128412698	0.0110814
2	72397055	rs194238	0.7043689	0.7462	0.838	-0.37942954112868	-0.325820732928177	0.202300974313726	0.0242762
2	72399541	rs194236	0.7720706	0.9149	0.5631	0.28966762984103	-0.109770750967742	-0.575666505681818	0.0165147
2	72399614	rs61654086	0.2462899	0.2431	0.6898	-1.15940820276089	-1.1669223935397	0.398733892462312	0.000198158
2	72400178	rs75189672	0.7025456	0.1203	0.2091	-0.381886407051101	-1.55375694829396	-1.2561621796875	0.000613032
2	72400179	rs75915508	0.6792987	0.1195	0.2262	-0.413420281215456	-1.55904848503937	-1.20882243987539	0.000613032
2	72401702	rs57013742	0.2236447	0.03083	0.504	1.21689360547688	2.15644223312883	0.669079376363636	0.000728077
2	72401886	rs17723364	0.8707512	0.2295	0.238	-0.162704350544054	-1.20207313031088	-1.17902573518519	0.000598786
2	72402254	rs41420	0.896014	0.8258	0.9523	-0.130698247704248	-0.220882944033149	-0.0588500158954248	0.0238768
2	72402810	rs41419	0.8862255	0.8294	0.6351	0.143081870400145	-0.212607996774194	-0.473219484198473	0.0163082
2	72402994	rs41418	0.7683994	0.9374	0.5816	0.294469242742041	-0.0774658436774194	-0.545138483484849	0.0163082
2	72403848	rs41417	0.9122235	0.8736	0.9845	-0.11023433856432	-0.161345174833333	-0.0196107849019608	0.0238768
2	72404853	rs62150118	0.2413676	0.03162	0.4641	1.1715753297735	2.15074238092308	0.733456266423358	0.000742593
2	72405098	rs41415	0.9021486	0.8667	0.9969	-0.12294754506443	-0.166917167777778	-0.00653627452941177	0.0238768
2	72405665	rs17007922	0.6306234	0.8301	0.3181	0.480849487461023	-0.216558078917749	-0.994966886294416	5.71284e-05
2	72405833	rs41413	0.3616724	0.3278	0.7933	0.9121829673799	0.973443100671141	-0.261541583333333	0.011702
2	72406213	rs7587370	0.3599074	0.7914	0.2714	0.915541519148014	0.264987310361446	-1.09867118215962	2.2839e-06
2	72406358	rs144371530	0.5226892	0.129	0.4213	0.639205490056228	1.51696438109855	0.804993805353728	0.000104943
2	72407263	rs41412	0.7228278	0.91	0.4977	0.354682074472472	-0.109770750967742	-0.679349861603053	0.0163082
2	72407793	rs62150119	0.2285129	0.03489	0.5272	1.20419854961061	2.11100906820988	0.631368506569343	0.000742593
2	72409072	rs17007926	0.6143232	0.8588	0.3247	0.503912000397269	-0.177419347445887	-0.984614701015228	5.19309e-05
2	72409433	rs41410	0.337822	0.2793	0.8359	0.958477539678907	1.08051687852349	-0.206617926190476	0.011702
2	72409750	rs41409	0.9054926	0.8626	0.9835	-0.118725805408009	-0.172489719611111	-0.0196107849019608	0.0238768
2	72411003	rs41408	0.8760343	0.8337	0.9956	-0.155998410844526	-0.209790068950276	-0.00653627452941177	0.0240754
2	72411493	rs62150120	0.3745523	0.05984	0.3887	0.887978485757431	1.88393178840125	0.861981451865672	0.00075714
2	72413594	rs17007927	0.4509808	0.0852	0.3784	0.753780909602289	1.72329045503145	0.880211977153558	0.000771718
2	72414565	rs6705261	0.4462273	0.08332	0.3808	0.76171965527653	1.72900093021807	0.877298596654275	0.00075714
2	72414575	rs6705347	0.4462273	0.0833	0.3805	0.76171965527653	1.72900093021807	0.877298596654275	0.00075714
2	72415274	rs62150121	0.7865117	0.1567	0.2082	0.270843168761251	1.41558061635389	1.2610077343949	0.000430116
2	72415328	rs58339219	0.4467044	0.08341	0.3798	0.760920718835084	1.72954145345912	0.876553474906367	0.00075714
2	72415803	rs41407	0.8635067	0.9424	0.7301	0.17191199115175	-0.0710068028387097	-0.348527757272727	0.0168303
2	72416387	rs41406	0.4556698	0.3171	0.9793	0.745996060847206	0.999995852027027	0.0238059530952381	0.0118447
2	72416709	rs62150123	0.4438028	0.08033	0.3711	0.765787358540302	1.7515588827044	0.895208100374532	0.000771718
2	72417191	rs55813510	0.4423132	0.07978	0.3708	0.768292862258892	1.75483042830189	0.895208100374532	0.00075714
2	72417880	rs114337207	0.02178204	0.2093	0.0366	-2.29414718924275	-1.25610232843137	2.0901719112782	0.000211582
2	72418689	rs41403	0.8789381	0.8973	0.6988	0.152315502695122	-0.129161462645161	-0.386590770909091	0.0167243
2	72418724	rs17007929	0.425211	0.07468	0.3763	0.797413387978466	1.78541643880126	0.887192941729323	0.000771718
2	72419055	rs41402	0.4605751	0.3631	0.9439	0.73790020925379	0.905938533557047	-0.0714607335873016	0.0118447
2	72419303	rs41401	0.4636536	0.3661	0.9435	0.732843968921227	0.899316782550336	-0.0714607335873016	0.0117731
2	72419864	rs13339845	0.382269	0.09262	0.5175	0.873723169798896	1.68344487115987	0.64550362238806	0.00075714
2	72420204	rs41400	0.8984971	0.9265	0.7619	0.127560138840188	-0.0903858655483871	-0.302877370227273	0.0167243
2	72422160	rs41398	0.7756061	0.9708	0.6928	0.285049711225204	0.0386980691612903	-0.394205669090909	0.0165147
2	72422217	rs116218017	0.6245802	0.9328	0.5085	-0.489369349723005	-0.0845509453057554	0.660960282188841	0.000265551
2	72422386	rs41397	0.7793912	0.9691	0.6974	0.280112508006694	0.0386980691612903	-0.386590770909091	0.0167243
2	72423016	rs41396	0.7116145	0.4853	0.8046	0.369688693089524	0.697186629090909	0.250275309071429	0.015613
2	72423287	rs41395	0.487186	0.4063	0.9226	0.694791421367128	0.831350977027027	-0.0952952838888889	0.0117731
2	72424367	rs11685903	0.6213497	0.8527	0.3254	0.493938357049067	-0.186113785844156	-0.9794394	5.19309e-05
2	72424868	rs41394	0.9017886	0.7692	0.5944	0.123402118334488	-0.290329698387097	-0.534692683435114	0.0163082
2	72425292	rs41393	0.7797186	0.9285	0.5924	0.279685754419936	-0.0903858655483871	-0.53750839969697	0.0165147
2	72426686	rs41392	0.4776302	0.3717	0.9605	0.710119225292175	0.892058289189189	-0.047633339047619	0.0117731
2	72427119	rs6707549	0.2961709	0.04297	0.4315	1.04468003026421	2.021906498125	0.787160757089552	0.00075714
2	72427480	rs41391	0.8523697	0.9253	0.6893	0.186095737886942	-0.0962260337179487	-0.401821332727273	0.0168303
2	72428379	rs41389	0.9960438	0.6892	0.6322	0.00495837433283066	-0.399946789870968	-0.48090092740458	0.0163082
2	72428488	rs41388	0.874793	0.7965	0.586	0.157573373269445	-0.257934276580645	-0.549299845954198	0.0163082
2	72429239	rs10490039	0.3341941	0.05395	0.4269	0.965700371209643	1.92773708742138	0.794142556179775	0.000742593
2	72429650	rs41387	0.7453982	0.8008	0.8414	-0.324713198238674	-0.254174939005525	0.202300974313726	0.0244793
2	72429776	rs41386	0.6354647	0.7244	0.7534	-0.474049354928311	-0.3555799545	0.313625419084967	0.0244793
2	72430393	rs35583916	0.07743787	0.06645	0.5606	-1.76574954409878	-1.83548019381107	0.581332734579439	0.000184761
2	72430477	rs72835256	0.3318707	0.8529	0.2017	0.970352796919295	0.184715120281124	-1.27683073661972	1.20883e-06
2	72430843	rs112690380	0.143238	0.3188	0.2765	-1.46383872906205	-0.995988254082999	1.08760684162754	0.000158048
2	72430862	rs194235	0.5813568	0.8671	0.511	0.551403866052847	0.164268434144737	-0.658603792325581	0.013964
2	72430888	rs7597679	0.2324531	0.167	0.828	1.19406367727194	1.37973323333333	-0.217967243272727	0.000502451
2	72431682	rs7575087	0.8272352	0.9666	0.7737	0.218248920999171	0.04316132	-0.287265954055118	0.01405
2	72432759	rs17007937	0.3170259	0.02583	0.2773	1.00058836178516	2.2252278037037	1.08807409194139	0.000728077
2	72433199	rs13391463	0.6920729	0.9621	0.5759	0.396043562090177	0.0460365206776316	-0.557816122635659	0.01405
2	72433296	rs13417114	0.9860569	0.8997	0.9011	0.0174759276519846	0.126297904770115	0.121512293310811	0.0194059
2	72433660	rs2192012	0.5331314	0.06396	0.2196	0.623232912023616	1.8530213021875	1.22972743814815	0.000728077
2	72435343	rs55877105	0.7292259	0.9779	0.6152	0.346155452887344	0.0263105277171053	-0.503960181550388	0.013964
2	72436307	rs112941147	0.986068	0.8814	0.8366	-0.0174619859451887	0.149231370517241	0.202399255405405	0.0194059
2	72436502	rs141987304	0.07162375	0.206	0.1961	-1.80150225303848	-1.26510068558719	1.29343789937107	0.000361057
2	72436567	rs72910329	0.3675322	0.02842	0.2319	0.90110548966252	2.18773273323077	1.19694432189781	0.000728077
2	72436929	rs62147573	0.5401065	0.2015	0.5756	-0.612651825325796	-1.27861437731959	-0.557709743333333	0.0301703
2	72437501	rs17724205	0.5454023	0.2029	0.5716	-0.604663869650194	-1.27333054845361	-0.563826686424242	0.0301703
2	72437602	rs62147574	0.3645948	0.0277	0.2315	0.906644577436989	2.20005297507692	1.19646253381818	0.000728077
2	72438759	rs12466112	0.5533738	0.2049	0.5659	-0.592712103615371	-1.26804726134021	-0.576062425090909	0.0301703
2	72438883	rs55700162	0.4747505	0.9266	0.3213	0.714770977513874	0.0939138266239316	-0.990241365	3.75964e-05
2	72439951	rs58173605	0.4231964	0.03333	0.2029	0.800888162642899	2.12605741784615	1.27273749745455	0.000728077
2	72440035	rs11899672	0.6314593	0.9506	0.4179	0.479673827492057	-0.0601279363090129	-0.808989677889447	3.75964e-05
2	72440145	rs61391258	0.4096579	0.03131	0.2054	0.824495800135338	2.15074238092308	1.26536303781818	0.000728077
2	72440777	rs13423761	0.6197578	0.8603	0.5743	0.496193622522588	0.177392207105263	-0.557816122635659	0.013964
2	72441096	rs62147579	0.6771581	0.912	0.6083	0.416344232639921	0.111747147105263	-0.51176307248062	0.013964
2	72441356	rs62147580	0.3965486	0.028	0.2	0.847801403961381	2.19375021169231	1.28011046218182	0.000728077
2	72441476	rs62147581	0.3958152	0.02865	0.2033	0.849118842676658	2.18458025076923	1.27385824854015	0.000728077
2	72441720	rs7565922	0.6918469	0.9376	0.6043	0.396349967268276	0.0789000378289474	-0.519566748837209	0.0138785
2	72442093	rs13430254	0.4782528	0.1679	0.5965	-0.709115387704246	-1.38359496528497	-0.527134285030303	0.029897
2	72442324	rs13430651	0.4746966	0.1877	0.657	-0.714858325125682	-1.31455878402062	-0.442215468666667	0.029897
2	72444019	rs4852859	0.4532127	0.1701	0.6492	-0.750069675763458	-1.37116916494845	-0.454426677393939	0.029897
2	72444121	rs4852860	0.8919149	0.9799	0.8118	-0.135881547231629	0.0229839092701149	0.236746913986486	0.0191094
2	72444132	rs4852861	0.7709555	0.9729	0.6821	0.291125277241182	0.0328865159013158	-0.411166014883721	0.0138785
2	72446679	rs60872571	0.384356	0.8115	0.2885	0.869898202249752	0.236641163026316	-1.06168371076923	6.81205e-05
2	72446753	rs4852285	0.6076434	0.7202	0.7068	0.513440189308021	0.357312484569536	-0.372209985736434	0.0137093
2	72446925	rs115208530	0.1281351	0.6672	0.06325	-1.52149721520791	-0.430644316806723	1.8547109433584	0.00135663
2	72447285	rs62147586	0.3875859	0.03636	0.2564	0.864003693875569	2.09204164693252	1.13388253550725	0.000713591
2	72447789	rs6717899	0.3693527	0.7794	0.2898	0.897686499629068	0.279453256812227	-1.05644849794872	6.81205e-05
2	72447833	rs13404369	0.9300645	0.9275	0.8062	-0.0877635737220157	0.0918805381609196	0.243479702027027	0.0194059
2	72448427	rs72910350	0.435416	0.03942	0.2192	0.77995737227963	2.05850315230769	1.22530414036364	0.000728077
2	72449102	rs139218262	0.9917728	0.9038	0.8988	0.0103114815560387	0.120169295387597	0.126547600781609	0.000279111
2	72449443	rs10490040	0.4651295	0.0401	0.1952	0.73042657287378	2.05217132430769	1.29450099054545	0.000728077
2	72449468	rs62147587	0.4007067	0.03482	0.2335	0.840359828785217	2.11037379969325	1.19212752463768	0.000713591
2	72449484	rs62147588	0.4266524	0.0383	0.2242	0.79493310654802	2.07375175353846	1.21385768297101	0.000713591
2	72451262	rs62147589	0.4919472	0.1978	0.6484	-0.687214990066265	-1.2886551443299	-0.454426677393939	0.029897
2	72451299	rs66888584	0.8018915	0.96	0.655	0.250899997844075	-0.0509539557407407	-0.448281822459016	0.000141299
2	72451666	rs62147590	0.3992998	0.03331	0.2276	0.84287233976618	2.12583303650307	1.20649892753623	0.000713591
2	72453414	rs11126363	0.7383102	0.308	0.4969	-0.334091980791767	-1.01893483057325	-0.679200849925373	0.0174836
2	72453847	rs2041564	0.7715838	0.8118	0.8676	0.290303843070549	0.240233306	-0.165528196220472	0.0125863
2	72454146	rs7600833	0.4978581	0.8467	0.4	-0.677863611996208	-0.19256637427598	0.841384141014799	0.000265551
2	72454879	rs6724795	0.7224884	0.9872	0.5736	0.355135052611931	-0.0138269589400922	-0.565431180434783	0.00014891
2	72455057	rs1002415	0.3809401	0.03367	0.2501	0.87616553110463	2.12318578769231	1.15280489927273	0.000713591
2	72455337	rs2041563	0.8591415	0.8979	0.8993	0.177467111605133	0.126546485533333	-0.125100106796875	0.0172005
2	72456139	rs56299443	0.5195724	0.2001	0.6054	-0.644004583078842	-1.28337028608247	-0.514908419454545	0.029897
2	72456318	rs6760895	0.8710982	0.9107	0.9094	0.162263729720104	0.113237109066667	-0.11727547859375	0.0126631
2	72456348	rs55970539	0.5221437	0.1983	0.6004	-0.640044358420706	-1.28337028608247	-0.521021044	0.029897
2	72456543	rs72835275	0.4993717	0.7534	0.4991	-0.675478651561389	-0.313444602966102	0.6749242075	0.0484098
2	72457091	rs13395204	0.7794809	0.7913	0.907	0.279995637200641	0.2667987586	-0.118198907559055	0.0126631
2	72457217	rs59269913	0.3583959	0.03224	0.2682	0.918426048813088	2.14155959169231	1.10909478727273	0.000713591
2	72458949	rs7577860	0.8794409	0.8759	0.6748	0.151677948293693	-0.157211068009259	-0.418454659021739	0.00014891
2	72459305	rs56152907	0.3723593	0.03338	0.2581	0.892062684036676	2.12583303650307	1.13037080942029	0.000713591
2	72459614	rs62147598	0.3711898	0.03326	0.2583	0.894246961918841	2.12869500337423	1.13037080942029	0.000713591
2	72459825	rs13416674	0.9616827	0.868	0.9023	0.0480420240982602	0.166425466206897	0.121512293310811	0.0194059
2	72460604	rs6748607	0.756074	0.8007	0.8543	0.310640486732261	0.253517355533333	-0.18131094984252	0.0126631
2	72461309	rs77024759	0.3723593	0.03337	0.2583	0.892062684036676	2.12583303650307	1.13037080942029	0.000713591
2	72461630	rs7574693	0.8684376	0.4039	0.2161	0.165643446735712	-0.834034383794466	-1.23724101395349	5.38857e-06
2	72462925	rs74437940	0.3450667	0.986	0.1347	-0.944201575176294	0.0184409655553506	1.4943936192053	0.000184761
2	72463898	rs62147601	0.3956973	0.03031	0.2126	0.849330636921827	2.16808538165138	1.24541662129964	0.000713591
2	72464241	rs1159766	0.7409727	0.3235	0.5159	-0.330565575611167	-0.987229238853503	-0.653963586691729	0.0174836
2	72464294	rs1159765	0.7484171	0.3261	0.5117	-0.320727241925932	-0.980760648407643	-0.661548447819549	0.0174836
2	72464426	rs1159763	0.7633527	0.3295	0.4973	-0.301081068670258	-0.974292715286624	-0.684307623233083	0.0174836
2	72465331	rs13418637	0.7667644	0.3356	0.502	-0.296609841829763	-0.962005450955414	-0.67672046593985	0.0174836
2	72465814	rs114573218	0.9157481	0.5584	0.4109	0.105791074424739	-0.58571506147343	-0.821227335607094	0.000104943
2	72466113	rs13382986	0.5298815	0.2099	0.6138	-0.628186887450486	-1.25272878969072	-0.503296131151515	0.029897
2	72466296	rs62147622	0.3739599	0.02973	0.2337	0.889080270622418	2.17435210489297	1.19131690469314	0.000713591
2	72466465	rs68172337	0.8903742	0.8624	0.6788	0.137830726982781	-0.171149298333333	-0.415234856557377	0.000172604
2	72467134	rs62147623	0.3587746	0.02858	0.2417	0.917702553735345	2.19330434631902	1.17038432536232	0.000713591
2	72467878	rs75452542	0.2450986	0.05204	0.688	-1.16233702867346	-1.94379265926893	-0.402339805563481	0.000118179
2	72468135	rs59421152	0.4794793	0.8261	0.3933	-0.707140199848012	-0.219205339726027	0.853751202542373	0.000265551
2	72468627	rs72835276	0.876689	0.889	0.6855	0.155167796813085	-0.139097639814815	-0.404223640983607	0.00014891
2	72468750	rs141366446	0.197808	0.2142	0.5973	-1.28782191648265	-1.24307075061162	0.527737891234347	0.000252017
2	72468974	rs10196589	0.7558851	0.3295	0.5065	-0.310888914801675	-0.974292715286624	-0.669134074210526	0.0174836
2	72470995	rs61448485	0.8487799	0.907	0.6652	0.190675458190529	-0.115885658240741	-0.431755841311475	0.000156667
2	72471323	rs7565358	0.8487799	0.907	0.6672	0.190675458190529	-0.115885658240741	-0.431755841311475	0.000156667
2	72471378	rs62147624	0.3840996	0.02768	0.2091	0.87036758986192	2.20481286972477	1.25622684259928	0.000699135
2	72471453	rs62147625	0.3918196	0.02643	0.194	0.856322204916939	2.22330226972477	1.29978363285199	0.000699135
2	72471732	rs7592404	0.8515703	0.9087	0.6705	0.187115283461697	-0.115885658240741	-0.426248291420765	0.000164566
2	72471769	rs2080044	0.5196955	0.2055	0.6201	-0.643814731357696	-1.26804726134021	-0.497185294	0.029897
2	72474578	rs56178437	0.7192749	0.953	0.63	0.359428001780193	0.0601460987037037	-0.48366756451087	0.00014891
2	72475801	rs76307828	0.2443249	0.2559	0.6478	-1.1642445333909	-1.13627599415855	0.457896063471074	0.000198158
2	72476225	rs768042	0.795139	0.7948	0.9248	0.25964325155859	0.2601583878	-0.0945449273228346	0.0126631
2	72476263	rs768043	0.7794594	0.7941	0.9031	0.280023604570295	0.2601583878	-0.126085147007874	0.0126631
2	72478909	rs10221767	0.4917816	0.2004	0.6559	-0.687477834285108	-1.27861437731959	-0.442215468666667	0.029897
2	72479907	rs72835277	0.4223617	0.5866	0.5474	-0.802330620631541	-0.542050322895623	0.602288393975904	0.0853463
2	72480246	rs62147626	0.4870204	0.1993	0.661	-0.695055705436971	-1.28337028608247	-0.436110786787879	0.029897
2	72480428	rs13389524	0.4819887	0.1954	0.6631	-0.703107552321893	-1.2939405443299	-0.436110786787879	0.029897
2	72480536	rs10171231	0.3020225	0.01964	0.246	1.03210596750708	2.33015453703704	1.15701221642336	0.000728077
2	72480543	rs11682749	0.7219896	0.9464	0.6419	0.355800974883042	0.0693924131481481	-0.467219957934783	0.000156667
2	72481268	rs142097042	0.6871091	0.8613	0.4015	-0.402781247237043	0.174894146209913	0.837685434380454	0.000225033
2	72482823	rs6709493	0.879495	0.8878	0.6911	0.151609415273698	-0.139097639814815	-0.398718865191257	0.000156667
2	72483329	rs10193543	0.4724314	0.195	0.68	-0.718528554834254	-1.2939405443299	-0.412308401212121	0.029897
2	72483919	rs10205108	0.7670725	0.3265	0.4861	-0.296206389002489	-0.980760648407643	-0.699484235037594	0.0173726
2	72484043	rs10181899	0.4870204	0.199	0.6641	-0.695055705436971	-1.28337028608247	-0.436110786787879	0.0296272
2	72485039	rs17007984	0.7619542	0.9939	0.6471	0.302915625820442	0.00925833345833333	-0.456257651521739	0.000156667
2	72485205	rs62147627	0.3722256	0.02801	0.2233	0.892312151989867	2.19525403902439	1.21645717906137	0.000728077
2	72485767	rs61037557	0.9044141	0.8479	0.682	0.120087113711962	-0.189740135462963	-0.409728971420765	0.000156667
2	72485881	rs55764675	0.4773827	0.2091	0.703	-0.710518319672747	-1.25748231082474	-0.381806190848485	0.029897
2	72486342	rs6740982	0.7619542	0.9916	0.6471	0.302915625820442	0.00925833345833333	-0.456257651521739	0.000156667
2	72486539	rs112227464	0.9802952	0.1962	0.137	-0.0246987232585534	-1.29290693200993	-1.48534151725146	0.000556225
2	72486812	rs17724860	0.4725214	0.199	0.6898	-0.718382565912336	-1.28337028608247	-0.400105674848485	0.0301703
2	72486843	rs6546752	0.730627	0.3136	0.5143	-0.344291613254349	-1.00663895159236	-0.64908326141791	0.0174836
2	72487364	rs17673916	0.4651084	0.1941	0.6887	-0.730460955256119	-1.29922648659794	-0.400105674848485	0.0301703
2	72488912	rs62147629	0.4532279	0.1896	0.6979	-0.750044530700843	-1.31455878402062	-0.387905404909091	0.0301703
2	72489047	rs62147630	0.3505908	0.02891	0.2553	0.933443917161343	2.18659699357798	1.13713599494585	0.000728077
2	72490319	rs6546753	0.8036225	0.8008	0.9294	0.248661657526514	0.253517355533333	-0.0859848003125	0.0125863
2	72491066	rs6729219	0.8958368	0.9038	0.7298	0.130922283907225	-0.121087714883721	-0.344251483551913	0.000172604
2	72491308	rs17007994	0.5743596	0.9738	0.3919	-0.561642438087524	-0.0325651933219178	0.855340462553192	0.000265551
2	72491466	rs13392314	0.4532607	0.1991	0.7245	-0.749990088669864	-1.28337028608247	-0.351319324060606	0.0301703
2	72491508	rs112587221	0.8515408	0.8993	0.6624	0.187152907412725	-0.125169054351852	-0.437263946393443	0.000156667
2	72491985	rs112054620	0.8570989	0.8915	0.6629	0.180068402422101	-0.134454312361111	-0.437263946393443	0.000156667
2	72495076	rs6546754	0.7457272	0.9981	0.6196	0.324278563728677	0.00462939816342593	-0.494635401576087	0.000156667
2	72495577	rs6546755	0.7723354	0.8047	0.8783	0.289321465154389	0.2468756616	-0.156406458671875	0.0125863
2	72495697	rs61450122	0.3434496	0.02716	0.2518	0.947371409441636	2.21107207217125	1.14448139819495	0.000728077
2	72496083	rs1003672	0.7200248	0.3162	0.5321	-0.3584257164287	-1.00016839044586	-0.619730310746269	0.0174836
2	72496299	rs1123199	0.5096049	0.2204	0.6776	-0.65945293264809	-1.22157766907216	-0.418410685878788	0.029897
2	72497178	rs141254156	0.3860023	0.1012	0.5968	-0.866890010442198	-1.63856303771131	-0.529724572423803	0.000104943
2	72497735	rs116421751	0.6771593	0.8586	0.6587	-0.416342582823432	-0.178091190686275	0.441501385080645	0.000252017
2	72498920	rs17725024	0.3829785	0.1947	0.8612	-0.872421368046706	-1.29533211398964	-0.1770861675	0.0296272
2	72499378	rs62147636	0.458155	0.1844	0.6807	-0.741888252038744	-1.32460655618557	-0.412308401212121	0.0301703
2	72499725	rs2109963	0.718788	0.7423	0.862	0.360079077484472	0.3265323508	-0.172064340234375	0.0126631
2	72500375	rs6719255	0.4554455	0.2003	0.7262	-0.746367296074689	-1.27861437731959	-0.351319324060606	0.029897
2	72500694	rs56143801	0.3657424	0.2103	0.9403	-0.904477313973317	-1.2523413549505	-0.075630565872093	0.0247833
2	72500816	rs10209861	0.6625482	0.6872	0.8393	0.436397716259454	0.4001301464	-0.20338952109375	0.0127404
2	72501106	rs72835299	0.1524318	0.517	0.1461	-1.43099463010658	-0.648160901162791	1.45313859688581	0.00125497
2	72501137	rs2192015	0.9505841	0.7692	0.6612	0.0619731959393108	-0.292464520612245	-0.43960562256	0.00946749
2	72501537	rs12463825	0.3787009	0.1887	0.8502	-0.880292497935436	-1.31605505854922	-0.189317984939024	0.0293611
2	72501773	rs13409641	0.4370413	0.1741	0.6912	-0.777199050125009	-1.36058305979381	-0.400105674848485	0.029897
2	72501904	rs17008015	0.2549354	0.09428	0.8303	1.13844341967457	1.67172283544974	0.212762445875	0.000698365
2	72502270	rs10192800	0.6773632	0.6916	0.8651	0.416063937710596	0.4001301464	-0.172064340234375	0.0126631
2	72502993	rs4852286	0.4857559	0.094	0.3739	-0.697074946636151	-1.67336501554404	-0.884606382424242	0.0293611
2	72503373	rs4852287	0.9418441	0.5307	0.3985	0.072952146107204	-0.6240664	-0.843555684328358	0.0175954
2	72503643	rs56302716	0.699675	0.448	0.1368	0.385759232317114	-0.76100690438247	-1.49297242018779	9.69838e-06
2	72504516	rs6742264	0.9264085	0.5265	0.3765	0.0923643360668293	-0.630498864904459	-0.887168362406015	0.0175954
2	72504650	rs145340041	0.1308698	0.7862	0.04288	-1.51068093390609	-0.271352055766621	2.02582244588045	0.000347329
2	72504809	rs6546756	0.9803823	0.4583	0.3642	0.0245895853478453	-0.73866151910828	-0.909995945112782	0.0175954
2	72504873	rs2420442	0.9264233	0.5356	0.3829	0.0923456654666705	-0.617634584649682	-0.871953823308271	0.0175954
2	72505243	rs2901144	0.9264085	0.526	0.3771	0.0923643360668293	-0.630498864904459	-0.887168362406015	0.0175954
2	72505475	rs4852288	0.9420291	0.5147	0.3806	0.0727196926368888	-0.649800157961784	-0.879560707518797	0.0175954
2	72506035	rs11694921	0.6523529	0.6726	0.2346	0.450495834064055	-0.421535286792453	-1.19251071037037	0.0186422
2	72506138	rs11690734	0.6523529	0.6734	0.2344	0.450495834064055	-0.421535286792453	-1.19251071037037	0.0186422
2	72506938	rs6722637	0.6731386	0.6639	0.2449	0.421844310164718	-0.43419976836478	-1.16315879481481	0.0185222
2	72507502	rs10168145	0.7117827	0.7028	0.3071	0.369462917963596	-0.383557135974843	-1.02258148	0.0184031
2	72507640	rs10204415	0.4795088	0.2231	0.7347	-0.707092808197782	-1.21782741917098	-0.341196729085366	0.0301703
2	72507795	rs72837105	0.5049208	0.4516	0.8858	-0.666767156441297	-0.750962450988142	0.144635743317757	0.00242095
2	72508332	rs6729863	0.6555821	0.6832	0.2431	0.446020912425789	-0.408873354842767	-1.17068381777778	0.0186422
2	72508467	rs6758462	0.6624122	0.6514	0.2288	0.436585145123977	-0.452567797610063	-1.20756748740741	0.0186422
2	72508787	rs76603235	0.4498575	0.9058	0.3052	-0.755652632159186	-0.118808485381232	1.02578679672978	0.000211582
2	72509115	rs7583271	0.6454434	0.6897	0.2383	0.46010141661112	-0.402543344716981	-1.18498346962963	0.0186422
2	72510368	rs6753073	0.6510096	0.7373	0.2739	0.452359988927251	-0.333615954259259	-1.09503422773723	0.0186422
2	72511401	rs187915345	0.1488798	0.09275	0.7994	-1.44349961495832	-1.682371475	0.254294477835052	0.000225033
2	72511690	rs62149273	0.4302751	0.167	0.6824	-0.788720935755508	-1.38468079487179	-0.409824615662651	0.0310125
2	72513375	rs2109961	0.6566104	0.6365	0.2147	0.444597763081627	-0.471574853899371	-1.23531902058824	0.0186422
2	72513414	rs2109960	0.5260117	0.1914	0.5757	-0.634105912420712	-1.30255705794872	-0.557709743333333	0.0310125
2	72514421	rs60975798	0.2106974	0.5093	0.2484	1.25165022229835	0.660659956387665	-1.15527124352332	0.000105532
2	72514758	rs6733210	0.637397	0.708	0.2407	0.471341262258008	-0.37487198775	-1.16879922132353	0.0187632
2	72514837	rs12466613	0.6647272	0.6771	0.2462	0.433395850438474	-0.4126089771875	-1.15460615661765	0.0187632
2	72516353	rs719117	0.5234367	0.192	0.5827	-0.638056705394186	-1.30255705794872	-0.551593417515151	0.030728
2	72516421	rs719120	0.1793873	0.5136	0.1912	1.34264396162809	0.651979674449339	-1.30595823005181	9.88598e-05
2	72516574	rs719119	0.2143736	0.5467	0.2264	1.24162864707932	0.603338463876652	-1.20721936010363	9.88598e-05
2	72516703	rs719118	0.6409317	0.6703	0.2215	0.466396499239327	-0.42519303875	-1.22036550808824	0.0187632
2	72518207	rs58035683	0.242974	0.5936	0.2411	1.16758563366136	0.535245174778761	-1.17116819740933	9.88598e-05
2	72518487	rs13432350	0.6409317	0.6689	0.2228	0.466396499239327	-0.42519303875	-1.22036550808824	0.0187632
2	72518970	rs7559131	0.7129146	0.6873	0.2998	0.367944470689676	-0.402543344716981	-1.03668561617647	0.0184031
2	72519723	rs6711257	0.5985216	0.3477	0.7674	-0.526527685619524	-0.939090151269036	-0.29353264491018	0.030728
2	72519728	rs6711265	0.6283043	0.7813	0.2824	0.484114817922151	-0.2812568953125	-1.07280881459854	0.0187632
2	72519802	rs62149275	0.844163	0.9457	0.8239	-0.196571347221788	-0.069620929	0.222836194404145	0.0484098
2	72520445	rs17008043	0.2621959	0.2647	0.6772	-1.12121609703781	-1.11370575687204	0.415809033459357	0.000388595
2	72521819	rs144356762	0.8951482	0.9414	0.9059	-0.131792795256353	-0.0729091346434231	0.118560910936902	0.000319959
2	72522769	rs13409513	0.9703243	0.6803	0.5868	0.0372014935606638	-0.411643377256637	-0.544708571727749	0.0507845
2	72523018	rs12467816	0.2886501	0.5285	0.3691	-1.06108764049245	-0.629175301186944	0.898496017132867	0.0886968
2	72523949	rs7577877	0.5634115	0.6885	0.1719	0.577781668772979	-0.402555985804598	-1.36504779189189	0.0269383
2	72524299	rs12471875	0.8767928	0.7798	0.5669	0.15503621639715	-0.277524323744493	-0.570637741884817	0.0507845
2	72524450	rs12468057	0.5543603	0.6848	0.1632	0.591238852603803	-0.407764992873563	-1.3919422777027	0.0269383
2	72526321	rs7580952	0.5397826	0.6848	0.1541	0.613141644265313	-0.407764992873563	-1.42574796689189	0.0269383
2	72526931	rs6546757	0.9460926	0.677	0.5489	0.0676142553871666	-0.416109737831858	-0.597109322513089	0.0507845
2	72527039	rs6731988	0.4948808	0.8287	0.1909	0.68256644807707	-0.216813118	-1.30898935441176	6.25266e-05
2	72527174	rs7584538	0.9516091	0.6734	0.5542	0.0606861217079381	-0.420872529517544	-0.593999378125	0.0507845
2	72527533	rs117717121	0.8275935	0.3104	0.4067	-0.217789025160658	-1.01374237575758	-0.82974474511041	0.000949074
2	72528084	rs57730885	0.5710876	0.7549	0.2148	0.566450371621171	-0.31372553041841	-1.24006349852941	6.25266e-05
2	72528356	rs140828090	0.6015054	0.7639	0.6491	0.522236839205293	0.300686226858108	-0.455264124796748	0.000292699
2	72529188	rs57270251	0.5170888	0.6966	0.1442	0.647839316277352	-0.390982104597701	-1.45957057837838	0.0269383
2	72531611	rs6723136	0.5812845	0.7045	0.195	0.551509422190997	-0.380807171087866	-1.30026164334975	6.25266e-05
2	72531822	rs6738521	0.5907942	0.699	0.1992	0.537685364228386	-0.385029739121339	-1.2792940745098	6.25266e-05
2	72531858	rs6723380	0.5040241	0.7836	0.1766	0.668171559783318	-0.276223583054393	-1.35281015637255	5.71284e-05
2	72532204	rs34236294	0.02496648	0.005261	0.8228	-2.24192091229355	-2.7915637340591	0.223968694532628	0.000211582
2	72533108	rs144127556	0.2939578	0.1056	0.8421	-1.04947884483437	-1.61886548984468	-0.198966611681643	0.00469221
2	72533679	rs11903453	0.4939987	0.8264	0.1899	0.683962745111992	-0.221926426443515	-1.313520725	6.81205e-05
2	72533963	rs9309464	0.5851734	0.5858	0.1395	0.545843624653801	-0.543588443641619	-1.4827083244898	0.0265508
2	72534325	rs10181651	0.9620474	0.6575	0.551	0.0475843618870589	-0.442470445929204	-0.600252003157895	0.0507845
2	72534469	rs10194216	0.5515479	0.6707	0.155	0.595442126416604	-0.425131760344828	-1.41884747297297	0.0269383
2	72535478	rs9309465	0.5833056	0.7018	0.1968	0.548562675735485	-0.380807171087866	-1.29570977438424	6.25266e-05
2	72535690	rs7595180	0.6329809	0.5288	0.1394	0.477535338900546	-0.633673306395349	-1.47645125442177	0.0256152
2	72535950	rs7569059	0.4817757	0.8513	0.1922	0.703449332857956	-0.187504596875	-1.3026040404878	6.25266e-05
2	72537018	rs6737565	0.5544991	0.6655	0.1555	0.591031680953328	-0.430921849252874	-1.41884747297297	0.0269383
2	72540123	rs6546760	0.6516406	0.7044	0.2502	0.451484151071251	-0.381424105911602	-1.15059123856209	0.0287837
2	72541646	rs17008057	0.4839371	0.8234	0.1818	0.699984227929671	-0.221926426443515	-1.33819886960784	6.25266e-05
2	72543925	rs56153402	0.2316112	0.7345	0.02501	1.196218746191	-0.339564972878229	-2.24236732597403	3.55104e-07
2	72544130	rs10173381	0.5057795	0.6867	0.1327	0.665423736867673	-0.402555985804598	-1.50031824256757	0.0269383
2	72544670	rs183960702	0.9385714	0.4157	0.4094	-0.0770654799067505	-0.814718935559265	-0.82430028050193	0.000118179
2	72545608	rs115408606	0.3728886	0.6779	0.3765	0.89107563768742	0.414943370841487	-0.882369623303167	0.00283924
2	72545678	rs6752122	0.531243	0.6832	0.1479	0.626109684885502	-0.407764992873563	-1.44576338581081	0.0269383
2	72546167	rs55714718	0.4899266	0.7834	0.1654	0.690425460699704	-0.276223583054393	-1.38708819411765	6.25266e-05
2	72547147	rs144770548	0.7768209	0.6574	0.9296	0.283464383654077	0.44351794738292	0.0889888299669967	0.000713591
2	72547252	rs147899025	0.7001888	0.6915	0.9004	0.385065633349124	0.397295155723906	-0.124983371834677	0.000279111
2	72548174	rs6546761	0.4878707	0.7823	0.1639	0.693699406205422	-0.276223583054393	-1.39213110392157	6.25266e-05
2	72548702	rs6546763	0.4819859	0.83	0.1823	0.703111965522048	-0.213514568033473	-1.33316150441176	6.25266e-05
2	72548895	rs7558919	0.4864059	0.7061	0.1277	0.696036512988531	-0.379410553735632	-1.52035576689189	0.0269383
2	72550565	rs148235879	0.3558381	0.6187	0.3979	-0.923324533528851	-0.498430529392971	0.844486496737044	0.000444013
2	72552935	rs6546764	0.4836507	0.7091	0.1272	0.7004430071219	-0.37362565183908	-1.52035576689189	0.0267436
2	72553208	rs145349571	0.3443414	0.1593	0.8599	-0.945622115753187	-1.40738000074766	-0.176042003240343	0.000292699
2	72553263	rs59095814	0.8658496	0.7469	0.5201	0.168932660952087	-0.322856426238938	-0.643731837172775	0.0507845
2	72553840	rs6727580	0.4849414	0.8516	0.1948	0.698377101000841	-0.187504596875	-1.29892114264706	6.25266e-05
2	72554331	rs11680197	0.4730834	0.8569	0.1889	0.717471123785633	-0.179134518875	-1.31855607205882	6.25266e-05
2	72557963	rs142893753	0.438656	0.6357	0.08945	0.774464759542831	-0.473805449212598	-1.69759066666667	0.000158048
2	72558818	rs11890482	0.5039807	0.7777	0.1742	0.668239537308737	-0.280435609205021	-1.35784954117647	6.25266e-05
2	72558981	rs62149279	0.4624548	0.03358	0.1683	0.734810617932523	2.12802303081395	1.37784641099656	0.000742593
2	72559117	rs11891573	0.5039373	0.7743	0.1723	0.668307528836886	-0.284648059414226	-1.36288944411765	6.25266e-05
2	72560667	rs75240917	0.8871899	0.0663	0.04671	0.141860890363582	1.83740720909091	1.99126415216138	0.000361057
2	72560841	rs11903912	0.499877	0.8156	0.1889	0.674683238780425	-0.2341266258159	-1.313520725	6.81205e-05
2	72565272	rs113026106	0.1496514	0.3578	0.2539	-1.44076397754873	-0.920015305242464	1.14113826027607	0.000158048
2	72566546	rs2420445	0.848104	0.6491	0.8066	0.191538139020982	0.45506359953917	0.244514074587912	0.000171391
2	72566891	rs11894521	0.5009626	0.7611	0.1627	0.672975909844005	-0.305295198033473	-1.39898889261084	6.25266e-05
2	72566956	rs17008077	0.4076694	0.9663	0.1709	-0.828001989369794	0.0427294937611408	1.37088693664459	0.000265551
2	72568147	rs58582296	0.4856929	0.8186	0.1795	0.697175538719813	-0.229919258661088	-1.34323675245098	6.81205e-05
2	72568854	rs144322474	0.1922319	0.07202	0.9459	-1.30400508373548	-1.79799542776999	-0.0684590517993631	0.000118179
2	72570709	rs62149282	0.8119248	0.8147	0.5196	0.237943702357347	-0.232633403157895	-0.645652101041667	0.051408
2	72572214	rs7594350	0.4808596	0.7069	0.1263	0.704920577038701	-0.37362565183908	-1.52726663581081	0.0273338
2	72572908	rs7595315	0.4864059	0.7039	0.1285	0.696036512988531	-0.379410553735632	-1.52035576689189	0.0273338
2	72573205	rs7559116	0.5857949	0.6699	0.181	0.544939768614868	-0.425077603333333	-1.33668437804878	5.19309e-05
2	72573212	rs7571483	0.5706134	0.719	0.1968	0.567148282074125	-0.35820196775	-1.29258494195122	5.19309e-05
2	72574875	rs62149283	0.5424396	0.5479	0.8269	-0.609127976600276	-0.601162094146341	0.218077108688784	0.000118179
2	72575107	rs17008082	0.577106	0.7091	0.1957	0.557616856080291	-0.375015924875	-1.29759423414634	5.19309e-05
2	72575328	rs13383535	0.7488629	0.8431	0.4641	0.320139076529586	-0.198242745594714	-0.732853907853403	0.0507845
2	72575589	rs17559539	0.3708276	0.2019	0.9092	-0.894924204732786	-1.27489134020833	-0.114659330707317	0.00037379
2	72577226	rs7607353	0.5812926	0.6857	0.1861	0.551497593978084	-0.404035957458333	-1.32214720439024	5.19309e-05
2	72579620	rs72841783	0.3488155	0.6491	0.04824	0.936889234906441	-0.453293860299625	-1.97356868114035	6.84928e-08
2	72581576	rs10186080	0.7059119	0.8983	0.4616	0.377352198724329	-0.127938905154185	-0.738163580104712	0.0507845
2	72582796	rs6707920	0.5991198	0.6386	0.1729	0.525666605188343	-0.470985257083333	-1.3607554302439	5.19309e-05
2	72583630	rs72841784	0.2602825	0.6885	0.02763	1.12572363019549	-0.399929262962963	-2.19907705151515	3.55104e-07
2	72583946	rs116223830	0.3599316	0.5709	0.03482	-0.915495506782366	0.565866702231237	2.11218598926829	0.000306315
2	72584121	rs13390754	0.4463026	0.7222	0.1108	0.761593607109282	-0.356274439252874	-1.59433877432432	0.0273338
2	72584457	rs6746583	0.5900581	0.6527	0.1738	0.538751825443347	-0.449920420833333	-1.35624120292683	4.21592e-05
2	72584465	rs6746586	0.5900581	0.6528	0.1738	0.538751825443347	-0.449920420833333	-1.35624120292683	4.21592e-05
2	72584886	rs598547	0.7106947	0.8604	0.4309	0.370923272749378	-0.176122523656388	-0.78544339895288	0.0507845
2	72584921	rs598496	0.4487146	0.723	0.1118	0.757559772066523	-0.356274439252874	-1.58811278310811	0.0273338
2	72584959	rs66920016	0.5988162	0.6508	0.1792	0.526103569763692	-0.45413253625	-1.34169820097561	5.19309e-05
2	72584972	rs145748665	0.1426694	0.09956	0.6939	-1.46592268067003	-1.64785911295681	0.39318394235706	7.85498e-05
2	72584975	rs598138	0.4487146	0.7202	0.1116	0.757559772066523	-0.356274439252874	-1.58811278310811	0.0273338
2	72585221	rs6735400	0.5880363	0.6523	0.1735	0.541683752210414	-0.449920420833333	-1.3607554302439	5.19309e-05
2	72585768	rs636319	0.6933664	0.913	0.4585	0.394290775871437	-0.110270053656388	-0.743473790575916	0.0507845
2	72586848	rs6711442	0.5793545	0.6735	0.177	0.554327777677838	-0.420868424166667	-1.34621108243902	5.19309e-05
2	72588021	rs661395	0.671	0.9361	0.4502	0.424775996844439	-0.0793666055947136	-0.754095827748691	0.0507845
2	72588041	rs3106878	0.9873272	0.655	0.5731	-0.0158836833848095	0.446777770434783	0.563591304587156	
2	72588225	rs11903908	0.5684922	0.6932	0.1806	0.570273387160144	-0.39604291725	-1.34169820097561	5.19309e-05
2	72588448	rs1517179	0.5769831	0.6803	0.1801	0.557796853638351	-0.412451340791667	-1.34169820097561	5.19309e-05
2	72588669	rs1568145	0.6808702	0.9504	0.4758	0.411275950054255	-0.061717220969163	-0.712151330890052	0.0507845
2	72589000	rs634785	0.6711244	0.9239	0.437	0.424605251946411	-0.0970230640969163	-0.77481500052356	0.0507845
2	72589312	rs687371	0.6808852	0.8938	0.4244	0.411255523633182	-0.132357225550661	-0.796073954973822	0.0507845
2	72589663	rs11884225	0.6227658	0.6363	0.19	0.491934227421397	-0.47322772033195	-1.31074152912621	5.19309e-05
2	72590248	rs669074	0.6859103	0.8959	0.4327	0.404411313463774	-0.132357225550661	-0.78544339895288	0.0507845
2	72592238	rs680495	0.4753927	0.718	0.126	0.713732234916385	-0.362057594770115	-1.52726663581081	0.0273338
2	72592644	rs74789845	0.3783204	0.1538	0.7635	-0.880995225166434	-1.42658369230769	-0.300412551612903	0.000265551
2	72593112	rs625434	0.6833387	0.8887	0.4233	0.407911453423085	-0.140753255374449	-0.800858409947644	0.0507845
2	72593243	rs587431	0.6450603	0.9931	0.4795	0.46063529114763	0.00877105275	-0.706844295811518	0.0507845
2	72594548	rs613880	0.6426502	0.9907	0.4803	0.46399657873608	0.0131559214473684	-0.706844295811518	0.0507845
2	72595282	rs77683017	0.5765669	0.4763	0.9785	-0.558406317518338	-0.712286775714286	0.026238554725537	0.000444013
2	72596171	rs192103383	0.3579562	0.1291	0.7025	-0.919266419465186	-1.51842215279673	-0.381135116938111	0.000198158
2	72596932	rs186505531	0.5271088	0.4547	0.9207	-0.632425604524803	-0.74642694198783	0.0997900889548693	0.000430116
2	72597101	rs60806585	0.5857171	0.6473	0.1695	0.54505291380231	-0.4583450775	-1.37580587170732	5.19309e-05
2	72597646	rs671550	0.7333387	0.8724	0.4722	0.34068773054345	-0.158434339823789	-0.717458903664921	0.0501733
2	72597683	rs141714296	0.5857171	0.6471	0.1691	0.54505291380231	-0.4583450775	-1.37580587170732	5.19309e-05
2	72597839	rs56173504	0.568544	0.6624	0.1643	0.570197119145632	-0.43770769375	-1.39035904731707	5.19309e-05
2	72598522	rs56184446	0.5802286	0.6721	0.1772	0.553050785732176	-0.423313795850622	-1.35122588487805	5.19309e-05
2	72598911	rs55939880	0.5714767	0.6812	0.1753	0.565877913423248	-0.410739924439834	-1.35624120292683	5.19309e-05
2	72599200	rs66539158	0.5714767	0.6809	0.1752	0.565877913423248	-0.410739924439834	-1.35624120292683	5.19309e-05
2	72599824	rs6714312	0.478355	0.7105	0.1246	0.708950781200643	-0.37362565183908	-1.5334870222973	0.027135
2	72600693	rs603324	0.7133741	0.9102	0.4813	0.367328392192031	-0.114686602202643	-0.706844295811518	0.0501733
2	72600856	rs602465	0.7133741	0.9104	0.4811	0.367328392192031	-0.114686602202643	-0.706844295811518	0.0501733
2	72600959	rs56042118	0.468276	0.7939	0.1481	-0.725286955884957	0.261309269900498	1.44358360297619	0.00111568
2	72600969	rs72841795	0.4999615	0.7453	0.1554	0.674550221756922	-0.326374214769874	-1.42139021764706	6.25266e-05
2	72602388	rs666233	0.4754906	0.7027	0.1195	0.713574043821874	-0.385196037931035	-1.55422578175676	0.027135
2	72606346	rs56718524	0.4818891	0.7794	0.1584	0.703267333448469	-0.280435609205021	-1.4118034122549	6.25266e-05
2	72606790	rs66560019	0.5502525	0.6977	0.1692	0.597381778990985	-0.386022420165975	-1.37580587170732	5.19309e-05
2	72607722	rs112951680	0.7588137	0.8422	0.471	0.307038957962296	-0.199712821216849	-0.720409977485929	0.000306315
2	72607816	rs590252	0.4542741	0.6865	0.1035	0.748308392808327	-0.402555985804598	-1.62824590405405	0.027135
2	72609738	rs1914339	0.5020802	0.7328	0.1508	0.671220213457736	-0.343245077447699	-1.43602632647059	6.25266e-05
2	72610085	rs634574	0.7695141	0.8175	0.4675	0.293010513441646	-0.229229728281938	-0.72754477434555	0.0501733
2	72610456	rs636332	0.8980449	0.6922	0.5017	0.128131470834386	-0.396492607797357	-0.670240410471204	0.051408
2	72610532	rs636734	0.8465272	0.7628	0.5127	0.193551368010266	-0.301474948340611	-0.658047076683938	0.0394354
2	72611175	rs641939	0.4781014	0.6592	0.1057	0.709359518831366	-0.442503777356322	-1.61509622162162	0.027135
2	72611364	rs641123	0.8325788	0.7731	0.5003	0.211395344854584	-0.289550159429825	-0.672025279166667	0.051408
2	72611844	rs638854	0.4836818	0.6587	0.1085	0.700393190859222	-0.442503777356322	-1.60125721486486	0.027135
2	72611942	rs59974816	0.5019151	0.7343	0.1525	0.671479499461891	-0.339026723974895	-1.43148361813725	6.25266e-05
2	72612168	rs59386422	0.3711459	0.8469	0.2397	-0.894328949389295	-0.193086814981949	1.17668370905077	0.000265551
2	72612874	rs2222142	0.3642785	0.8589	0.2237	-0.907242633888326	-0.177176175045208	1.2168012880531	0.000265551
2	72614539	rs687325	0.8980654	0.6989	0.5114	0.12810556887313	-0.387603275594714	-0.659635370680628	0.051408
2	72619262	rs614653	0.8455155	0.7567	0.5001	0.194843497162671	-0.311189073508772	-0.672025279166667	0.051408
2	72620138	rs34183790	0.8753495	0.731	0.5143	0.156867182498454	-0.34502759371179	-0.652799770984456	0.051408
2	72621479	rs1400582	0.8700219	0.7292	0.507	0.163630716220051	-0.34502759371179	-0.663294913989637	0.051408
2	72621970	rs630241	0.462108	0.7082	0.1151	0.735380201696104	-0.37362565183908	-1.57427930067568	0.027135
2	72622480	rs642652	0.4512633	0.6844	0.1004	0.753310481414075	-0.407764992873563	-1.64209044054054	0.027135
2	72623205	rs116184475	0.6892403	0.03247	0.05966	0.399886177470691	2.13660586546185	1.88254793403756	0.000319959
2	72623612	rs628432	0.508751	0.6419	0.1168	0.660783662926795	-0.465674638103448	-1.56736362162162	0.027135
2	72624914	rs67085067	0.4699066	0.7633	0.1427	0.722631034627589	-0.301080668702929	-1.46581673284314	6.25266e-05
2	72625421	rs72845103	0.5556742	0.4399	0.06613	0.589278821190916	-0.771852246359223	-1.83538697601156	0.000542097
2	72625427	rs66827358	0.4718788	0.7602	0.142	0.719425451722363	-0.305295198033473	-1.46581673284314	6.25266e-05
2	72627158	rs7583268	0.4623516	0.7843	0.1458	0.734980001735517	-0.276223583054393	-1.45571626176471	6.25266e-05
2	72628508	rs137919383	0.4661316	0.765	0.1408	0.728787566840906	-0.296866563849372	-1.4703626245098	6.25266e-05
2	72629234	rs185879164	0.7803614	0.4488	0.2035	0.278848162588228	-0.757821078777778	-1.27091378901373	0.000104943
2	72629568	rs11681845	0.3477181	0.5897	0.03778	0.939024669426997	-0.541474823684211	-2.07461724210526	6.84928e-08
2	72630591	rs6718052	0.4719002	0.7463	0.1368	0.719390712858871	-0.322157561757322	-1.48551864019608	6.25266e-05
2	72631003	rs681908	0.85699	0.7293	0.493	0.18020716607375	-0.34502759371179	-0.689017002072539	0.051408
2	72631258	rs584522	0.4700206	0.6778	0.1094	0.722445418175605	-0.413553332298851	-1.60125721486486	0.027135
2	72631323	rs57286048	0.4660407	0.7596	0.1376	0.728936086159416	-0.305295198033473	-1.48046611421569	6.25266e-05
2	72631561	rs57694083	0.3795143	0.8613	0.241	-0.878791482163787	-0.17566780759058	1.17257381769912	0.000265551
2	72631576	rs583119	0.4948128	0.6446	0.1116	0.682674045503706	-0.459881047068966	-1.59433877432432	0.027135
2	72631733	rs6546769	0.4640365	0.7602	0.1374	0.732216274336732	-0.305295198033473	-1.48551864019608	6.25266e-05
2	72631778	rs6546770	0.4640365	0.7609	0.1373	0.732216274336732	-0.305295198033473	-1.48551864019608	6.25266e-05
2	72631907	rs114805989	0.3188348	0.6138	0.03307	0.996855170722594	-0.505662917343173	-2.12990253030303	3.55104e-07
2	72632539	rs77005916	0.4640365	0.7615	0.1364	0.732216274336732	-0.305295198033473	-1.48551864019608	6.25266e-05
2	72633762	rs149154912	0.293519	0.9306	0.1231	-1.05043323722124	-0.0876132164705882	1.54183994881517	0.000158048
2	72635689	rs143543336	0.4681146	0.7496	0.1358	0.725550046254661	-0.317941333682008	-1.49006635931373	6.25266e-05
2	72637624	rs7575050	0.456535	0.7786	0.1401	0.744564509483777	-0.280435609205021	-1.47541410882353	6.25266e-05
2	72637927	rs114015867	0.3002654	0.9012	0.07894	-1.03586441205796	0.124256837294333	1.75483138091106	0.00201215
2	72637965	rs681574	0.898264	0.6768	0.4886	0.127854676615251	-0.418723789162996	-0.696231839790576	0.051408
2	72638705	rs58033567	0.4584035	0.7575	0.1324	0.741478168098242	-0.309510151882845	-1.50472299019608	6.25266e-05
2	72638719	rs60536402	0.4641457	0.7537	0.1344	0.73203742892412	-0.31372553041841	-1.495119875	6.25266e-05
2	72638819	rs11897200	0.4506983	0.7852	0.1383	0.754251395327722	-0.27201198083682	-1.48046611421569	6.25266e-05
2	72639901	rs10496183	0.4652027	0.7383	0.1288	0.730306649016162	-0.334808795774059	-1.5222958	6.25266e-05
2	72639936	rs55840408	0.4652027	0.7382	0.1287	0.730306649016162	-0.334808795774059	-1.5222958	6.25266e-05
2	72640213	rs112350586	0.4653583	0.7345	0.1273	0.730052180681316	-0.339026723974895	-1.52686865517241	6.25266e-05
2	72640680	rs11674508	0.4690754	0.7412	0.1321	0.72398414579538	-0.330591292719665	-1.50756393103448	6.25266e-05
2	72641282	rs45556232	0.2418387	0.9789	0.06419	-1.17040341159196	0.0267492808515815	1.85228825623188	0.00106985
2	72642796	rs7608054	0.4690754	0.7421	0.1323	0.72398414579538	-0.330591292719665	-1.50756393103448	6.25266e-05
2	72642988	rs659833	0.4411291	0.6881	0.09625	0.770287938593647	-0.402555985804598	-1.66217005878378	0.027135
2	72643287	rs67166018	0.4525955	0.7658	0.1317	0.751094917132164	-0.296866563849372	-1.50472299019608	6.25266e-05
2	72643375	rs3115351	0.4835929	0.6508	0.1063	0.700535516659338	-0.45408804	-1.61509622162162	0.027135
2	72644845	rs17008143	0.4622367	0.7606	0.1362	0.735168732757216	-0.305295198033473	-1.49006635931373	6.25266e-05
2	72644884	rs17040320	0.477097	0.7346	0.1348	0.710979302035056	-0.339026723974895	-1.49740658768473	6.25266e-05
2	72645017	rs145571931	0.3814606	0.4994	0.5776	-0.875208241362491	-0.675229741025641	0.556933878210678	0.000144732
2	72646373	rs623095	0.9193677	0.6742	0.5108	0.101230141349364	-0.422726593524229	-0.659635370680628	0.051408
2	72646639	rs634476	0.8851471	0.7101	0.5033	0.144447538800996	-0.372631093026316	-0.666749575	0.051408
2	72647093	rs6758324	0.3374573	0.6175	0.03947	0.959201346474564	-0.499925869924812	-2.05714675833333	6.84928e-08
2	72647458	rs6758689	0.5100376	0.6992	0.1421	0.658779134164624	-0.385029739121339	-1.46581673284314	6.81205e-05
2	72647841	rs6743881	0.4709846	0.7464	0.1361	0.720877998822762	-0.322157561757322	-1.49283646600985	6.25266e-05
2	72648052	rs7420588	0.4920281	0.6515	0.1102	0.687086713535335	-0.45408804	-1.59433877432432	0.027135
2	72648432	rs7596126	0.4949397	0.7162	0.1389	0.682473214812964	-0.363921159121339	-1.48268215862069	6.25266e-05
2	72649112	rs7599755	0.4681146	0.7518	0.1355	0.725550046254661	-0.317941333682008	-1.49006635931373	6.25266e-05
2	72650263	rs7603342	0.4739904	0.7368	0.1348	0.716001437687014	-0.334808795774059	-1.495119875	6.25266e-05
2	72650266	rs7603535	0.4759737	0.7358	0.1347	0.712793269686897	-0.339026723974895	-1.495119875	6.25266e-05
2	72650937	rs640610	0.4383843	0.6779	0.09235	0.774924506418723	-0.413553332298851	-1.68225564527027	0.0273338
2	72651954	rs11887356	0.4681798	0.7429	0.1328	0.725443792903468	-0.330591292719665	-1.50472299019608	5.71284e-05
2	72652453	rs10175824	0.5361463	0.594	0.1141	0.618650980293265	-0.531393664435146	-1.58126737241379	5.71284e-05
2	72652484	rs10176044	0.5361463	0.5956	0.1142	0.618650980293265	-0.531393664435146	-1.58126737241379	5.71284e-05
2	72653115	rs59881252	0.4701041	0.7351	0.1314	0.722309591778252	-0.339026723974895	-1.50977801715686	5.71284e-05
2	72654662	rs689154	0.4865884	0.6418	0.1054	0.6957451818634	-0.465674638103448	-1.6213247	0.027135
2	72654827	rs4507127	0.4347627	0.7799	0.1253	0.781067638197712	-0.2792671275	-1.5345551877451	5.71284e-05
2	72655020	rs4508623	0.4366916	0.7801	0.127	0.77779210266025	-0.2792671275	-1.52949760490196	5.71284e-05
2	72655374	rs587744	0.4726452	0.6692	0.1061	0.718181742335833	-0.430921849252874	-1.61509622162162	0.0273338
2	72656450	rs680380	0.8874695	0.6803	0.4788	0.141506859860156	-0.414276655286344	-0.712151330890052	0.051408
2	72656691	rs55727931	0.4898416	0.7326	0.1423	0.690560665968002	-0.343245077447699	-1.46581673284314	6.25266e-05
2	72656740	rs55728837	0.4593833	0.7627	0.1351	0.739862680565887	-0.299826165916667	-1.495119875	6.25266e-05
2	72657163	rs6733538	0.4311415	0.8228	0.1399	0.787239838756624	-0.225190769125	-1.48046611421569	6.25266e-05
2	72657984	rs663218	0.4976062	0.6413	0.1111	0.678260932257972	-0.465674638103448	-1.59433877432432	0.027135
2	72659065	rs7561471	0.85732	0.2229	0.08594	0.179786714014392	-1.22182048679245	-1.71681137444444	0.000369589
2	72659523	rs6741956	0.9150302	0.5772	0.4089	0.106695940176752	-0.554598627947598	-0.823609813989637	0.0520441
2	72659731	rs634586	0.7338175	0.2192	0.0487	0.340051813907111	-1.22871106445783	-1.97184004680851	0.0211203
2	72661143	rs59176504	0.7578099	0.2456	0.06529	0.308358121272323	-1.16521757735849	-1.83968427624309	0.000369589
2	72661525	rs589547	0.6964185	0.2172	0.03961	0.39015962504302	-1.23485960722892	-2.05647946382979	0.0211203
2	72661750	rs62149292	0.8884558	0.08612	0.0706	0.140258417241253	1.71661966053269	1.80866810485714	0.000444013
2	72661791	rs676078	0.6396289	0.2646	0.04165	0.46821761994338	-1.11446240843373	-2.03531013829787	0.0211203
2	72663244	rs62149293	0.7984005	0.07173	0.08426	0.255417767023452	1.79844245679612	1.72792465931232	0.000444013
2	72663283	rs143596467	0.596628	0.8853	0.5114	-0.529255804828517	-0.144038591857001	0.655833296402878	0.000144732
2	72663316	rs668586	0.682064	0.2254	0.03864	0.409648245179075	-1.21088383795181	-2.07116860285714	0.0208405
2	72663717	rs138335367	0.0476169	0.1349	0.1937	-1.98077152183985	-1.4945827722372	1.29987865981453	0.201034
2	72663816	rs666361	0.8929269	0.6169	0.4207	0.134601550226415	-0.50241357092511	-0.806174983246073	0.0520441
2	72664114	rs66489235	0.7861791	0.2539	0.07777	0.271275636774409	-1.14208717440758	-1.76559735363129	0.000390814
2	72664311	rs13424607	0.899016	0.615	0.4262	0.126904449939962	-0.502001070305677	-0.792559359067357	0.0520441
2	72664536	rs7563738	0.645187	0.2454	0.03744	0.460458658426063	-1.15681969759036	-2.08587612928571	0.0208405
2	72665335	rs656440	0.8688201	0.6649	0.4432	0.165157389049676	-0.431623016740088	-0.769501610471204	0.0520441
2	72665954	rs582918	0.754943	0.5838	0.8648	0.312128299774872	0.547936851458333	0.169964231375	0.000171391
2	72665969	rs2901190	0.7865215	0.2312	0.06781	0.270830382469899	-1.19454947109005	-1.82675010949721	0.000390814
2	72666791	rs7571517	0.7150134	0.2463	0.05392	0.365131307929777	-1.15616857014218	-1.92727829106145	0.000390814
2	72667181	rs11685876	0.6937634	0.2576	0.05218	0.393752973738823	-1.13286370047393	-1.94405058882682	0.000390814
2	72667225	rs11126367	0.7930551	0.2397	0.07368	0.262345484990258	-1.17924102830189	-1.79421915555556	0.000390814
2	72668082	rs55825364	0.7230711	0.2421	0.05495	0.354357312748212	-1.16588231611374	-1.92207411843575	0.000390814
2	72668197	rs184181669	0.01449095	0.001078	0.9033	-2.44485712924965	-3.26822338852914	0.121741854879227	6.53928e-05
2	72668303	rs658067	0.8794551	0.6281	0.4189	0.151659963669299	-0.484593914537445	-0.811492096858639	0.0520441
2	72669141	rs11695000	0.8029935	0.2367	0.07549	0.249474850579887	-1.17997078436019	-1.77655377374302	0.000390814
2	72669402	rs112930199	0.7294733	0.6191	0.281	0.345826316499869	-0.496095781818182	-1.08011597082405	0.000225033
2	72670198	rs3106879	0.8195156	0.7052	0.4205	0.228168144291925	-0.377054702894737	-0.801976155208333	0.0520441
2	72670831	rs581976	0.8794794	0.6339	0.423	0.151629233295542	-0.475686788546255	-0.800858409947644	0.0520441
2	72673448	rs620770	0.6691617	0.2542	0.04533	0.427298786699521	-1.1383998253012	-2.00028513262411	0.0211203
2	72673549	rs72845109	0.6668949	0.8507	0.3841	0.430413473932685	-0.188288601533981	-0.870929173273942	0.00259605
2	72673557	rs642847	0.8715505	0.6764	0.4554	0.161689381214543	-0.418723789162996	-0.748784539790576	0.0520441
2	72673658	rs11695629	0.7465195	0.2439	0.06181	0.323232118397249	-1.16278650232558	-1.87390223351648	0.000348753
2	72674211	rs639843	0.6558317	0.2565	0.04267	0.445675368151686	-1.13226111927711	-2.02144400496454	0.0211203
2	72674929	rs626469	0.3823014	0.7357	0.07971	0.873663771877747	-0.336389099688474	-1.75278583579336	0.000112534
2	72676343	rs60563535	0.8152403	0.2161	0.06952	0.233671126623153	-1.23586077830189	-1.81660149777778	0.000369589
2	72678488	rs2901146	0.6776717	0.2361	0.04083	0.415642307465569	-1.18793016121212	-2.04249763428571	0.0208405
2	72678585	rs62149322	0.4571606	0.6739	0.5013	-0.743530433110664	-0.420050847707559	0.6719312872	0.000118179
2	72679025	rs72845111	0.1201071	0.8072	0.03307	-1.55432401017976	-0.24280870625	2.12894259455587	0.00116181
2	72679624	rs11884162	0.7360181	0.2324	0.05412	0.33713108752669	-1.19535459809524	-1.92207411843575	0.000390814
2	72680652	rs7577244	0.8020624	0.2134	0.0642	0.25067887451494	-1.2427428152381	-1.85384894719101	0.000390814
2	72680709	rs590345	0.6373808	0.2588	0.03907	0.471363999692517	-1.13356552666667	-2.06455120428571	0.0208405
2	72680716	rs12996385	0.04638162	0.02413	0.6444	-1.99190374488693	-2.25305277409639	0.461745188285229	0.000198158
2	72681710	rs10496184	0.7981612	0.2171	0.0645	0.255727643593265	-1.23246471209302	-1.85173470714286	0.000338484
2	72681922	rs1949377	0.8319893	0.2139	0.07306	0.212150995130675	-1.24070322735849	-1.78905528	0.000369589
2	72682283	rs7557942	0.7946012	0.2107	0.06061	0.260340521682786	-1.25582897203791	-1.88276936703911	0.000369589
2	72682865	rs17008188	0.7708857	0.2202	0.05895	0.291216558953848	-1.22182048679245	-1.88897537111111	0.000369589
2	72683578	rs12476397	0.8369904	0.6899	0.4274	0.205744708419968	-0.400937946651982	-0.796073954973822	0.051408
2	72684324	rs631550	0.8238925	0.6869	0.4086	0.222541431053663	-0.405383734140969	-0.827446677486911	0.0520441
2	72684766	rs674863	0.8188156	0.7314	0.4443	0.229068690065057	-0.34362747722467	-0.764188759685864	0.0520441
2	72684979	rs142993546	0.3013056	0.2231	0.8746	-1.03363774134037	-1.21828321181001	0.157203137099237	0.000184761
2	72686053	rs56777837	0.8934497	0.1974	0.08432	0.1339404261402	-1.28893339763033	-1.72640249944134	0.000369589
2	72688411	rs3106880	0.8304003	0.6913	0.4221	0.214188221282583	-0.399179446885965	-0.803082852331606	0.0520441
2	72688538	rs2203679	0.5983815	0.2987	0.04097	0.526729390116667	-1.04224392909091	-2.04249763428571	0.0211203
2	72690622	rs688433	0.884631	0.6472	0.4395	0.145101128279918	-0.460351049557522	-0.769501610471204	0.0520441
2	72691140	rs115434051	0.3647885	0.2732	0.9163	-0.906278370044287	-1.09488517166922	0.10427244820841	0.000347329
2	72692872	rs79156043	0.6480083	0.6754	0.2297	-0.456530848298718	0.418665538956311	1.20055475558739	0.000361057
2	72693113	rs634929	0.8763169	0.6659	0.4498	0.155639838911956	-0.433532853097345	-0.754095827748691	0.0520441
2	72693266	rs62149327	0.5335709	0.7754	0.5173	-0.622564260141458	-0.284828605597015	0.64797987648	0.000118179
2	72693535	rs17008208	0.7403341	0.2705	0.06987	0.331410964161968	-1.10549635023923	-1.8091570247191	0.000380154
2	72695932	rs11675264	0.6899508	0.2624	0.05301	0.398921797547683	-1.12128997943925	-1.93419765989011	0.000338484
2	72695961	rs11675268	0.7127299	0.2894	0.06868	0.368192247400914	-1.06119935258216	-1.81741224861878	0.000348753
2	72696675	rs62149328	0.5478537	0.7887	0.5268	-0.600979349851979	-0.2686118	0.633717673089172	0.000118179
2	72697479	rs585653	0.8369904	0.6896	0.4269	0.205744708419968	-0.400937946651982	-0.796073954973822	0.0520441
2	72697616	rs629539	0.6212133	0.2857	0.04265	0.494131484998496	-1.06691187575758	-2.02118565428571	0.0208405
2	72697644	rs584865	0.8606414	0.951	0.7291	0.175557738710058	-0.0613974333184358	-0.3465994704	0.00378723
2	72700111	rs597799	0.8712344	0.6768	0.4557	0.162090710417955	-0.416109737831858	-0.743473790575916	0.0520441
2	72701177	rs619343	0.8868886	0.6704	0.4681	0.14224237024662	-0.424597065176991	-0.722767014659686	0.0520441
2	72701489	rs678684	0.8685489	0.6811	0.4572	0.165501985830728	-0.411643377256637	-0.743473790575916	0.0520441
2	72702058	rs6736305	0.8427691	0.7663	0.507	0.198352824815535	-0.299695533920705	-0.661474405208333	0.0520441
2	72702715	rs646357	0.6784892	0.8211	0.3638	0.4145256447248	-0.224801681762115	-0.911021710994764	0.0520441
2	72702865	rs645489	0.7313491	0.8078	0.4114	0.343331441380765	-0.242073580704846	-0.817846027604167	0.0520441
2	72703142	rs671721	0.7372707	0.8277	0.4338	0.335469831492385	-0.219407527324561	-0.781352547916667	0.0520441
2	72703425	rs632670	0.8953033	0.6764	0.484	0.131596615188668	-0.416109737831858	-0.696231839790576	0.0520441
2	72703506	rs67491855	0.8166097	0.2619	0.09274	0.231907763732653	-1.12362923142857	-1.67572053296089	0.000369589
2	72703733	rs684673	0.8317472	0.7062	0.4372	0.212461259929616	-0.37427263969163	-0.77481500052356	0.0520441
2	72706633	rs17263172	0.8474604	0.2303	0.08706	0.192359766807645	-1.20023780190476	-1.71350817134831	0.000369589
2	72707580	rs142974127	0.4804952	0.6759	0.5485	0.705506339055371	0.417973229172511	-0.599276193656093	0.000184761
2	72707874	rs653220	0.6121107	0.3044	0.04581	0.507062790961662	-1.03061207804878	-2.00021184604317	0.0208405
2	72708107	rs654157	0.8842977	0.7039	0.4988	0.145523266551129	-0.380391470176991	-0.675543736125654	0.0520441
2	72709774	rs650352	0.8661653	0.7395	0.5127	0.168531377976721	-0.330310139955947	-0.654333656020942	0.0520441
2	72710029	rs683328	0.8696154	0.7097	0.4869	0.1641470468249	-0.372631093026316	-0.694267977202072	0.0520441
2	72712224	rs6714580	0.8423076	0.7389	0.4787	0.198942655089704	-0.334748805066079	-0.706844295811518	0.0520441
2	72712248	rs6714595	0.638586	0.3102	0.05425	0.469676605432941	-1.01821034268293	-1.9277570352518	0.0208405
2	72712364	rs6758593	0.6352102	0.3139	0.05401	0.474406257514531	-1.01201042134146	-1.9277570352518	0.0208405
2	72714401	rs13001810	0.03127917	0.02675	0.4585	-2.15350289209193	-2.21498882926829	0.741240252256944	0.000225033
2	72714799	rs583673	0.751215	0.8103	0.4372	0.317037696154806	-0.242073580704846	-0.780128929842932	0.0520441
2	72717276	rs34597906	0.2246403	0.3187	0.4823	-1.21428144364695	-0.997779526535088	0.702266672519084	0.000198158
2	72718221	rs585938	0.7925924	0.8201	0.4962	0.262945737470959	-0.229229728281938	-0.68084759895288	0.0520441
2	72718727	rs11126369	0.6462802	0.3089	0.05625	0.458935853851247	-1.01893204312796	-1.91051102681564	0.000369589
2	72722464	rs11689707	0.6920676	0.3431	0.08359	0.396050777617312	-0.947458652857143	-1.73030739044944	0.000369589
2	72722787	rs142367832	0.3015481	0.1299	0.8467	-1.03311923167701	-1.5154740492228	-0.19323674202454	0.000118179
2	72725947	rs11126370	0.8651867	0.7399	0.5114	-0.169775534207892	0.333412936444444	0.657975222105263	0.0520441
2	72729261	rs1400580	0.8464305	0.7572	0.5044	-0.193674808048902	0.310909978311111	0.668369735789474	0.0520441
2	72729324	rs1400581	0.582598	0.4022	0.06606	-0.549593714544957	0.83662308969697	1.83549900642857	0.0212621
2	72730418	rs11126372	0.7574546	0.8712	0.4998	-0.308825078989275	0.1645837744	0.673566222631579	0.0520441
2	72731190	rs60580301	0.6774525	0.372	0.09037	0.415941907183864	-0.890783629383886	-1.69299331061453	0.000348753
2	72731696	rs115051528	0.01530119	0.1838	0.02976	-2.42517063891316	-1.32821565834933	2.17368527305123	0.00075714
2	72731874	rs114008126	0.4269137	0.01785	0.1266	-0.794484011217906	-2.36782488789238	-1.52714406519481	0.000485875
2	72733022	rs114618681	0.2191669	0.1661	0.7966	-1.22874644596605	-1.38531360224888	0.257145767985612	0.00033363
2	72733126	rs1517185	0.5757783	0.4069	0.06495	-0.559561855060155	0.830047462424242	1.84315640571429	0.0216949
2	72735313	rs1517182	0.09648454	0.9327	0.007518	-1.66214082090231	0.0856500642285714	2.66452126510067	0.0501733
2	72735509	rs2138683	0.7806249	0.8093	0.4744	-0.27850486364381	0.239796378533333	0.715638868947369	0.0520441
2	72735706	rs58967293	0.8295998	0.327	0.1367	0.215214901961285	-0.981071629577465	-1.49436354833333	0.000328317
2	72740596	rs190113821	0.7367539	0.2003	0.3361	-0.336155169180168	-1.28080445342466	-0.962557480078895	0.000104943
2	72740726	rs1517181	0.7599127	0.8468	0.4806	-0.30559551821953	0.1955690864	0.705253687368421	0.0520441
2	72740914	rs148264602	0.8986112	0.7466	0.5412	-0.127415900949519	0.322627606846473	0.610139561277705	0.000252017
2	72742820	rs17560823	0.7653188	0.3222	0.4718	0.298503691471973	0.990212971153846	0.718478690804598	0.000537634
2	72743467	rs113085287	0.6481359	0.3542	0.07192	0.456353331372065	-0.925459219626168	-1.8008568160221	0.000318253
2	72744688	rs12713772	0.7417028	0.9039	0.5143	-0.329599285477864	0.119838291022222	0.652777195789474	0.0520441
2	72745105	rs62149336	0.5083124	0.02591	0.1102	0.66146762593898	2.22806655751295	1.60053563902439	0.000742593
2	72745682	rs4144318	0.7624883	0.8405	0.478	-0.302214907207387	0.199993796666667	0.705253687368421	0.0520441
2	72746317	rs12713773	0.7795115	0.8325	0.4928	-0.279955715439561	0.211386295682819	0.68606122408377	0.0520441
2	72746826	rs13016873	0.7515631	0.8358	0.4597	-0.316579042141459	0.208841895822222	0.740821144973545	0.0520441
2	72747629	rs4852872	0.7342425	0.8874	0.4853	-0.339487481533673	0.142438175511111	0.694866456842105	0.051408
2	72748616	rs10496185	0.6204579	0.4002	0.07915	0.495201418442071	-0.838656328909953	-1.75406660055866	0.000348753
2	72749730	rs6750766	0.661365	0.872	0.3845	-0.438029302119472	0.160155537333333	0.868582742105263	0.0520441
2	72749995	rs10460572	0.6513528	0.9113	0.4058	-0.451883590371419	0.110972453288889	0.831813112631579	0.0520441
2	72750154	rs12992973	0.4823262	0.5019	0.05958	-0.702566108639729	0.672617373939394	1.87864817285714	0.0214051
2	72752939	rs4852873	0.5449053	0.4546	0.06873	-0.605411909234881	0.745696633939394	1.81461101571429	0.0214051
2	72753126	rs55843056	0.3158976	0.1305	0.8388	-1.00292380477125	-1.51141687923211	-0.203224352191235	0.000279111
2	72756991	rs72845187	0.4451715	0.9814	0.2249	-0.76348948816062	0.0227170515858586	1.21329449339339	0.00117725
2	72757843	rs12052508	0.8610707	0.777	0.5448	-0.17501139576757	0.282516257757847	0.60663395	0.0507845
2	72758653	rs4852874	0.6145562	0.3989	0.0762	-0.503580384058023	0.842600313333333	1.77142313642857	0.0216949
2	72758775	rs4852875	0.8838054	0.7822	0.5816	-0.146146936199375	0.275588250755556	0.552875402631579	0.0520441
2	72759101	rs6711701	0.7867547	0.3166	0.11	0.270527244318266	-1.00464794906542	-1.59886306758242	0.000308293
2	72760420	rs7420667	0.640562	0.3897	0.08313	-0.466913139595823	0.860528448484848	1.73587803714286	0.0216949
2	72762194	rs4852876	0.838636	0.7977	0.5329	-0.203638587512903	0.257916854533333	0.621058111578947	0.0520441
2	72762253	rs12618390	0.8412751	0.7941	0.5328	-0.200262715353865	0.262335362355556	0.621058111578947	0.0520441
2	72762502	rs11126373	0.838636	0.7974	0.5359	-0.203638587512903	0.257916854533333	0.621058111578947	0.0520441
2	72762644	rs10865391	0.838636	0.796	0.5332	-0.203638587512903	0.257916854533333	0.621058111578947	0.0520441
2	72763459	rs12998681	0.846528	0.795	0.5404	-0.193550342923537	0.262335362355556	0.610654248947368	0.0520441
2	72764025	rs145838539	0.4169677	0.2574	0.9729	-0.811693247308082	-1.13320831798189	-0.0338434452957746	0.000118179
2	72766892	rs11893504	0.6328729	0.3862	0.07841	-0.477687147591876	0.867221703614458	1.75885985177305	0.0221392
2	72767171	rs189442736	0.800587	0.2395	0.3301	-0.252587514467921	-1.17633339220339	-0.974609462352941	0.000104943
2	72767622	rs144085095	0.9082756	0.3144	0.2061	0.115213834778451	-1.00621948773467	-1.26401461755102	0.000171391
2	72767778	rs983928	0.8594017	0.6482	0.4178	-0.177135845439352	0.45526004375	0.810568241052632	0.0489863
2	72768864	rs115038367	0.9230512	0.3685	0.3746	-0.0965908997670818	-0.899725588043478	-0.887482303472222	0.000104943
;;;;
run;
data work.gtf;
length chr_text $128 chr_raw $128 seqname $128 source $128 feature $128 type $128 score $128 strand $128 frame $128 gene $128 gene_name $128 gene_id $128 transcript_name $128 transcript_id $128 gene_type $128 transcript_type $128 exon_id $128 exon_number $128 ensembl $128 genesymbol $128;
infile datalines4 dlm='09'x dsd truncover;
input chr chr_text :$128. chr_raw :$128. seqname :$128. source :$128. feature :$128. type :$128. start end st en bp1 bp2 txStart txEnd score :$128. strand :$128. frame :$128. gene :$128. gene_name :$128. gene_id :$128. transcript_name :$128. transcript_id :$128. gene_type :$128. transcript_type :$128. exon_id :$128. exon_number :$128. ensembl :$128. genesymbol :$128. protein_coding original_protein_coding;
datalines4;
2	2	chr2	chr2	HAVANA	gene	gene	71680691	71913893	71680691	71913893	71680691	71913893	71680691	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18			protein_coding				HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71680691	71913893	71680691	71913893	71680691	71913893	71680691	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71680852	71913778	71680852	71913778	71680852	71913778	71680852	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71680852	71913778	71680852	71913778	71680852	71913778	71680852	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71680852	71913778	71680852	71913778	71680852	71913778	71680852	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71680852	71913778	71680852	71913778	71680852	71913778	71680852	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693829	71913893	71693829	71913893	71693829	71913893	71693829	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693829	71913893	71693829	71913893	71693829	71913893	71693829	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693832	71913778	71693832	71913778	71693832	71913778	71693832	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693832	71913778	71693832	71913778	71693832	71913778	71693832	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693832	71913778	71693832	71913778	71693832	71913778	71693832	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693832	71913778	71693832	71913778	71693832	71913778	71693832	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693832	71913778	71693832	71913778	71693832	71913778	71693832	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71693859	71913893	71693859	71913893	71693859	71913893	71693859	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71776480	71776521	71776480	71776521	71776480	71776521	71776480	71776521	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00001072853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778171	71778286	71778171	71778286	71778171	71778286	71778171	71778286	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000846589.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71778737	71778850	71778737	71778850	71778737	71778850	71778737	71778850	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761306.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780141	71780318	71780141	71780318	71780141	71780318	71780141	71780318	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00002480060.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71780937	71781061	71780937	71781061	71780937	71781061	71780937	71781061	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761308.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71783095	71783201	71783095	71783201	71783095	71783201	71783095	71783201	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761309.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71788882	71789074	71788882	71789074	71788882	71789074	71788882	71789074	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761310.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71791188	71791343	71791188	71791343	71791188	71791343	71791188	71791343	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000920763.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795081	71795212	71795081	71795212	71795081	71795212	71795081	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000920764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795144	71795212	71795144	71795212	71795144	71795212	71795144	71795212	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003972577.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71795144	71913880	71795144	71913880	71795144	71913880	71795144	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71795302	71795468	71795302	71795468	71795302	71795468	71795302	71795468	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000920765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71796950	71797064	71796950	71797064	71796950	71797064	71796950	71797064	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761314.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797268	71797464	71797268	71797464	71797268	71797464	71797268	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-212	ENST00000461565.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001858316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71797268	71798046	71797268	71798046	71797268	71798046	71797268	71798046	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-212	ENST00000461565.1_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797359	71797464	71797359	71797464	71797359	71797464	71797359	71797464	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761316.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71797871	71797729	71797871	71797729	71797871	71797729	71797871	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761318.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71797729	71798046	71797729	71798046	71797729	71798046	71797729	71798046	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-212	ENST00000461565.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001863184.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71801328	71801501	71801328	71801501	71801328	71801501	71801328	71801501	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00000761319.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71803392	71803573	71803392	71803573	71803392	71803573	71803392	71803573	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003972578.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71803392	71803573	71803392	71803573	71803392	71803573	71803392	71803573	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003972578.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71803392	71913880	71803392	71913880	71803392	71913880	71803392	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71803392	71913880	71803392	71913880	71803392	71913880	71803392	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71803398	71803573	71803398	71803573	71803398	71803573	71803398	71803573	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding	ENSE00001908694.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71803398	71827970	71803398	71827970	71803398	71827970	71803398	71827970	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71804029	71804261	71804029	71804261	71804029	71804261	71804029	71804261	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00001939324.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71804029	71913893	71804029	71913893	71804029	71913893	71804029	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71815835	71815903	71815835	71815903	71815835	71815903	71815835	71815903	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001938495.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71815835	71827972	71815835	71827972	71815835	71827972	71815835	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding	ENSE00003972580.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003972580.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003663865.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003972580.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003972580.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71816723	71816816	71816723	71816816	71816723	71816816	71816723	71816816	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003495281.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003563532.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71817341	71817418	71817341	71817418	71817341	71817418	71817341	71817418	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003642866.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003687479.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71825694	71825875	71825694	71825875	71825694	71825875	71825694	71825875	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003649549.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827970	71827832	71827970	71827832	71827970	71827832	71827970	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-215	ENST00000475076.5_2	protein_coding	protein_coding	ENSE00001927136.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-218	ENST00000493767.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003548301.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71827832	71827972	71827832	71827972	71827832	71827972	71827832	71827972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003567669.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828402	71828658	71828402	71828658	71828402	71828658	71828402	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001856863.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71828402	71839819	71828402	71839819	71828402	71839819	71828402	71839819	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828426	71828658	71828426	71828658	71828426	71828658	71828426	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001855604.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71828426	71839843	71828426	71839843	71828426	71839843	71828426	71839843	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71828629	71828658	71828629	71828658	71828629	71828658	71828629	71828658	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003463707.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829814	71829935	71829814	71829935	71829814	71829935	71829814	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001887993.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71829814	71840506	71829814	71840506	71829814	71840506	71829814	71840506	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003485765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003485765.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71829906	71829935	71829906	71829935	71829906	71829935	71829906	71829935	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003495395.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71835706	71835747	71835706	71835747	71835706	71835747	71835706	71835747	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003972579.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71835706	71835747	71835706	71835747	71835706	71835747	71835706	71835747	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003972579.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71837909	71838047	71837909	71838047	71837909	71838047	71837909	71838047	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001883842.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	71837909	71871163	71837909	71871163	71837909	71871163	71837909	71871163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined			HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003669295.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003669295.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003669295.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003669295.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838375	71838476	71838375	71838476	71838375	71838476	71838375	71838476	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003652872.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003678056.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003678056.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003678056.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838595	71838756	71838595	71838756	71838595	71838756	71838595	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003666914.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71838657	71838756	71838657	71838756	71838657	71838756	71838657	71838756	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001825645.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839819	71839771	71839819	71839771	71839819	71839771	71839819	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-214	ENST00000472873.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001861973.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839843	71839771	71839843	71839771	71839843	71839771	71839843	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-219	ENST00000494501.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001858227.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003649151.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003649151.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71839771	71839936	71839771	71839936	71839771	71839936	71839771	71839936	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003500649.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840506	71840464	71840506	71840464	71840506	71840464	71840506	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-217	ENST00000487180.5_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001880946.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003694283.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71840464	71840540	71840464	71840540	71840464	71840540	71840464	71840540	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003550093.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00003618243.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71847677	71847739	71847677	71847739	71847677	71847739	71847677	71847739	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003519442.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71869058	71869082	71869058	71869082	71869058	71869082	71869058	71869082	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003972575.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71869608	71869732	71869608	71869732	71869608	71869732	71869608	71869732	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003972574.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871163	71871095	71871163	71871095	71871163	71871095	71871163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-213	ENST00000468173.1_1	protein_coding	protein_coding_CDS_not_defined	ENSE00001850594.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71871095	71871193	71871095	71871193	71871095	71871193	71871095	71871193	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003510739.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883292	71883420	71883292	71883420	71883292	71883420	71883292	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003618663.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883307	71883420	71883307	71883420	71883307	71883420	71883307	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00004319133.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71883361	71883420	71883361	71883420	71883361	71883420	71883361	71883420	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00004319135.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71886008	71886163	71886008	71886163	71886008	71886163	71886008	71886163	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003600853.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71887690	71887781	71887690	71887781	71887690	71887781	71887690	71887781	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003567354.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71891398	71891568	71891398	71891568	71891398	71891568	71891398	71891568	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003533440.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71892292	71892434	71892292	71892434	71892292	71892434	71892292	71892434	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003612101.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71894506	71894645	71894506	71894645	71894506	71894645	71894506	71894645	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003494116.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71895884	71895972	71895884	71895972	71895884	71895972	71895884	71895972	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003637790.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896242	71896337	71896242	71896337	71896242	71896337	71896242	71896337	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003552220.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71896735	71896876	71896735	71896876	71896735	71896876	71896735	71896876	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003683266.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71901327	71901426	71901327	71901426	71901327	71901426	71901327	71901426	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003497725.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71906187	71906365	71906187	71906365	71906187	71906365	71906187	71906365	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003472400.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71908131	71908240	71908131	71908240	71908131	71908240	71908131	71908240	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003548775.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71909660	71909807	71909660	71909807	71909660	71909807	71909660	71909807	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003620355.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-202	ENST00000394120.6_5	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-203	ENST00000409366.5_3	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-204	ENST00000409582.7_9	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-205	ENST00000409651.5_7	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-206	ENST00000409744.5_5	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-207	ENST00000409762.5_8	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-209	ENST00000410041.1_4	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-210	ENST00000413539.6_2	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913778	71913584	71913778	71913584	71913778	71913584	71913778	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-211	ENST00000429174.6_3	protein_coding	protein_coding	ENSE00001589403.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913880	71913584	71913880	71913584	71913880	71913584	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-220	ENST00000698057.1_3	protein_coding	protein_coding	ENSE00003972576.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913880	71913584	71913880	71913584	71913880	71913584	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-221	ENST00000698058.1_2	protein_coding	protein_coding	ENSE00003972576.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913880	71913584	71913880	71913584	71913880	71913584	71913880	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-222	ENST00000698059.1_1	protein_coding	protein_coding	ENSE00003972576.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913893	71913584	71913893	71913584	71913893	71913584	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-201	ENST00000258104.8_10	protein_coding	protein_coding	ENSE00003850764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913893	71913584	71913893	71913584	71913893	71913584	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-208	ENST00000410020.8_11	protein_coding	protein_coding	ENSE00003850764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913893	71913584	71913893	71913584	71913893	71913584	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-216	ENST00000479049.6_2	protein_coding	protein_coding	ENSE00003850764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913893	71913584	71913893	71913584	71913893	71913584	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-223	ENST00000873664.1_1	protein_coding	protein_coding	ENSE00003850764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	HAVANA	exon	exon	71913584	71913893	71913584	71913893	71913584	71913893	71913584	71913893	.	+	.	DYSF	DYSF	ENSG00000135636.17_18	DYSF-224	ENST00000873665.1_1	protein_coding	protein_coding	ENSE00003850764.1_1		HAVANA	DYSF	1	1
2	2	chr2	chr2	ENSEMBL	exon	exon	72356367	72359748	72356367	72359748	72356367	72359748	72356367	72359748	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding	ENSE00000846592.3_1		ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	ENSEMBL	transcript	transcript	72356367	72374991	72356367	72374991	72356367	72374991	72356367	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding			ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72356367	72359748	72356367	72359748	72356367	72359748	72356367	72359748	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00000846592.3_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	gene	gene	72356367	72374991	72356367	72374991	72356367	72374991	72356367	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13			protein_coding				HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72356367	72374991	72356367	72374991	72356367	72374991	72356367	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding			HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72356522	72359748	72356522	72359748	72356522	72359748	72356522	72359748	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding	ENSE00001670276.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72356522	72370213	72356522	72370213	72356522	72370213	72356522	72370213	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding			HAVANA	CYP26B1	1	1
2	2	chr2	chr2	ENSEMBL	exon	exon	72360152	72360436	72360152	72360436	72360152	72360436	72360152	72360436	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding	ENSE00000761362.1_1		ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72360152	72360436	72360152	72360436	72360152	72360436	72360152	72360436	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00000761362.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72360152	72360436	72360152	72360436	72360152	72360436	72360152	72360436	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding	ENSE00000761362.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	ENSEMBL	exon	exon	72361890	72362045	72361890	72362045	72361890	72362045	72361890	72362045	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding	ENSE00000761363.1_1		ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72361890	72362045	72361890	72362045	72361890	72362045	72361890	72362045	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00000761363.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72361890	72362045	72361890	72362045	72361890	72362045	72361890	72362045	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding	ENSE00000761363.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72361980	72362045	72361980	72362045	72361980	72362045	72361980	72362045	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-204	ENST00000474509.1_8	protein_coding	protein_coding	ENSE00001888384.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72361980	72374991	72361980	72374991	72361980	72374991	72361980	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-204	ENST00000474509.1_8	protein_coding	protein_coding			HAVANA	CYP26B1	1	1
2	2	chr2	chr2	ENSEMBL	exon	exon	72362273	72362548	72362273	72362548	72362273	72362548	72362273	72362548	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding	ENSE00003623778.1_1		ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72362273	72362548	72362273	72362548	72362273	72362548	72362273	72362548	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00003623778.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72362273	72362548	72362273	72362548	72362273	72362548	72362273	72362548	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding	ENSE00003581116.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72362273	72362548	72362273	72362548	72362273	72362548	72362273	72362548	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-204	ENST00000474509.1_8	protein_coding	protein_coding	ENSE00003623778.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72362409	72362548	72362409	72362548	72362409	72362548	72362409	72362548	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-203	ENST00000461519.1_8	protein_coding	protein_coding	ENSE00001863465.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72362409	72371544	72362409	72371544	72362409	72371544	72362409	72371544	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-203	ENST00000461519.1_8	protein_coding	protein_coding			HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72370133	72370213	72370133	72370213	72370133	72370213	72370133	72370213	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-202	ENST00000412253.1_4	protein_coding	protein_coding	ENSE00001760360.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72371118	72371342	72371118	72371342	72371118	72371342	72371118	72371342	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00000846593.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72371118	72371544	72371118	72371544	72371118	72371544	72371118	72371544	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-203	ENST00000461519.1_8	protein_coding	protein_coding	ENSE00001871292.1_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	ENSEMBL	exon	exon	72374760	72374991	72374760	72374991	72374760	72374991	72374760	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-205	ENST00000546307.5_5	protein_coding	protein_coding	ENSE00000401861.3_1		ENSEMBL	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72374760	72374991	72374760	72374991	72374760	72374991	72374760	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-201	ENST00000001146.7_7	protein_coding	protein_coding	ENSE00000401861.3_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72374760	72374991	72374760	72374991	72374760	72374991	72374760	72374991	.	-	.	CYP26B1	CYP26B1	ENSG00000003137.9_13	CYP26B1-204	ENST00000474509.1_8	protein_coding	protein_coding	ENSE00000401861.3_1		HAVANA	CYP26B1	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403113	72406590	72403113	72406590	72403113	72406590	72403113	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00001952405.2_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403113	72406590	72403113	72406590	72403113	72406590	72403113	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00001952405.2_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403113	72406590	72403113	72406590	72403113	72406590	72403113	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00001952405.2_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403113	72406590	72403113	72406590	72403113	72406590	72403113	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00001952405.2_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403113	72406590	72403113	72406590	72403113	72406590	72403113	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00001952405.2_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	gene	gene	72403113	73053180	72403113	73053180	72403113	73053180	72403113	73053180	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15			protein_coding				HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403113	73053119	72403113	73053119	72403113	73053119	72403113	73053119	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403113	73053162	72403113	73053162	72403113	73053162	72403113	73053162	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403113	73053165	72403113	73053165	72403113	73053165	72403113	73053165	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403113	73053171	72403113	73053171	72403113	73053171	72403113	73053171	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403113	73053180	72403113	73053180	72403113	73053180	72403113	73053180	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403114	72406590	72403114	72406590	72403114	72406590	72403114	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00004469217.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403114	72406590	72403114	72406590	72403114	72406590	72403114	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00004469217.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403114	72406590	72403114	72406590	72403114	72406590	72403114	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00004469217.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403114	72406590	72403114	72406590	72403114	72406590	72403114	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00004469217.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403114	73053118	72403114	73053118	72403114	73053118	72403114	73053118	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403114	73053128	72403114	73053128	72403114	73053128	72403114	73053128	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403114	73053152	72403114	73053152	72403114	73053152	72403114	73053152	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403114	73053164	72403114	73053164	72403114	73053164	72403114	73053164	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403116	72406590	72403116	72406590	72403116	72406590	72403116	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00004469221.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403116	73053136	72403116	73053136	72403116	73053136	72403116	73053136	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403117	72406590	72403117	72406590	72403117	72406590	72403117	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00004302380.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403117	73053165	72403117	73053165	72403117	73053165	72403117	73053165	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72403131	72406590	72403131	72406590	72403131	72406590	72403131	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00004302379.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72403131	73053120	72403131	73053120	72403131	73053120	72403131	73053120	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72404160	72406590	72404160	72406590	72404160	72406590	72404160	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00004302382.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72404160	73053177	72404160	73053177	72404160	73053177	72404160	73053177	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72405753	72406590	72405753	72406590	72405753	72406590	72405753	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00004302377.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72405753	73053165	72405753	73053165	72405753	73053165	72405753	73053165	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72406144	72406590	72406144	72406590	72406144	72406590	72406144	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-207	ENST00000490919.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001860286.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72406144	72581407	72406144	72581407	72406144	72581407	72406144	72581407	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-207	ENST00000490919.5_3	protein_coding	protein_coding_CDS_not_defined			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72406258	72406590	72406258	72406590	72406258	72406590	72406258	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-205	ENST00000471335.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001920145.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72406258	72562418	72406258	72562418	72406258	72562418	72406258	72562418	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-205	ENST00000471335.5_3	protein_coding	protein_coding_CDS_not_defined			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72406302	72406590	72406302	72406590	72406302	72406590	72406302	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-208	ENST00000492257.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001257920.5_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72406302	72490566	72406302	72490566	72406302	72490566	72406302	72490566	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-208	ENST00000492257.1_3	protein_coding	protein_coding_CDS_not_defined			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72406438	72406590	72406438	72406590	72406438	72406590	72406438	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003785470.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72406438	73053148	72406438	73053148	72406438	73053148	72406438	73053148	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72406446	72406590	72406446	72406590	72406446	72406590	72406446	72406590	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00004302384.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72406446	73053165	72406446	73053165	72406446	73053165	72406446	73053165	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72410023	72410034	72410023	72410034	72410023	72410034	72410023	72410034	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003785775.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-205	ENST00000471335.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003613302.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-207	ENST00000490919.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003613302.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-208	ENST00000492257.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003613302.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72411204	72411316	72411204	72411316	72411204	72411316	72411204	72411316	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003659181.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72490407	72490566	72490407	72490566	72490407	72490566	72490407	72490566	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-208	ENST00000492257.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001952287.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-205	ENST00000471335.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003648236.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-207	ENST00000490919.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003648236.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562076	72562149	72562076	72562149	72562076	72562149	72562076	72562149	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003523316.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72562376	72562418	72562376	72562418	72562376	72562418	72562376	72562418	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-205	ENST00000471335.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001837949.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72581347	72581407	72581347	72581407	72581347	72581407	72581347	72581407	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-207	ENST00000490919.5_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001879237.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606858	72606999	72606858	72606999	72606858	72606999	72606858	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00001070608.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72606938	72606999	72606938	72606999	72606938	72606999	72606938	72606999	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-204	ENST00000464347.2_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001811892.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72606938	72722668	72606938	72722668	72606938	72722668	72606938	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-204	ENST00000464347.2_3	protein_coding	protein_coding_CDS_not_defined			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72688605	72692468	72688605	72692468	72688605	72692468	72688605	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00001583105.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72688605	73053170	72688605	73053170	72688605	73053170	72688605	73053170	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-204	ENST00000464347.2_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003564749.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72692289	72692468	72692289	72692468	72692289	72692468	72692289	72692468	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003622831.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72707745	72707879	72707745	72707879	72707745	72707879	72707745	72707879	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00001122411.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719414	72719558	72719414	72719558	72719414	72719558	72719414	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00004302387.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719414	72719558	72719414	72719558	72719414	72719558	72719414	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00004302387.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-204	ENST00000464347.2_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003466919.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72719447	72719558	72719447	72719558	72719447	72719558	72719447	72719558	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003552269.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-204	ENST00000464347.2_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003568692.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72722559	72722668	72722559	72722668	72722559	72722668	72722559	72722668	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003570399.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723661	72723583	72723661	72723583	72723661	72723583	72723661	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00004469223.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003504408.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72723583	72723688	72723583	72723688	72723583	72723688	72723583	72723688	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003593937.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72723583	73053134	72723583	73053134	72723583	73053134	72723583	73053134	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003615453.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72725583	72725680	72725583	72725680	72725583	72725680	72725583	72725680	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003479739.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003621915.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727030	72727101	72727030	72727101	72727030	72727101	72727030	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003463493.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72727057	72727101	72727057	72727101	72727057	72727101	72727057	72727101	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001878202.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	transcript	transcript	72727057	72742883	72727057	72742883	72727057	72742883	72727057	72742883	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined			HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003583902.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003583902.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72740261	72740381	72740261	72740381	72740261	72740381	72740261	72740381	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003480917.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003574103.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003574103.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72741763	72741809	72741763	72741809	72741763	72741809	72741763	72741809	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003568204.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-201	ENST00000272427.11_12	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-202	ENST00000410104.1_5	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-203	ENST00000410112.6_4	protein_coding	nonsense_mediated_decay	ENSE00003631773.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00003631773.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-209	ENST00000634650.1_9	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-210	ENST00000862930.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-211	ENST00000862931.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-212	ENST00000862932.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-213	ENST00000862933.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-214	ENST00000862934.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-215	ENST00000862935.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-216	ENST00000862936.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-217	ENST00000862937.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-218	ENST00000971148.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-219	ENST00000971149.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-220	ENST00000971150.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-221	ENST00000971151.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-222	ENST00000971152.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742172	72742255	72742172	72742255	72742172	72742255	72742172	72742255	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-223	ENST00000971153.1_1	protein_coding	protein_coding	ENSE00003483582.1_1		HAVANA	EXOC6B	1	1
2	2	chr2	chr2	HAVANA	exon	exon	72742565	72742883	72742565	72742883	72742565	72742883	72742565	72742883	.	-	.	EXOC6B	EXOC6B	ENSG00000144036.17_15	EXOC6B-206	ENST00000485398.1_3	protein_coding	protein_coding_CDS_not_defined	ENSE00001941138.1_1		HAVANA	EXOC6B	1	1
;;;;
run;
%let local_gtf_ods_html5=1;
ods listing close;
ods html5 path="&AF_OUT" gpath="&AF_OUT" file='regional.html'
 options(bitmap_mode='LINK') image_dpi=400 style=journal;
%SNP_Local_Manhattan_With_GTF(gwas_dsd=work.region,chr_var=CHR,
 AssocPVars=EUR_DIFF_P EUR_FEMALE_P EUR_MALE_P,
 SNP_IDs=rs185665940,SNP_Var=SNP,Pos_Var=BP,gtf_dsd=work.gtf,
 dist2snp=500000,ZscoreVars=EUR_STD_Z EUR_FEMALE_Z EUR_MALE_Z,
 gwas_labels_in_order=Female_minus_male Female Male,
 design_width=640,design_height=580,image_dpi=400,
 dotsize=3,dist2sep_genes=100000,pct4neg_y=1.4,
 fig_fmt=png,makedotheatmap=1,makeheatmapdotintooneline=0,
 SNPs2label_scatterplot_dots=rs185665940,text_rotate_angle=0,
 label_headroom_frac=0.03,label_center_offset=0.65,
 LD_display_mode=heatmap,LD_r2_var=LD_R2,LD_reference_snp=rs185665940,
 heatmap_legend_title=%str(R2 x sign(Z), EUR 1000G),
 LD_heatmap_legend_title=%str(R2 x sign(Z), EUR 1000G),
 verbose=1);
options notes;
ods html5 close;
ods listing gpath="&AF_OUT";
%af_export(data=work.region,name=regional_input);
%af_export(data=work.gtf,name=regional_annotation);
%af_export(data=work.final,name=regional_render);

/* Preserve the native macro-generated template and render named deliverables. */
ods listing gpath="&BOOK_OUT" image_dpi=300 style=journal;
ods graphics / reset=index imagename='multi_gwas_gtf' imagefmt=png width=7.6in height=6.9in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods graphics / reset=index imagename='multi_gwas_gtf' imagefmt=svg width=7.6in height=6.9in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods listing close;
proc template;source BedGraph / file="&BOOK_OUT/multi_gwas_template.sas";run;

/* Export numerical association values for independent checking. */
data work.panel_values;
 set work.region;
 length panel $24;
 array p_values[3] EUR_DIFF_P EUR_FEMALE_P EUR_MALE_P;
 array z_values[3] EUR_STD_Z EUR_FEMALE_Z EUR_MALE_Z;
 do i=1 to 3;
  if i=1 then panel='Female_minus_male';
  else if i=2 then panel='Female';
  else panel='Male';
  P=p_values[i];Z=z_values[i];neglog10P=-log10(P);
  signed_ld=LD_R2*sign(Z);
  output;
 end;
 keep CHR BP SNP panel P Z neglog10P LD_R2 signed_ld;
 format _numeric_ best32.;
run;
proc export data=work.panel_values outfile="&BOOK_OUT/panel_values.csv" dbms=csv replace;run;
%put POC_COMPLETE=multi_gwas_gtf;
