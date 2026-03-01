*----------------------------------------------------------------------*
*   INCLUDE ZPEKIDEM                                                   *
*----------------------------------------------------------------------*
* User exit için ilave formlar

*&---------------------------------------------------------------------*
*&      Form  KIDTAR_USEREXIT
*&---------------------------------------------------------------------*
* Kıdem dönem başı ve dönem sonu tarihlerinin değiştirilebilmesi için
* Programın Akışının Değişmemesi için bu formda sadece
* Kidendda ve Kidbegda alanları değiştirilebilir.
*----------------------------------------------------------------------*
FORM KIDTAR_USEREXIT.
* Yapılan standart işlem aşağıdaki gibidir
* IF potkidem = 'X'.            "Potansiyel Kıdem Hesabı Olup Olmadığı?
*   kidendda = pottarih.        "Potansiyel Kıdem Tarihi
*   kidem döneminin içinde bulunduğu ayın ilk ve son gününü bulur...
*   PERFORM kidemtarihleri USING kidendda kidbegda.
*   ve kidendda ile kidbegda ya yazar
*   kidendda = pottarih.        "Potasiyel hesap tarihini tekrar atar
* ELSE.
*   kidendda+0(4) = norkdyil.
*   kidendda+4(2) = norkiday.
*   kidendda+6(2) = '01'.
*   kidem döneminin içinde bulunduğu ayın ilk ve son gününü bulur...
*   PERFORM kidemtarihleri USING kidendda kidbegda.
*   ve kidendda ile kidbegda ya yazar
* ENDIF.
ENDFORM.                               " KIDTAR_USEREXIT
*&---------------------------------------------------------------------*
*&      Form  DAY_COMPUTE_USREXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DAY_COMPUTE_USREXIT.

ENDFORM.                    " DAY_COMPUTE_USREXIT
*&---------------------------------------------------------------------*
*&      Form  ON_COMPENSATION_USER_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ON_COMPENSATION_USER_EXIT.
* iper-kidem = iper-kidem + ( iper-ktime+0(4) *   iper-k1yil ).
* iper-kidem = iper-kidem + ( iper-ktime+4(2) * ( iper-k1yil / 12  ) ).
* iper-kidem = iper-kidem + ( iper-ktime+6(2) * ( iper-k1yil / 360 ) ).
ENDFORM.                    " ON_COMPENSATION_USER_EXIT
*&---------------------------------------------------------------------*
*&      Form  ON_POTANTIAL_WO9005_USER_EXIT
*&---------------------------------------------------------------------*
* default values:
* i9005-knorm = 1.   0 = kıdem almaz 1 = Normal kıdem 2 = İlaveli Kıdem
* i9005-fprtg = 0.
* i9005-kidtg = 30.   kıdemi 30 gün üzerinden hesaplar
* i9005-fagan = 1.    0 = ihbar almaz 1 = ihbar alır
* please don't make any changes if you are not sure what you do
*----------------------------------------------------------------------*
* Potansiyel kıdem hesaplamasında 9005 bilgi tipine kayıt girilmediği
*  taktirde işlem yapılabilmesi için tanımlanan değerler.
*----------------------------------------------------------------------*
FORM ON_POTANTIAL_WO9005_USER_EXIT.
* I9005-KNORM = 1.
* I9005-FPRTG = 0.
* i9005-prznt = 100.
* i9005-kidpr = 100.
* I9005-KIDTG = 30.
* I9005-FAGAN = 1.
* append i9005.

 I0776-KNORM = 1.
 I0776-FPRTG = 0.
 i0776-prznt = 100.
 i0776-kidpr = 100.
 I0776-KIDTG = 30.
 I0776-FAGAN = 1.
 append i0776.

ENDFORM.                    " ON_POTANTIAL_WO9005_USER_EXIT
*&---------------------------------------------------------------------*
*&      Form  ON_NORMAL_WO9005_USER_EXIT
*&---------------------------------------------------------------------*
* default values:
* i9005-knorm = 0.   0 = kıdem almaz 1 = Normal kıdem 2 = İlaveli Kıdem
* i9005-fprtg = 0.
* i9005-kidtg = 30.  kıdemi 30 günl üzerinden hesaplar
* i9005-fagan = 1.   0 = ihbar almaz 1 = ihbar alır
* please don't make any changes if you are not sure what you do
*----------------------------------------------------------------------*
* Normal kıdem hesaplamasında 9005 bilgi tipine kayıt girilmediği
*  taktirde işlem yapılabilmesi için tanımlanan değerler.
*----------------------------------------------------------------------*
FORM ON_NORMAL_WO9005_USER_EXIT.
* I9005-KNORM = 0.
* I9005-FPRTG = 0.
* I9005-KIDTG = 30.
* I9005-FAGAN = 1.
ENDFORM.                    " ON_NORMAL_WO9005_USER_EXIT
*&---------------------------------------------------------------------*
*&      Form  ON_CALC_IHBAR_USER_EXIT
*&---------------------------------------------------------------------*
*  YPCKIDEM programı giydirilmiş ücret üzerinden ihbar hesaplar
*  eğer ek ödemeler dahil olmadan hesaplanacak şekilde değiştirmek için
*  formun içindeki satırı aşağıdaki gibi değiştirin
*     iper-ihbar = iper-betrg / 30 * iper-ihgun.
*----------------------------------------------------------------------*
*  iper-ihbar             ihbar hakedişi
*  iper-topla             giydirilmiş brüt ücret
*  iper-betrg             brüt ücret
*  iper-ihgun             ihbar hesaplamasına esas gün
*----------------------------------------------------------------------*
FORM ON_CALC_IHBAR_USER_EXIT.
*    iper-ihbar = iper-topla / 30 * iper-ihgun.
ENDFORM.                    " ON_CALC_IHBAR_USER_EXIT
*&---------------------------------------------------------------------*
*&      Form  ON_CALC_2001_USER_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ON_CALC_2001_USER_EXIT.

