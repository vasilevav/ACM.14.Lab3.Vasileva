package ST01;
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
#use DBD::mysql;
my $Myfile='lab2\st01\AbramovData';
my @option_func=
(
\&add,
\&delete,
\&change
);
my @students=();
sub st01
{
	my $q = new CGI;
	my $st =$q->param("menu_");
	my $global = {selfurl => $ENV{SCRIPT_NAME}, menu_=> $st};
	#fromfile();
	FromDB();
	if ($st eq "Add")
		{
			$option_func[0]->($q, $global);
		}
	elsif ($st eq "Delete")
		{
			$option_func[1]->($q, $global);
		}
	elsif ($st eq "Change") 
		{
			$option_func[2]->($q, $global);
		}
	else
	{	
		menu($q, $global);
	}
}

sub PrintAll
{
	my($q, $global) = @_;
	my $id=1;
	print "<table border=\"1\">
   <tr>
	<th>ID</th>
    <th>Name</th>
    <th>Surname</th>
    <th>Group</th>
    <th>Age</th>
	<th>TypeOfStudent</th>
   </tr>";
   foreach	my $item (@students)
	{
		print "<tr> 
			<td>$id</td>
			<td>$item->{name}</td>
			<td>$item->{surname}</td> 
			<td>$item->{group}</td> 
			<td>$item->{age}</td>";
		if(defined $item->{type})	
			{ print "
			<td>$item->{type}</td><td><INPUT TYPE='radio' NAME=\"number_\" value=$id></td></tr>";}
		else 
			{
				print "<td></td><td><INPUT TYPE='radio' NAME=\"number_\" value=$id></td></tr>";
			}	
		$id++;
	}
	print "</table>";
}

sub menu
{
	my($q, $global) = @_;
	my $id=1;
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>Second Lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";
	print "<FORM>
	<HR>List of students. <br>";
	PrintAll($q, $global);
	 print "<P>Name of student:<BR><INPUT NAME=\"name_\" TYPE=TEXT maxsize=100><BR>
	<P>Surname of student:<BR><INPUT NAME=\"surname_\" TYPE=TEXT maxsize=100><BR>
	<P>Group of student:<BR><INPUT NAME=\"group_\" TYPE=TEXT maxsize=100><BR>
	<P>Age of student:<BR><INPUT NAME=\"age_\" TYPE=TEXT maxsize=100><BR>
	<INPUT TYPE='checkbox' NAME=\"starosta_\" VALUE=5>Steward<BR>
	<INPUT TYPE='submit' NAME=\"menu_\" VALUE=Add>  <INPUT TYPE='submit' NAME=\"menu_\" VALUE=Delete>  <INPUT TYPE='submit' NAME=\"menu_\" VALUE=Change> 
	<INPUT TYPE='HIDDEN' NAME='student' VALUE =\"1\"/>
	<INPUT type='reset'> <BR>";
	print "</BODY><BR><BR><a href=\"$global->{selfurl}\">Back to student list.</a><BR></FORM></HTML>";
}
sub TypeOfStudent
{
my($q) = @_;
my $st=0+$q->param('starosta_');
my $type;
if($st==5)
	{
		$type="steward";
	}
}

sub add
{
	my($q, $global) = @_;
	my $name=$q->param('name_');
	my $surname=$q->param('surname_');
	my $group=$q->param('group_');
	my $age=$q->param('age_');
	my $type=TypeOfStudent($q);
	my $k=0+$q->param('number_');
	my $sthash=
			{
				name=>$name,
				surname=>$surname,
				group=>$group,
				age=>$age
			};
	if($type eq "steward")
	{	
		$sthash->{type}=$type;
	}
	if($k!=0)
	{
		$students[$k-1]=$sthash;
	}
	else 
	{push(@students,$sthash);}
	#tofile();
	ToDB();
	menu($q,$global);
}

