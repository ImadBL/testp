Hi team,

We’ve identified the root cause of the import failure: the XLSX file contains empty rows at the bottom, and those rows trigger the mandatory-field validation, which causes the job to fail (and eventually reach the skip limit).

A fix has already been added to the next release to:

* ignore fully empty rows and stop reading after the last row that contains actual data (so trailing blank lines won’t cause errors), and
* avoid creating cases if an error occurs during the process, to prevent duplicates.

In the meantime, could you please clean up the Excel file by properly deleting the empty rows at the bottom (select the rows and **Delete rows**, not just “Clear contents”) before re-submitting?

Before retrying, please also check the cases that have already been created to avoid duplicates.

Thanks,
Imad BELMOUJAHID
