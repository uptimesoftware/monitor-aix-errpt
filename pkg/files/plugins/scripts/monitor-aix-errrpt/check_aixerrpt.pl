#!/usr/bin/perl

# Check AIX Errpt Plug-in Monitor
# -- monitoring station script
# -- Desc: This script calls the errpt.sh script on your agent
# --	system and parses the output for specific messages
# Get input variables
my $AGENT_HOSTNAME = $ENV{UPTIME_HOSTNAME};
my $AGENT_PASS = $ENV{UPTIME_PASSWORD};
my $AGENT_PORT = $ENV{UPTIME_PORT};
my $OFFSET = $ENV{UPTIME_OFFSET};
my $CHECK_ID = $ENV{UPTIME_ID};
my $CHECK_CLASS = $ENV{UPTIME_CLASS};
my $CHECK_TYPE = $ENV{UPTIME_TYPE};
my $CHECK_IGNORE = $ENV{UPTIME_IGNORE};
my $CHECK_TEXT = $ENV{UPTIME_TEXT};
my $NETCAT;
my $TMP_FILE;
# Set some defaults, these will need to change depending on platform


if (-e "/etc/hosts")
{
$NETCAT = "./agentcmd";
$TMP_FILE = "../tmp/check_aixerrpt.${AGENT_HOSTNAME}.$$";
}
else 
{
$NETCAT = "agentcmd";
$TMP_FILE = "..\\tmp\\check_aixerrpt.${AGENT_HOSTNAME}.$$";
}

# Potential Logging Variables
# Error classes
#	H hardware
#	S software
#	O errlogger diagnostic messages
#	U undetermined error 
# Error types
#	INFO informative (I)
#	TEMP temporary (T)
#	UNKN unknown (U)
#	PERM permanent (P)

# Logic Breakdown
	# The ignore patterns will be applied first.
	# The error class + error type will be applied next.
	# The ID / description regex match will be applied last

# Processing begins

# Contact agent and save output
$CMD = "$NETCAT -p $AGENT_PORT $AGENT_HOSTNAME print_errpt $OFFSET > $TMP_FILE";
`$CMD`;
#print "$CMD";
open( FH, $TMP_FILE );
while ( <FH> ) {

        chomp;
	if ( $_ =~ /IDENTIFIER/ )
	{	
		goto SKIPOVER;
	}

	@line = split( ' ' , $_ ); 
	$ID = shift(@line);
	$DUMMY = shift(@line);
	$TYPE = shift(@line);
	$CLASS = shift(@line);
	$RESOURCE = shift(@line);
	$TEXT = join(' ', @line);
#print "\nLine $ID | $TYPE | $CLASS | $RESOURCE | $TEXT ";

	# check for ignore pattern
	if ( $CHECK_IGNORE )
	{
		if ( $TEXT =~ /$CHECK_IGNORE/ )
		{
			# this desc matches our ignore so skip this line
			goto SKIPOVER;
		} 
	}

	# check for class + type parameters
	# if both class/type are set both must be true to be valid
	# if only one of class/type is set only it needs to be true
	if ( $TYPE eq "P" ) {
		$TYPE = "Permanent";
	} elsif ( $TYPE eq "T" ) {
		$TYPE = "Temporary";
	} elsif ( $TYPE eq "I" ) {
		$TYPE = "Information";
	} elsif ( $TYPE eq "U" ) {
		$TYPE = "Unknown";
	} else {
		$TYPE = "OTHR";
	}
	if ( $CLASS eq "H" ) {
		$CLASS = "Hardware";
	} elsif ( $CLASS eq "S" ) {
		$CLASS = "Software";
	} elsif ( $CLASS eq  "O" ) {
		$CLASS = "Errorlogger";
	} elsif ( $CLASS eq "U" ) {
		$CLASS = "Undetermined";
	} else {
		$CLASS = "OTHR";
	}
	if ( $CHECK_TYPE && $CHECK_CLASS && $CHECK_TEXT)
	{	
		if ( $TYPE =~ /$CHECK_TYPE/ && $CLASS =~ /$CHECK_CLASS/ && $TEXT =~ /$CHECK_TEXT/)
		{
			$ERR_FOUND = 1;
		} else {
			$ERR_FOUND = 0;
		}
	}
	elsif ( $CHECK_TYPE && $CHECK_TEXT)
	{
		if ( $TYPE =~ /$CHECK_TYPE/ && $TEXT =~ /$CHECK_TEXT/ )
		{
			$ERR_FOUND = 1;
		} else {
			$ERR_FOUND = 0;
		}
	}
	elsif ( $CHECK_CLASS && $CHECK_TEXT)
	{
		if ( $CLASS =~ /$CHECK_CLASS/ && $TEXT =~ /$CHECK_TEXT/ )
		{
			$ERR_FOUND = 1;
		} else {
			$ERR_FOUND = 0;
		}
	}
	elsif ( $CHECK_TYPE && $CHECK_CLASS )
	{	
		if ( $TYPE =~ /$CHECK_TYPE/ && $CLASS =~ /$CHECK_CLASS/ )
		{
			$ERR_FOUND = 1;
		} else {
			$ERR_FOUND = 0;
		}
	} else {
		if ( $CHECK_TYPE )
		{
			if ( $TYPE =~ /$CHECK_TYPE/ )
			{
				$ERR_FOUND = 1;
			} else {
				$ERR_FOUND = 0;
			}
		} elsif ( $CHECK_CLASS ) {
			if ( $CLASS =~ /$CHECK_CLASS/ )
			{
				$ERR_FOUND = 1;
			} else {
				$ERR_FOUND = 0;
			}
		}
		elsif ( $CHECK_TEXT ) 
		{
			if ( $TEXT =~ /CHECK_TEXT/ )
			{
				$ERR_FOUND = 1;
			} else {
				$ERR_FOUND = 0;
			}
		} 
	}

	# check for text/id match
		if ( $CHECK_ID )
		{
			if ( $ID =~ /$CHECK_ID/ )
			{
				$ERR_FOUND = 1;
			} else {
				$ERR_FOUND = 0;
			}
		} 
	# set our status line
	if ( $ERR_FOUND == 1)
	{
		$ERR_MASTER = true;
		# to change the format of the status message, change this line
		$ERR_TEXT = "CRIT ".$RESOURCE." Message: ".$TEXT."\n";
	}
	SKIPOVER:
}
close( FH );
unlink( "$TMP_FILE" );

if ( $ERR_MASTER )
{
	print $ERR_TEXT;
	exit ( 2 );
} else {
	print "OK - No matching errors found";
	exit (0 );
}

exit ( 0 );

