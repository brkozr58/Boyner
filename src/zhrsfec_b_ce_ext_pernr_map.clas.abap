class ZHRSFEC_B_CE_EXT_PERNR_MAP definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_HRSFEC_CE_EXT_PERNR_MAP .
protected section.
private section.
ENDCLASS.



CLASS ZHRSFEC_B_CE_EXT_PERNR_MAP IMPLEMENTATION.


  method IF_HRSFEC_CE_EXT_PERNR_MAP~MAP_EXT_PERNR.
*   This sample code shows how the personnel number that
*   defines the PERNR for external numbering of the Employee Central Payroll employee is derived
*   from the EMPLOYMENT_ID of the correspnonding employment of the Employee Central employee data.
*

*   Comment:
*   1. If EV_PERNR_EXTERNAL is initial, employee master data replication uses
*      internal numbering to define the personnel number of the employee.

* If you are using global assignments or more than one employment, it is recommended
* to use only internal numbering or to use the field IS_EMPLOYMENT_INFORMATION-EMPLOYMENT_ID
* and not is_person-person_id_external. Each new employment needs a new personnel number.
* In case you are using intercompany transfers (company change in Job Information), you should use
* internal numbering only. Do so by clearing ev_pernr_external.


*  ATTENTION:
*   The EMPLOYMENT_ID/PERSON_ID_EXTERNAL of the Employee Central employee data is a
*   character string with numeric digits only and a maximum length of 8 digits.
*   return external employee id
clear ev_pernr_external.
*    ev_pernr_external = IS_EMPLOYMENT_INFORMATION-EMPLOYEE_ID.
ev_pernr_external = IS_EMPLOYMENT_INFORMATION-ASSIGNMENTIDEXTERNAL.
"yıldızlandı ECK 03.10.2024
*ev_pernr_external = is_person-person_id_external.
"yıldızlandı ECK 03.10.2024
  endmethod.
ENDCLASS.