sub delete
{
	my($q, $global) = @_;
	my $k=0+$q->param('number_');
	if ($k && defined $students[$k-1])
	{ 
		splice(@students,$k-1,1);
		#tofile();
		ToDB();
	}
	menu($q,$global);	
}

sub change
{
	my($q, $global) = @_;
	my $k=0+$q->param('number_');
	my $hashref;
	if (defined $students[$k-1])
	{
	$hashref=$students[$k-1];
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>Second Lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";
	print "<FORM>
	<HR>List of students. <br>";
	PrintAll($q, $global);
	 print "<P>Name of student:<BR><INPUT NAME=\"name_\" TYPE=TEXT maxsize=100 value=$hashref->{name}><BR>
	<P>Surname of student:<BR><INPUT NAME=\"surname_\" TYPE=TEXT maxsize=100 value=$hashref->{surname}><BR>
	<P>Group of student:<BR><INPUT NAME=\"group_\" TYPE=TEXT maxsize=100 value=$hashref->{group}><BR>
	<P>Age of student:<BR><INPUT NAME=\"age_\" TYPE=TEXT maxsize=100 value=$hashref->{age}><BR>
	<INPUT TYPE='checkbox' NAME=\"starosta_\" VALUE=5>Steward<BR>
	<INPUT TYPE='submit' NAME=\"menu_\" VALUE=Add>  <INPUT TYPE='submit' NAME=\"menu_\" VALUE=Delete>  <INPUT TYPE='submit' NAME=\"menu_\" VALUE=Change> 
	<INPUT TYPE='HIDDEN' NAME='student' VALUE =\"1\"/>
	<INPUT TYPE='HIDDEN' NAME='number_' VALUE =\"$k\"/>
	<INPUT type='reset'> <BR>";
	print "</BODY><BR><BR><a href=\"$global->{selfurl}\">Back to student list.</a><BR></FORM></HTML>";
		ToDB();
	}
}

sub ToDB
{
	my $dbh=DBI->connect("DBI:mysql:mydata;localhost:3306", "root", "12345", {RaiseError=>1, AutoCommit=>1});
	my $id=1;
	$dbh->do('SET CHARACTER SET cp1251');
	$dbh->do("TRUNCATE TABLE mydata.students");
	my $sth = $dbh->prepare("INSERT INTO mydata.students(`StudentsID`, `Name`, `Surname`, `Group`, `Age`, `Starosta`) VALUES (?, ?, ?, ?, ?, ?)");
	foreach my $item(@students)
	{	
		$sth->bind_param(1,$id);
		$sth->bind_param(2,$item->{name});
		$sth->bind_param(3,$item->{surname});
		$sth->bind_param(4,$item->{group});
		$sth->bind_param(5,$item->{age});
		if ($item->{type} eq "steward")
		{
			$sth->bind_param(6,'steward');
		}
		else
		{
			$sth->bind_param(6,'');
		}
		$sth->execute();
		$id++;
	}	
	$dbh ->disconnect();
}

sub FromDB
{
	my $dbh=DBI->connect('DBI:mysql:mydata;localhost:3306', "root", "12345", {RaiseError=>1, AutoCommit=>1});
	$dbh->do('SET CHARACTER SET cp1251');
	my $sth = $dbh->prepare ("SELECT * FROM mydata.students;");
	$sth->execute();
	my $id=0;
	while(my $hash_ref = $sth->fetchrow_hashref())
	{	
		my $sthash=
			{
				name=>"$hash_ref->{Name}",
				surname=>"$hash_ref->{Surname}",
				age=>"$hash_ref->{Age}",
				group=>"$hash_ref->{Group}"
			};
		if ($hash_ref->{Starosta} eq "steward")
			{
				$sthash->{type}="$hash_ref->{Starosta}";
			}
		$students[$id]=$sthash;
		$id++;
	}
	$sth->finish();
	$dbh ->disconnect();
};
1
