*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P005_IN                                     *
*----------------------------------------------------------------------*
*-----Tables
TABLES : pernr      ,  pcl1       , pcl2       , s001       ,
         sscrfields , tka02.
*-----Table internal table definitions
DATA : gt_t7trg01 LIKE t7trg01 OCCURS 0 WITH HEADER LINE,
*      ZBYHR_T003   like  ZBYHR_T003   occurs 0 with header line,
       zbyhr_t004 LIKE  zbyhr_t004   OCCURS 0 WITH HEADER LINE,
*      ZBYHR_T006   like  ZBYHR_T006   occurs 0 with header line,
       zbyhr_t007 LIKE  zbyhr_t007   OCCURS 0 WITH HEADER LINE,
       zbyhr_t005 LIKE  zbyhr_t005   OCCURS 0 WITH HEADER LINE,
       zbyhr_t008 LIKE  zbyhr_t008  OCCURS 0 WITH HEADER LINE.
*-----İnfotypes
INFOTYPES : 0000,
            0001,
            0002,
            0008,
            0769.
*-----İncludes
INCLUDE rpc2cd00.
INCLUDE rpc2rxx0.
INCLUDE rpc2rx00.
INCLUDE rpppxd00.
INCLUDE rpppxd10.
INCLUDE rpppxm00.
INCLUDE pc2rxtr0.
*-----field-symbols
FIELD-SYMBOLS: <n_fnam_m> TYPE any,
               <n_fnam_s> TYPE any,
               <o_fnam_m> TYPE any,
               <o_fnam_s> TYPE any.
RANGES : gr_apznr FOR rt-apznr ."Split için, SerenK 10052012

DATA: sortfnam(10),
      sortfval(25).
*---EVIRM = WAGES
FIELD-SYMBOLS : <w_mul>,
                <w_div>.
*-----Period table
DATA : BEGIN OF f OCCURS 0,
         fpper    LIKE   s001-spmon,
         begda    LIKE   p0001-begda,
         endda    LIKE   p0001-begda,
         multi(8) TYPE p,
         divid(8) TYPE p,
       END OF f.
*-----Period table
DATA : BEGIN OF fp OCCURS 0,
         prmod(10) TYPE   c,
         low       LIKE   s001-spmon,
         high      LIKE   s001-spmon,
         txt       LIKE   t512t-lgtxt,
       END OF fp.
*-----Memory Exported İmported Personel
DATA : BEGIN OF pcf,
         pernr LIKE   p0001-pernr,
         fpper LIKE   s001-spmon,
       END OF pcf,
       pim LIKE pcf OCCURS 0,
       pex LIKE pcf OCCURS 0       WITH HEADER LINE,
       pc  LIKE pcf-pernr,
       BEGIN OF ppcf,
         fpper    LIKE   s001-spmon,
         count(4) TYPE   i,
       END OF ppcf.
*-----Wage types
DATA : BEGIN OF wt OCCURS 0,
         lgtxt   LIKE   t512t-lgtxt,
         lgart   LIKE   t512t-lgart,
         sumsign TYPE   c,
       END OF wt.
*-----selected wage type
DATA : wts   LIKE wt OCCURS 0 WITH HEADER LINE,
       wts_t LIKE wt OCCURS 0 WITH HEADER LINE.
*-----period and period wages
DATA : BEGIN OF w OCCURS 0,
         fpper LIKE   s001-spmon,
         lgart LIKE   t512t-lgart,
         amt   LIKE   regup_bf-dmbtr,
         num   LIKE   pc207-anzhl,
         c_amt LIKE   regup_bf-dmbtr,
         per   LIKE   tcurr-ukurs,
       END OF w.
DATA : wx LIKE w OCCURS 0 WITH HEADER LINE.
*-----Source Personel Table
DATA : BEGIN OF p OCCURS 0,
         pernr    LIKE   p0001-pernr,
         fpper    LIKE   s001-spmon,
         bukrs    LIKE   p0001-bukrs,
         werks    LIKE   p0001-werks,
         btrtl(9) TYPE   c,
         kanun    LIKE   p0769-kanun,
         sskno(9) TYPE   c, " LIKE   t7trg01-sskno,
         kostl    LIKE   p0001-kostl,
         abkrs    LIKE   p0001-abkrs,
         orgeh    LIKE   p0001-orgeh,
         stell    LIKE   p0001-stell,
         persg    LIKE   p0001-persg,
         persk    LIKE   p0001-persk,
         ansvh    LIKE   p0001-ansvh,
         pergr    LIKE   zbyhr_t005-pergr,
         trfgr    LIKE   p0008-trfgr,
         trfst    LIKE   p0008-trfst,
         gesch    LIKE   p0002-gesch,
         mstbr    LIKE   p0001-mstbr,
         sgmnt    LIKE   p0001-sgmnt,
         setna    LIKE   setheader-setname,  "Masraf  Yeri hiyerarşi
         sinif    LIKE   p0001-zzpersnf,
         "depar    LIKE   p0001-zzdepartman,
         femod    TYPE   c          , "Full ALL NULL
         w        LIKE   w  OCCURS 0,
       END OF  p.
