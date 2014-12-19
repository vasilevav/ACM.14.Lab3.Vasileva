package ST17;

use strict; 
use CGI;
use DBI;


my $dbh; 
my $st;


my $n = new CGI;
my $selfurl = "lab3.cgi";


sub st17
{
    my ($q, $global) = @_;
    $st = $global->{st};
	print "Content-type: text/html; charset=windows-1251\n\n";

	print qq~
	<html>
		<head>
		</head>
		<body>
		<h1>AutoPark Of Your Dream</h1>
	~;
		
	my %LIST_ACTIONS = ('edit_elem' => \&edit_element, 'del_elem' => \&del_element, 'edit' => \&edit);
	my $type =  $n->param("type");

	if($LIST_ACTIONS{$type})
	{
		$LIST_ACTIONS{$type}->();
	}
	
	view_list();	
	print qq~
		</body>
	</html>
    ~;
	

}

sub connect_to_db
{
	$dbh = DBI->connect("DBI:mysql:db;localhost:3306", "root", "1234", {RaiseError=>1, AutoCommit=>1});
}

sub view_list
{
	connect_to_db();
	View_Cars_Form() unless ($n->param('type') eq 'edit');

	print qq~	
	<table cellspacing>
		<tr>
			<td width = 255 bgcolor = #F0F8FF> 
				<strong>Model_car</strong> </td>
			<td width = 250 bgcolor = #F0F8FF>
				<strong>Power_engine</strong> </td>
			<td width = 80 bgcolor = #F0F8FF> 
				<strong>Price</strong> </td>
			<td width = 1 bgcolor = #F0F8FF> 
				<strong>VIN_number</strong> </td>
		</tr>
	~;

	my $query_DB = $dbh->prepare("select * from autopark");
	$query_DB->execute();

	while(my $Car = $query_DB->fetchrow_hashref)
	{
		Car_print($Car);
	}

	$query_DB->finish();
	
	print '</table>';
	$dbh -> disconnect();
}

sub View_Cars_Form
{
	my ($Car) = @_;
	my $checked = "checked" if ($Car->{vin_num});
	
	print qq~	
	<table>
		<tr>
			<form action = $selfurl method = "post">
				<input type = "hidden" name = "st" value = $st/>
				<td width > 
					<input required type = "text" name = "Model_car" size = 29 maxlength = 160 value = "$Car->{Model_car}" > </td>
				<td width >
					<input required type = "text" name = "Power_engine" size = 29 maxlength = 30 value = "$Car->{Power_engine}"></td>
				<td width > 
					<input required type = "number" name = "Price" min = 15 max = 99 size = 10 maxlength = 2 value = $Car->{Price}></td>
				<td width = 100> 
			<input type = "checkbox" name = "vin_num"  $checked value = 1 >VIN_number</td>
			<input type = "hidden" name = "type" value = "edit_elem">
			<input type = "hidden" name = "Car_ID" value = $Car->{Car_ID}>
			<td width = 50> 
				<input type = "submit" width = 40 value = "Add"</td>
		</tr>
	</table>
	</form>
	~;
}

sub Car_print
{
	my ($Car) = @_;
	
	my $vin_num =  "Yes" if ($Car->{vin_num});
	
	print qq~
	<p align=left>
	<tr>
		<td width  bgcolor = #F0F8FF> 
			$Car->{Model_car}</td>
	 
		<td width  bgcolor = #F0F8FF> 
			$Car->{Power_engine}</td> 

		<td width  bgcolor = #F0F8FF> 
			$Car->{Price} </td >
		<td width bgcolor = #F0F8FF align = center> $vin_num </td>
		<td>
			<form action = $selfurl method = post>
				<input type = "hidden" name = "st" value = $st/>
				<input type = "hidden" name = "type" value = "del_elem">
				<input type = "hidden" name = "Car_ID" value =  $Car->{Car_ID}>
				<input type = "submit" value = "Del"></td>
			</form>
		<td width = 100 >
			<form action = $selfurl method = post>
				<input type = "hidden" name = "st" value = $st/>
				<input type = "hidden" name = "type" value = "edit">
				<input type = "hidden" name = "Car_ID"   value =  $Car->{Car_ID}>
				<input type = "submit" value = "Edit"></td>
			</form>
	</tr>
	~;
}

sub edit_element
{
	connect_to_db();
	my $Car_ID = $dbh->prepare("select count(*) from autopark");
	$Car_ID->execute();
	$Car_ID++;

	my $vin_num      = 0 + $n->param('vin_num');
	my $Price        = 0 + $n->param('Price');
	my $Model_car    = $dbh->quote($n->param('Model_car'));
	my $Power_engine = $dbh ->quote($n->param('Power_engine'));
		
	$dbh->do("replace into autopark values($Car_ID, $Model_car, $Power_engine, $Price, $vin_num)");
	$dbh -> disconnect();
}

sub Get_Elem 
{
	my ($Car_ID) = @_;
	my $query_DB = $dbh->prepare("select * from autopark where Car_ID=$Car_ID");
	$query_DB->execute();

	if(my $Car = $query_DB->fetchrow_hashref)
	{
		return $Car;
	}
	$query_DB->finish();
	my $Car = {Car_ID => $Car_ID};
	
	return $Car;
}

sub edit
{
	connect_to_db();
	my $Car_ID = 0+$n->param('Car_ID');
	View_Cars_Form(Get_Elem(0+$n->param('Car_ID')));

	$dbh->do("delete from autopark where Car_ID=$Car_ID");
	$dbh -> disconnect();
	
}

sub del_element
{
	connect_to_db();
	my $Car_ID = 0+$n->param('Car_ID');
	$dbh -> do ("delete from autopark where Car_ID = $Car_ID");
	$dbh -> disconnect();
}

return 1;
