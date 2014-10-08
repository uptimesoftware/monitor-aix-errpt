AIX errpt Scanner
---------------

DESCRIPTION
---------------
The AIX errpt Scanner monitor is designed to check the output of errpt on AIX agent 
systems for specific error messages and return an alert if any instances matching
the specified message are found. 

FIELDS

The AIX errpt Scanner monitor includes these monitor specific fields

- Agent Port: This field must match the agent listening port (default 9998).
- # Hours to check: The number of hours offset to have returned from the agent. For 
example if 1 (default) is entered the last 1 hour of errpt messages will be checked
for errors.
- Error ID: Error ID to search for.
- Error Type: Error Type to search for.
- Error Class: Error Class to search for.
- Ignore Error Matching: Ignore errors with this pattern in the description.
- Error Search String: Match errors with this pattern in the description.

The logic of the service monitor work be "anding" all of the check options you have
entered together. For example, by selecting Error Class "Undetermined" and Error Search
String "find me" only messages that match both the Error Class and Search String will
report an error.