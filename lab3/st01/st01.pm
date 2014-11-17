package ST01;
use strict;

sub st01
{
	my ($q, $global) = @_;
	print $q->header();

	print <<ENDOFTXT;
Self URL: $global->{selfurl}<br>
Student: $global->{student}<br>
<a href="$global->{selfurl}">Back</a>
ENDOFTXT

}

1;
