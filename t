----
On Friday morning, we couldn’t complete the batch tests because Philippe hadn’t yet finished the scripts for the test environment. We eventually managed to run some tests together, and I added a fix for an issue that occurs when the batch runs past midnight.

There’s also a build issue in the pipeline that generates new releases. I’ve opened an incident ticket with the DevOps team because the build fails in the pipeline even though it succeeds locally. We need to wait until the issue is resolved before rerunning the tests with Nathalie.
