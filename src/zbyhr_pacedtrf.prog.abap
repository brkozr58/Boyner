*****************************   PAYSLIP    *****************************
*                                                                      *
* Bu include'u kopyalayarak T596F tablosuyla birlikte müþteri bordro   *
* zarfý ismini otomatik getirebilirsiniz.                              *
*                                                                      *
* You can get customer payslip name on HTRCALC0 with copying this      *
* include  and T596F                                                   *
************************************************************************
REPORT zbyhr_pacedtrf MESSAGE-ID hrpaytr01 LINE-SIZE 132.
*----------------------------------------------------------------------*
FORM cedt USING $formular.
*
  $formular = '-BOY' .
*
ENDFORM.                    "cedt
*