*------Variable  Tables
DATA : BEGIN OF v OCCURS 0           ,
         fnam(10) TYPE  c,
         fval(10) TYPE  c,
         fadd(10) TYPE  c,
         ftxt(25) TYPE  c,
       END OF v.
*---Variable Selected Master
DATA : BEGIN OF vsm OCCURS 0  ,
         fval_m(10) TYPE  c,
         fval_s(10) TYPE  c,
       END OF vsm             .
*---Variable Summury Table
DATA : BEGIN OF vsum                   ,
         w        LIKE   w   OCCURS 0,
         wo       LIKE   w   OCCURS 0,
         count(4) TYPE   i            , "Personel Count ALL
         pc       LIKE   pc  OCCURS 0 , "Personel Count with period
         pcf      LIKE   pcf OCCURS 0 , "Personel ALL
         ppcf     LIKE   ppcf OCCURS 0, "Personel with monttly
       END OF vsum                     .
*---Variable Output Master Table
DATA : BEGIN OF vom OCCURS 10         ,
         fval_m(10) TYPE  c,
         ftxt_m(25) TYPE  c,
         betsq      LIKE  regup_bf-dmbtr.
         INCLUDE STRUCTURE vsum        .
DATA   END OF vom                     .
*---Variable Output Slave Table
DATA : BEGIN OF vos OCCURS 10          ,
         fval_m(10) TYPE  c,
         fval_s(10) TYPE  c,
         ftxt_s(25) TYPE  c,
         betsq      LIKE regup_bf-dmbtr.
         INCLUDE STRUCTURE vsum         .
DATA  END OF vos                       .
*-----Variable TEXT proporties
DATA : BEGIN OF vp OCCURS 0,
         ftxt_t LIKE zbyhr_t006-ftxt_t,
         fnam   LIKE zbyhr_t006-fnam,
         ftxt_n LIKE zbyhr_t006-ftxt_n,
         flen_n LIKE zbyhr_t006-flen_n,
         flen_t LIKE zbyhr_t006-flen_t,
       END OF vp,
       vps LIKE vp OCCURS  0 WITH HEADER LINE.
*-----Newmod_Oldmod
DATA: BEGIN OF newmod,
        ucomm(10)  TYPE  c,           " UCOMM
        nrmod(10)  TYPE  c,           " AMT NUM C_AMT
        nrpmd(10)  TYPE  c,           " NRROW NRCOL TOTAL
        prmod(10)  TYPE  c,           " SUMPR  PR001 PR003 PR006 PR012
        femod(10)  TYPE  c,           " FULL  ALL EMPTY
        evirm(10)  TYPE  c,           " EVIRMOD
        fnam_m(10) TYPE  c,           " Master Variable
        fnam_s(10) TYPE  c,           " Slave Variable
        lsind      TYPE  i,           " Listno
      END OF newmod.
DATA  oldmod  LIKE  newmod.
*-----hr-display-list-for excel
DATA: header  LIKE hrfieldnam OCCURS 20 WITH HEADER LINE,
      datatab LIKE hrdatatab  OCCURS 20 WITH HEADER LINE.
*-----Grafik Master Table
DATA : BEGIN OF grp OCCURS 32,
         ftxt(16) TYPE   c,
         amt      LIKE   regup_bf-dmbtr,
       END OF grp.
*---exclude
DATA  fcode  LIKE  rsmpe-func OCCURS 0.
*---Ranges
RANGES : femod   FOR p-femod    ,
         a_bukrs FOR p0001-bukrs.
*---Constants
CONSTANTS scurr LIKE tcurr-tcurr VALUE 'TRL  '.
*---Masraf yeri Hiyerarşi Grupları
DATA : BEGIN OF setna OCCURS 0,
         setname LIKE setnode-subsetname,
         kostl   LIKE setleaf-valfrom,
       END OF setna.
*---Data Definition
DATA : index      TYPE    i,
       lines      TYPE    i,           " Liste Kayıt Sayısı
       row_len    TYPE    i,
       first      TYPE    c,
       head       TYPE    c,
       fnam_m(10) TYPE   c,
       fnam_s(10) TYPE   c,
       box        TYPE    c,
       lmn(2)     TYPE    n,           " Length Master Name
       lmt(2)     TYPE    n,           " Length Master Text
       lsn(2)     TYPE    n,           " Length Slave  Name
       lst(2)     TYPE    n,           " Length Slave  text
       evirm(20)  TYPE    c.

*---Data Definitions
DATA: gv_val       LIKE dd07v-domvalue_l,
      gv_txt       LIKE dd07v-ddtext,
      gv_text(101).
