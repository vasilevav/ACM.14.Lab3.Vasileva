package ST08;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
#use DBD::mysql;

my @humans=();

my $q=new CGI;
my $myself	= $q->param('student');
my $action = $q->param('action');
my $targetid = $q->param('id'); 


 
 sub st08
{

	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	if($action eq "edit")
		{			
			edit();			
		}
	elsif($action eq "delete")
		{		
			deleteline();
			fromdb();
			showall();
			footer()
		}
	elsif($action eq "apply")
	{
		fromdb();
		add();
		todb();
		fromdb();
		showall();
		footer()
	}
		else
		{
			fromdb();
			showall();
			footer()
		}
}
sub footer
{
	my $newid=@humans;
	print "<tr>
	<form  method='get'>
	<td>$newid</td>
		<input type='hidden' name='student' value='$myself'>
		<input type='hidden' name='action' value='apply'>
		<input type='hidden' name='id' value='$newid'>
		<td><input type='text' size=20 name=v1></td>
		<td><input type='text' size=20 name=v2></td>
		<td><input type='text' size=5 name=v3></td>
		<td><input type='text' size=20 name=v4></td>
		<td><input type='checkbox' name=o1></td>
		<td><input type='text' size=20 name=v5></td>
		<td><input type='text' size=20 name=v6></td>
		<td><input type='submit' value='Добавить'></td></tr>
		</table>"
}

sub showall
{
	my ($q, $global) = @_;

	print "
	<a href=' $ENV{SCRIPT_NAME}'\>К списку</a>
	<table border='1'>	
    <tr>
    <th>ID</th>
    <th>Имя</th>
    <th>Фамилия</th>
    <th>Возраст</th>
    <th>Доп. инфо</th>
	<th>VIP</th>
	<th>Расширенный атрибут</th>
	<th>Расширенный атрибут 2</th>
	<th>Кнопочки</th>
	</tr>";
	
	my $j=0;
	 foreach my $i(@humans)
	 {
		 print "<tr><td>$j</td>
		 <td>$i->{Name}</td>
		 <td>$i->{SurName}</td>
		 <td>$i->{Age}</td>
		 <td>$i->{Sth}</td>
		 <td>$i->{Status}</td>
		 <td>$i->{Add}</td>
		 <td>$i->{Add1}</td>
		 <td><a href=\'$global->{selfurl}?student=$myself&action=edit&id=$j'>Изменить</a>&nbsp;&nbsp;&nbsp;
		 <a href=\'$global->{selfurl}?student=$myself&action=delete&id=$j''>Удалить</a>
		</td>
		 </tr>";
		$j++;
	} 
	
}
sub add
{
	my $human;
	if($q->param('o1') eq 'on')
	{
		$human={
		Name => $q->param('v1')."\n",
		SurName => $q->param('v2')."\n",
		Age => $q->param('v3')."\n",
		Sth => $q->param('v4')."\n",
		Status => '+',
		Add => $q->param('v5')."\n",
		Add1 => $q->param('v6')."\n",
		};
	}
	else
	{
		$human={
		Name => $q->param('v1')."\n",
		SurName => $q->param('v2')."\n",
		Age => $q->param('v3')."\n",
		Sth => $q->param('v4')."\n",
		Status => '-',
		Add => $q->param('v5')."\n",
		Add1 => $q->param('v6')."\n",
		};
	}
	$humans[$targetid]=$human;
}
sub edit
{
	my ($q, $global) = @_;
	fromdb();
	showall();
	print "<tr>
	<form  method='get'>
	
	<td>$targetid</td>
	<input type='hidden' name='student' value='$myself'>
	<input type='hidden' name='action' value='apply'>
	<input type='hidden' name='id' value='$targetid'>
	<td><input type='text' size=20 name=v1 value='$humans[$targetid]->{Name}'></td>
	<td><input type='text' size=20 name=v2 value='$humans[$targetid]->{SurName}'></td>
	<td><input type='text' size=5 name=v3 value='$humans[$targetid]->{Age}'></td>
	<td><input type='text' size=20 name=v4 value='$humans[$targetid]->{Sth}'></td>
	<td><input type='checkbox' name=o1></td>
	<td><input type='text' size=20 name=v5 value='$humans[$targetid]->{Add}'></td>
	<td><input type='text' size=20 name=v6 value='$humans[$targetid]->{Add1}'></td>
	<td><input type='submit' value='Применить'></td></tr>
	</form>
	</table>";
	todb();
}
sub deleteline()
{
	fromdb();
	splice( @humans, $targetid, 1);
	todb();
}

sub todb
{
	my $dbh = DBI->connect('DBI:mysql:dbname=data;host=localhost','root', '12345678');
	my $id=1;
	$dbh->do('SET CHARACTER SET cp1251');
	$dbh->do("TRUNCATE TABLE `data`.`table`")|| die "Could not delete from database: $DBI::errstr";
	my $query = "INSERT INTO `data`.`table` (`ID`, `Name`, `SurName`, `Age`, `Sth`, `Status`, `Sth1`, `Sth2`) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
	my $csr = $dbh->prepare($query);
	foreach my $i(@humans)
	{	
		$csr->bind_param(1,$id);
		$csr->bind_param(2,$i->{Name});
		$csr->bind_param(3,$i->{SurName});
		$csr->bind_param(4,$i->{Age});
		$csr->bind_param(5,$i->{Sth});
		if ($i->{Status} eq '+')
		{
			$csr->bind_param(6,'+');
			$csr->bind_param(7,$i->{Add});
			$csr->bind_param(8,$i->{Add1});
		}
		else
		{
			$csr->bind_param(6,'-');
			$csr->bind_param(7,'');
			$csr->bind_param(8,'');
		}
		$csr->execute();
		$id++;
	}
	
	$dbh ->disconnect();
}
sub fromdb
{
	my $dbh = DBI->connect('DBI:mysql:dbname=data;host=localhost','root', '12345678');
	$dbh->do('SET CHARACTER SET cp1251');
	my $data = $dbh->prepare ("SELECT * FROM `table`;");
	$data->execute();
	@humans=();
	my $id=0;
	while(my $hash_ref = $data->fetchrow_hashref())
	{	
		my $human={
			Name=>"$hash_ref->{Name}\n",
			SurName=>"$hash_ref->{SurName}\n",
			Age=>"$hash_ref->{Age}\n",
			Sth=>"$hash_ref->{Sth}\n",
			Status => "$hash_ref->{Status}",
			Add => "$hash_ref->{Sth1}",
			Add1 => "$hash_ref->{Sth2}",
		};
	
		$humans[$id]=$human;
		$id++;
	}
	$data->finish();
	$dbh ->disconnect();
}


	
1;









