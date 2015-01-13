package ST09;
use strict; 
use CGI;
use DBI;

my $n = new CGI;
my $snowboard;
my $selfurl = "lab3.cgi";
my $dbh; 



sub st09
{
    my ($q, $global) = @_;
    $snowboard = $global->{snowboard};
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
#$dbh -> disconnect();
sub ShowHeader
{
	print <<ENDOFHTML;
<html>
<head>
</head>
<body>
<h1>List of snowboards</h1>
ENDOFHTML
}

sub ShowList
{
	$dbh  =   DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});
	ShowForm() unless ($n->param('type') eq 'edit');

	print <<STARTLIST;
	
<table cellspacing>
<tr>
<td width = 255 bgcolor = #F0F8FF> 
<strong>Company</strong> </td>
<td width = 247 bgcolor = #F0F8FF>
<strong>Size</strong> </td>
<td width = 80 bgcolor = #F0F8FF> 
<strong>Color</strong> </td>
<td width = 1 bgcolor = #F0F8FF> 
<strong>Praepostor</strong> </td>
</tr>
STARTLIST

	my $sth = $dbh->prepare("select * from studlist");
	$sth->execute();

	while(my $item = $sth->fetchrow_hashref)
	{
		PrintItem($item);
	}

	$sth->finish();
	
	print '</table>';
	$dbh -> disconnect();
}

sub ShowForm
{
	my ($item) = @_;
	my $checked = "checked" if ($item->{Prpost});
	
	print <<ENDOFFORM;	
<table>
<tr>
<form action = $selfurl method = "post">
<input type = "hidden" Size = "snowboard" value = $snowboard/>
<td width > 
<input required type = "text" Size = "Company" size = 29 maxlength = 160 value = "$item->{Company}" > </td>
<td width >
<input required type = "text" Size = "Size" size = 29 maxlength = 30 value = "$item->{Size}"></td>
<td width > 
<input required type = "number" Size = "Color" min = 15 max = 99 size = 10 maxlength = 2 value = $item->{Color}></td>
<td width = 100> 
<input type = "checkbox" Size = "Prpost"  $checked value = 1 >  Praepostor</td>
<input type = "hidden" Size = "type" value = "doedit">
<input type = "hidden" Size = "id" value = $item->{id}>
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
$item->{Company}</td>
 
<td width  bgcolor = #F0F8FF> 
$item->{Size}</td> 

<td width  bgcolor = #F0F8FF> 
$item->{Color} </td >
<td width bgcolor = #F0F8FF align = center> $Prpost </td>
<td>
<form action = $selfurl method = post>
<input type = "hidden" Size = "snowboard" value = $snowboard/>
<input type = "hidden" Size = "type" value = "dodelete">
<input type = "hidden" Size = "id" value =  $item->{id}>
<input type = "submit" value = "-"></td>
</form>
<td width = 100 >
<form action = $selfurl method = post>
<input type = "hidden" Size = "snowboard" value = $snowboard/>
<input type = "hidden" Size = "type" value = "edit">
<input type = "hidden" Size = "id"   value =  $item->{id}>
<input type = "submit" value = "Edit"></td>
</form>
</tr>

ENDOFITEM
}

sub DoEdit
{
	$dbh  =   DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});
	my $id =$dbh->prepare("select count(*) from studlist");
	$id->execute();
	$id++;
	my $Prpost = 0 + $n->param('Prpost');
	my $Color = 0 + $n->param('Color');

	my $Company = $dbh->quote($n->param('Company'));
	my $Size = $dbh -> quote ($n->param('Size'));
		
	$dbh->do("replace into studlist values($id, $Company, $Size, $Color, $Prpost)");
	$dbh -> disconnect();
}

sub DoDelete
{
	$dbh  =   DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});
	my $id = 0+$n->param('id');
	$dbh -> do ("delete from studlist where id = $id");
	$dbh -> disconnect();
}

sub Edit
{
	$dbh  =   DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});
	my $id = 0+$n->param('id');
	ShowForm(GetItem(0+$n->param('id')));
	$dbh->do("delete from studlist where id=$id");
	$dbh -> disconnect();
	
}

sub GetItem 
{
	my ($id) = @_;
	my $sth = $dbh->prepare("select * from studlist where id=$id");
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


return 1;
