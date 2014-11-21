package ST21;
use strict;
use warnings;
use CGI;
use DBI;

print "Content-type: text/html\n\n";

my %list = (
	1 => 'Add',
	2 => 'Edit',
	3 => 'Delete',
	4 => 'Show_all');
	
my %Items =();

sub st21
{
	my ($q, $global) = @_;
	my $q = new CGI;
	my $choice = $q->param('choice');
	Load_from_DB();
	if(defined $choice)
	{
		my $func_call = \&{$list{$choice}};
		&$func_call($q, $global);
	}
	else
	{
		menu($q, $global);
	}	
	print "</BODY><a href=\"$global->{selfurl}?student=$global->{student}\">Íàçàä</a><BR></HTML>";
}

sub menu
{
	my($q, $global) = @_;
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>3nd lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";

	foreach my $name (sort keys %list)
	{
		print "<li> <a href=\"$global->{selfurl}?choice=$name&student=$global->{student}\" > $list{$name} </a>	</li>";
	}
	
	print "</ul></menu><hr>";	
}

sub printForm
{
	my ($q, $global) = @_;
	my $value = 0+$q->param('choice');
	if(defined $value && $value != 3)
	{
		print qq~<FORM action="$global->{selfurl}" name = SaveAndUpd>
			    ÔÈÎ:<BR>
			    <input type=text width = 40 name = "name_"> <BR>
			    Ïîçèöèÿ:<BR>
			    <input type=text width = 40 name = "pos_"> <BR>
			    Âîçðàñò:<BR>
			    <input type=text width = 40 name = "age_"> <BR>
			    Êëóá:<BR>
			    <input type=text width = 40 name = "club_"> <BR>
			    Êàïèòàí:<BR>
			    <input type=text width = 40 name = "cap_"> <BR>
			    <INPUT TYPE="HIDDEN" NAME="choice" VALUE ="$value"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$global->{student}/>
			    <input type = submit name = "btn" value = "Ñîõðàíèòü"/><BR>
		    </FORM>~;
	}elsif(defined $value)
	{
		print qq~<FORM action="$global->{selfurl}" name = SaveAndUpd>
			    ÔÈÎ:<BR>
			    <input type=text width = 40 name = "name_"> <BR>
			    <INPUT TYPE="HIDDEN" NAME="choice" VALUE ="$value"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$global->{student}/>
			    <input type = submit name = "btn" value = "Ñîõðàíèòü"/><BR>
		    </FORM>~;		
	}
}

sub Add
{
	my ($q, $global) = @_;
	
	my $name = $q->param('name_');
	my $pos = $q->param('pos_');
	my $age = 0+$q->param('age_');
	my $club = $q->param('club_');
	my $cap = '0';
	
	if(defined $q->param('cap_'))
	{
		$cap = '1';	
	}
	if(!defined $name)
	{
		    printForm($q, $global);
	}
	else
	{
		
		my $dsn = 'DBI:mysql:shilenkovdb:localhost:3306';
		my $user = 'root';
		my $pass = '';
		my $dbh = DBI->connect($dsn, $user, $pass, {RaiseError => 1, AutoCommit => 1});
		$dbh->do("INSERT INTO bestplayers (DBname, DBpos, DBage, DBclub, DBcap) VALUES (?,?,?,?,?)", undef, ($name, $pos, $age, $club, $cap));
		$dbh->disconnect();
				
		push(@{$Items{$name}}, $pos, $age, $club, $cap);
	}
}

sub Edit
{
	my ($q, $global) = @_;
	
	Show_all($q, $global);
	
	my $name = $q->param('name_');
	my $pos = $q->param('pos_');
	my $age = 0+$q->param('age_');
	my $club = $q->param('club_');
	my $cap = $q->param('cap_');	
	
	if(!defined $name)
	{
		    printForm($q, $global);
	}elsif(exists($Items{$name}))
	{
		@{$Items{$name}}[0] = $pos;
		@{$Items{$name}}[1] = $age;
		@{$Items{$name}}[2] = $club;
		@{$Items{$name}}[3] = $cap;
		
		my $dsn = 'DBI:mysql:shilenkovdb:localhost:3306';
		my $user = 'root';
		my $pass = '';
		my $dbh = DBI->connect($dsn, $user, $pass, {RaiseError => 1, AutoCommit => 1});
		$dbh->do("UPDATE bestplayers SET DBname = ?, DBpos = ?, DBage = ?, DBclub = ?, DBcap = ?) VALUES (?,?,?,?,?)", undef, ($name, $pos, $age, $club, $cap));
		$dbh->disconnect();		
	}else
	{
		print "\nÍåò òàêîãî èãðîêà\n\n";
	};
}
 
sub Delete
{
	my ($q, $global) = @_;
	
	Show_all($q, $global);
	
	my $name = $q->param('name_');
	
	if(!defined $name)
	{
		    printForm($q);
	}elsif(exists($Items{$name}))
	{
		delete($Items{$name});
		
		my $dsn = 'DBI:mysql:shilenkovdb:localhost:3306';
		my $user = 'root';
		my $pass = '';
		my $dbh = DBI->connect($dsn, $user, $pass, {RaiseError => 1, AutoCommit => 1});
		$dbh->do("DELETE FROM bestplayers WHERE DBname = ?", undef, ($name));
		$dbh->disconnect();
	}
	else
	{
		print "\nÍåò òàêîãî èãðîêà:\n\n";
	}
}

sub Show_all
{
	print "==========================<br>";
	foreach my $name (keys %Items)
	{
		print "<li>$name: @{$Items{$name}}</li>";
	}	
	print "==========================<br>";
}

sub Load_from_DB
{	
	my $dsn = 'DBI:mysql:shilenkovdb:localhost:3306';
	my $user = 'root';
	my $pass = '';
	my $dbh = DBI->connect($dsn, $user, $pass, {RaiseError => 1, AutoCommit => 1});
	my $sql = $dbh->prepare('SELECT DBname, DBpos, DBage, DBclub, DBcap FROM bestplayers order by DBname');
	$sql->execute();
	while(my $value = $sql->fetchrow_hashref())
	{
		push(@{$Items{$$value{'DBname'}}}, $$value{'DBpos'}, $$value{'DBage'}, $$value{'DBclub'}, $$value{'DBcap'});
	}
	$sql->finish();
	$dbh->disconnect();
}

#return 1;
#st21();
1;
