package ST01;
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use DBD::mysql;

my $Myfile='lab2\st01\AbramovData';
my @menu=
(
"Add object",
"Change",
"Delete",
"Print all elements"
);

my @option_func=
(
\&add,
\&delete,
\&change,
\&printall
);
my @students=();
sub st01
{
	my $q = new CGI;
	my $st =0+$q->param("menu_");
	my $global = {selfurl => $ENV{SCRIPT_NAME}, menu_=> $st};
	#fromfile();
	FromDB();
	if($st && defined $option_func[$st-1])
	{
		$option_func[$st-1]->($q, $global);
	}
	else
	{	
		menu($q, $global);
	}
}


sub menu
{
	my($q, $global) = @_;
	print $q->header('charset=windows-1251');
	print "<HTML><HEAD><TITLE>Second Lab</TITLE></HEAD><BODY><hr><menu type=\"toolbar\"><ul type=\"disc\">";
	print"<FORM>
	<HR>Press a text: <br>
	<P>Name of student:<BR><INPUT NAME=\"name_\" TYPE=TEXT maxsize=100><BR>
	<P>Surname of student:<BR><INPUT NAME=\"surname_\" TYPE=TEXT maxsize=100><BR>
	<P>Group of student:<BR><INPUT NAME=\"group_\" TYPE=TEXT maxsize=100><BR>
	<P>Age of student:<BR><INPUT NAME=\"age_\" TYPE=TEXT maxsize=100><BR>
	<P> Number of student:<BR><INPUT NAME=\"number_\" TYPE=TEXT maxsize=100><BR>
	<INPUT TYPE='checkbox' NAME=\"starosta_\" VALUE=5>Steward<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=1> Add<BR> 
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=2> Del<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=3> Change<BR>
	<INPUT TYPE='radio' NAME=\"menu_\" VALUE=4> Print all<BR>
	<INPUT TYPE='HIDDEN' NAME='student' VALUE =\"1\"/>
	<INPUT type='submit'> <INPUT type='reset'> <BR>";
	print "</BODY><BR><BR><a href=\"$global->{selfurl}\">Back to student list.</a><BR></FORM></HTML>";
}
sub TypeOfStudent
{
my($q) = @_;
my $st=$q->param('starosta_');
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
	push(@students,$sthash);
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
	my $type=TypeOfStudent($q);
	if (defined $students[$k-1])
	{ 
		my $hashref=$students[$k-1];
		$hashref->{name}=$q->param("name_");
		$hashref->{surname}=$q->param('surname_');
		$hashref->{group}=$q->param('group_');
		$hashref->{age}=$q->param('age_');
		if($type eq "steward"){
		$hashref->{type}=$type;}
		#tofile();
		ToDB();
	}
	menu($q,$global);	
}

sub printall
{	
	my ($q,$global) = @_;
	print $q->header('charset=windows-1251');
	print "<pre>\n------------------------------\n <ol value=1>";
	foreach	my $item (@students)
	{
		
		print "<li>Student: 
			Name:$item->{name} 
			Surname:$item->{surname} 
			Group:$item->{group} 
			Age:$item->{age}";
		if(defined $item->{type})	
			{ print "
			TypeOfStudent: $item->{type}</li>";}
		else 
			{
				print "</li>";
			}	
	}
	print "------------------------------</pre></ol>
	<a href=\"$global->{selfurl}?student=1&menu_=0\">To menu.</a>";
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
}

sub tofile
{	
	dbmopen(my %hash,$Myfile,0644);
	my $i=0;
	my $s;
	my @a=();
	%hash=();
	foreach my $item(@students)
		{
		if(defined $item->{type}){
		 @a=("name",$item->{name},"surname",$item->{surname},"group",$item->{group},"age",$item->{age},"type",$item->{type});}
		else { @a=("name",$item->{name},"surname",$item->{surname},"group",$item->{group},"age",$item->{age});}
		$s=join(",",@a);
		$hash{$i}=$s;
		$i++;
		}
	dbmclose(%hash);	
}

sub fromfile
{
	dbmopen(my %hash,$Myfile,0644);
		while (( my $key,my $value) = each(%hash))
	{
		my @st=split(/,/,$hash{$key});
		$students[$key]={@st};
	}
	dbmclose(%hash);
};
1
