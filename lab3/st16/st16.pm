package ST16;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
#use DBD::mysql;

my %list;

sub st16
{
	readschema();
	my ($q, $global) = @_;
	my $me=$q->param('student');
	print $q->header('charset=windows-1251');
	my $id=$q->param('id');
	if(!$id){$id=(keys %list)+1;}
	my $action=0;
	my $temp={};
	if($q->param('action') == 1)
	{
		$temp={
		title => $list{$id}->{title},
		country => $list{$id}->{country},
		year => $list{$id}->{year},
		mark => $list{$id}->{mark},
		priveleged => $list{$id}->{priveleged},
		annotation => $list{$id}->{annotation},
		};		 
	}	
	if($q->param('action') == 2)
	{
		delete $list{$id};
		$id=(keys %list)+1;
		saveshema();
		readschema();
	}
	if($q->param('action') == 3)
	{
		my $added={
			title => $q->param('v1'),
			country => $q->param('v2'),
			year => $q->param('v3'),
			mark => $q->param('v4'),
			priveleged => $q->param('v5'),
			annotation => $q->param('v6')
			
			};		 
		$list{$id}=$added;
		$id=(keys %list)+1;
		saveshema();
		readschema();
		
	}
	print "<body>
	<a href=' $ENV{SCRIPT_NAME}'\>К списку работ</a>
	<table border='1'>	
    <tr>
    <th>ID</th>
    <th>Название</th>
    <th>Страна</th>
    <th>Год</th>
    <th>Оценка</th>
	<th>Расширенно</th>
	<th>Аннотация</th>
	<th>Действия</th>
	
	</tr>";
	foreach my $j (sort keys %list ) {
        my $i = $list{$j};
		print"<tr><td>$j</td>
		<td>$i->{title}</td>
		<td>$i->{country}</td>
		<td>$i->{year}</td>
		<td>$i->{mark}</td>
		<td>$i->{priveleged}</td>
		<td>$i->{annotation}</td>
		<td><a href=\'$global->{selfurl}?student=$me&action=1&id=$j'>Изменить</a>&nbsp;&nbsp;&nbsp;
		<a href=\'$global->{selfurl}?student=$me&action=2&id=$j'>Удалить</a></td>
		</tr>";
    }	
	print"<tr>
	<form  method='get'>
	<td>$id</td>
	<input type='hidden' name='student' value='$me'>
	<input type='hidden' name='action' value='3'>
	<input type='hidden' name='id' value='$id'>
	<td><input type='text' size=20 name=v1 value='$temp->{title}'></td>
	<td><input type='text' size=20 name=v2 value='$temp->{country}'></td>
	<td><input type='text' size=5 name=v3 value='$temp->{year}'></td>
	<td><input type='text' size=20 name=v4 value='$temp->{mark}'></td>
	<td><select name=v5 size=2>
	<option value='0' selected>Нет аннотации</option>
	<option value='1'>Есть аннотация</option>
	</td>
	<td><input type='text' size=20 name=v6 value='$temp->{annotation}'></td>
	<td><input type='submit' value='Применить/добавить'></td></tr>
	</table></form></body>";
saveshema();
}

sub saveshema
{
	my $dbh = DBI->connect('DBI:mysql:dbname=data;host=localhost','root', '12345678');
	$dbh->do('SET CHARACTER SET cp1251');
	$dbh->do("TRUNCATE TABLE `data`.`table`");
	my $query = "INSERT INTO `data`.`table` (`id`, `title`, `country`, `year`, `mark`, `priveleged`, `annotation`) VALUES ( ?, ?, ?, ?, ?, ?, ?);";
	my $csr = $dbh->prepare($query);
	foreach my $j(sort keys %list)
	{	
		my $i = $list{$j};
		if($i->{priveleged})
			{$csr->execute($j,$i->{title},$i->{country},$i->{year},$i->{mark},"1",$i->{annotation});}
		else
			{$csr->execute($j,$i->{title},$i->{country},$i->{year},$i->{mark},"0","");}
	}
	$dbh->disconnect();
}


sub readschema
{
	my $dbh = DBI->connect('DBI:mysql:dbname=data;host=localhost','root', '12345678');
	$dbh->do('SET CHARACTER SET cp1251');
	my $data = $dbh->prepare ("SELECT * FROM `table`;");
	$data->execute();
	%list =();
	while(my $hash_ref = $data->fetchrow_hashref())
	{
		my $temp={
		title => $hash_ref->{title},
		country => $hash_ref->{country},
		year => $hash_ref->{year},
		mark => $hash_ref->{mark},
		priveleged => $hash_ref->{priveleged},
		annotation => $hash_ref->{annotation}};
		$list{$hash_ref->{id}}=$temp;
	}
	$data->finish();
	$dbh->disconnect();
}

1;
