package ST05;
use strict; 
use CGI;
use DBI;

my $n = new CGI;
my $student;
my $selfurl = "lab3.cgi";
my    $dbh  =   DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});



sub st05
{
    my ($q, $global) = @_;
    $student = $global->{student};
	print "Content-type: text/html; charset=windows-1251\n\n";

	ShowHeader ();
		
	my %MENU = ('doedit' => \&DoEdit,
				'dodelete' => \&DoDelete,
				'edit' => \&Edit);

	my $type =  $n->param("type");

	if($MENU{$type})
	{
		$MENU{$type}->();
	}
	
	ShowList();	
	ShowFooter ();
	

}
$dbh -> disconnect();
sub ShowHeader
{
	print <<ENDOFHTML;
<html>
<head>
</head>
<body>
<h1>List of students</h1>
ENDOFHTML
}

sub ShowList
{
	ShowForm() unless ($n->param('type') eq 'edit');

	print <<STARTLIST;
	
<table cellspacing>
<tr>
<td width = 255 bgcolor = #F0F8FF> 
<strong>Surname</strong> </td>
<td width = 247 bgcolor = #F0F8FF>
<strong>Name</strong> </td>
<td width = 80 bgcolor = #F0F8FF> 
<strong>Age</strong> </td>
<td width = 1 bgcolor = #F0F8FF> 
<strong>Praepostor</strong> </td>
</tr>
STARTLIST

	my $sth = $dbh->prepare("select * from list");
	$sth->execute();

	while(my $item = $sth->fetchrow_hashref)
	{
		PrintItem($item);
	}

	$sth->finish();
	
	print '</table>';
}

sub ShowForm
{
	my ($item) = @_;
	my $checked = "checked" if ($item->{Prpost});
	
	print <<ENDOFFORM;	
<table>
<tr>
<form action = $selfurl method = "post">
<input type = "hidden" name = "student" value = $student/>
<td width > 
<input required type = "text" name = "Surname" size = 29 maxlength = 160 value = "$item->{Surname}" > </td>
<td width >
<input required type = "text" name = "Name" size = 29 maxlength = 30 value = "$item->{Name}"></td>
<td width > 
<input required type = "number" name = "Age" min = 15 max = 99 size = 10 maxlength = 2 value = $item->{Age}></td>
<td width = 100> 
<input type = "checkbox" name = "Prpost"  $checked value = 1 >  Praepostor</td>
<input type = "hidden" name = "type" value = "doedit">
<input type = "hidden" name = "id" value = $item->{id}>
<td width = 50> 
<input type = "submit" width = 40 value = "+"</td>
</tr>
</table>
</form>
ENDOFFORM
}

sub PrintItem
{
	my ($item) = @_;
	
	my $Prpost =  "Yes" if ($item->{Prpost});
	
	print <<ENDOFITEM;
<p align=left>

<tr>
<td width  bgcolor = #F0F8FF> 
$item->{Surname}</td>
 
<td width  bgcolor = #F0F8FF> 
$item->{Name}</td> 

<td width  bgcolor = #F0F8FF> 
$item->{Age} </td >
<td width bgcolor = #F0F8FF align = center> $Prpost </td>
<td>
<form action = $selfurl method = post>
<input type = "hidden" name = "student" value = $student/>
<input type = "hidden" name = "type" value = "dodelete">
<input type = "hidden" name = "id" value =  $item->{id}>
<input type = "submit" value = "-"></td>
</form>
<td width = 100 >
<form action = $selfurl method = post>
<input type = "hidden" name = "student" value = $student/>
<input type = "hidden" name = "type" value = "edit">
<input type = "hidden" name = "id"   value =  $item->{id}>
<input type = "submit" value = "Edit"></td>
</form>
</tr>

ENDOFITEM
}

sub DoEdit
{
	my $id =$dbh->prepare("select count(*) from list");
	$id->execute();
	$id++;
	my $Prpost = 0 + $n->param('Prpost');
	my $Age = 0 + $n->param('Age');

	my $Surname = $dbh->quote($n->param('Surname'));
	my $Name = $dbh -> quote ($n->param('Name'));
		
	$dbh->do("replace into list values($id, $Surname, $Name, $Age, $Prpost)");
}

sub DoDelete
{
	my $id = 0+$n->param('id');
	$dbh -> do ("delete from list where id = $id");
}

sub Edit
{
	my $id = 0+$n->param('id');
	ShowForm(GetItem(0+$n->param('id')));
	$dbh->do("delete from list where id=$id");
	
}

sub GetItem 
{
	my ($id) = @_;
	my $sth = $dbh->prepare("select * from list where id=$id");
	$sth->execute();

	if(my $item = $sth->fetchrow_hashref)
	{
		return $item;
	}
	$sth->finish();
	my $item = {id => $id};
	
	return $item;
}

sub ShowFooter
{
	print <<ENDOFHTML;
</body>
</html>
ENDOFHTML
}
