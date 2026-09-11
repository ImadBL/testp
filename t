
Hello everyone. Today, we’ll show you a demo of the purge batch.

First, we’ll give you a short technical overview of how the batch works 
will focus only on the first part we have implemented, which is the TBC purge, 
and after that will show you how it works in a real scenario.



At the beginning of the TBC purge cycle, we initialize a purge report with the start time.

2. After that the batch searches for old cases in AMX based on their creation date and the maximum number of cases returned. 
The two information are configurable in properties files.

3. the batch discovers eligible TBC cases in AMX, stores them as READY in database

4. (So the TBC cases do not require any archive step) 
Then the batch deletes the case Cancel the process in AMX and updates the status in the batch database.

5. At the end, we update the report with the number of successfully purged cases, the errors, and the end time.

6. we also have eport generation and email notification at the end

i have a point out that The report generation and email notification are still in progress, 
so for today’s demo we’ll mainly show the database records and the purge results.

Tristan, you can add something if you have any other information to share.

Now we can move to the demo.

First, in our configuration, we have a retention period of 22 months. This means we will purge all cases created before 11 November 2024.

Why this date? Because:
11 September 2026 minus 22 months = 11 November 2024.

According to Spotfire, we currently have around 102 cases matching this criteria.

There may be a small difference in the final number because the creation time is also included in the criteria, not only the date.

In our current configuration, we have:
22 months for the retention period and 50 cases as the maximum number processed in one search.

Now we can launch the purge and start the batch.

And after that, we check the database to see the result.






he save the cases and clean them after the purge and générâtes the report


The objective of the demo is to show how , purges them, generates one purge report, and cleans only the rows successfully purged.

I’ll also point out that the report generation and email sending are not finished yet. They are still in progress.

For today’s demo, you will only see the database records showing the purge operation and all the related data.