ENDFORM.                    " ON_CALC_2001_USER_EXIT


*&---------------------------------------------------------------------*
*&      Form  UE_vor_Batch_Mappe
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UE_vor_Batch_Mappe.
* LOOP AT iper.
*   if iper-ihbar lt 0.
*      iper-ihbar = iper-ihbar * -1.
*      modify iper.
*   endif.
* endloop.
ENDFORM.                    " UE_vor_Batch_Mappe
*


*&---------------------------------------------------------------------*
*&      Form  ue_artis_flag
*&---------------------------------------------------------------------*
form ue_artis_flag.
* h_ue_artis_flag = 'X'.
endform.                    " ue_artis

form ue_custom_artis.
* tables: z9ypk.
* data: iz9ypk like z9ypk occurs 0 with header line.
*    REFRESH iz9ypk. CLEAR iz9ypk.
*    SELECT * FROM z9ypk INTO TABLE iz9ypk WHERE persg EQ p0001-persg
*                  AND persk EQ p0001-persk AND datum GT rgdir-fpend.
*    SORT iz9ypk BY datum ASCENDING.
*    LOOP AT iz9ypk.
*      IF NOT iz9ypk-prznt IS INITIAL.
*        iper-betrg = iper-betrg + ( iper-betrg * iz9ypk-prznt ).
*      ENDIF.
*      IF NOT iz9ypk-betrg IS INITIAL.
*        iper-betrg = iper-betrg + iz9ypk-betrg.
*      ENDIF.
*    ENDLOOP.
endform.                    " ue_custom_artis



*&---------------------------------------------------------------------*
*&      Form  ue_child
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form ue_child.
* Max. 2 cocuk için t9ytx deki deger hesaplanır.
*  kidbetrg = p9004-child * t9ytx-cocuk.
endform.                    " ue_child

 FORM COUNT_COCUK.
* çocuk yardımı
*   RP-READ-INFOTYPE PERNR-PERNR 9004 P9004 IPER-FIRED IPER-FIRED.
*   PERFORM RE9Y1P USING P0001-WERKS P0001-BTRTL.
*   SELECT * FROM T9YTX WHERE GRTAX EQ T9Y1P-GRTAX AND
*                             SSKGR EQ P9004-SSKGR AND
*                             BEGDA LE IPER-FIRED AND
*                             ENDDA GE IPER-FIRED.
*   ENDSELECT.
*   IF P9004-CHILD GT 2.
*     P9004-CHILD = 2.
*   ENDIF.
*   KIDBETRG = P9004-CHILD * T9YTX-COCUK.
*   PERFORM UE_CHILD.
*   PERFORM APPEND_RTAB USING WTY_9CHD KIDBETRG 'Çocuk Parası'.

  RP-READ-INFOTYPE PERNR-PERNR 0769 P0769 IPER-FIRED IPER-FIRED.
  perform re7trg04 using p0001-werks p0001-btrtl.
  select * from t7trt02 where grtax eq t7trg04-grtax and
                            sskod eq p0769-sskod and
                            ssgrp eq p0769-ssgrp and
                            begda le iper-fired and
                            endda ge iper-fired.
  endselect.
  if p0769-child gt 2.
    p0769-child = 2.
  endif.
  kidbetrg = p0769-child * t7trt02-cocuk.


*    PERFORM ue_child.
  perform append_rtab using wty_9chd kidbetrg 'Çocuk Parası'.

 ENDFORM.                               " COUNT_COCUK
*&---------------------------------------------------------------------*
*&      Form  RE7TRG04
*&---------------------------------------------------------------------*
form re7trg04 using    $werks
                     $btrtl.
  check t7trg04-werks ne $werks or t7trg04-btrtl ne $btrtl.
  select single * from t7trg04 where werks eq $werks
                             and   btrtl eq $btrtl.
  if sy-subrc ne 0.
    clear t7trg04.
  endif.

endform.                                                    " RE9Y1P
