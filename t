----

 the fault tolerance mechanism automatically switches over to the secondary EMS server in the event of a failure. However, the batch is currently configured to connect only to the primary server. The system is expected to switch back to the primary server at the next restart, scheduled for Monday.

We therefore have two options:

Keep the current configuration and wait until Monday, when the batch should resume normal operation.

Add the secondary EMS server URL to the batch configuration to handle this failover. This change requires redeploying the batch.
