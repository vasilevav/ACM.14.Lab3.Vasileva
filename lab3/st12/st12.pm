package ST12;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my @DATABASE=();
my @MODULES =(
	\&edit,
	\&delete,
	\&save);
my @ElNames=(
	'Название',
	'Жесткость',
	'Прогиб',
	'Ширина',
	'Система_закладных',
	'Форма',
	'Сердечник',
	'Супердоска');
my $addtnlPrm = 'Супердоска';
	
sub st12{Lab2Main();}

sub menu{
	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	my $i = 0;
	print "<pre><table cellspacing=0><tr><th>№&nbsp;</th><th>Название эл-та&nbsp;</th><th>Del</th></tr>";
	foreach my $s(@DATABASE){
		$i++;
		print "<tr><td>$i</td><td><a href=\"$global->{selfurl}?ElN=$i&wtd=1&student=$global->{st}\">$s->{$ElNames[0]}</a></td>
		<td>&nbsp;<a href=\"$global->{selfurl}?ElN=$i&wtd=2&student=$global->{st}\">X</a></td>";
	}
	print "</table></pre><FORM><button type=submit name=wtd value=1>Добавить</button>
	<INPUT TYPE=hidden NAME =student value=\"$global->{st}\"><a href=\"$global->{selfurl}\">EXIT</a></FORM>";
}

sub IntoDB{
	my $dsn = 'DBI:mysql:db;localhost:3306';
	my $userid = 'root';
	my $password = '';
	my $dbh = DBI->connect($dsn, $userid, $password, {RaiseError => 1, AutoCommit=>1}) or die $DBI::errstr;
	$dbh->do('SET CHARACTER SET cp1251');
	$dbh->do('TRUNCATE TABLE myitems');
	my $names = join(',',@ElNames);
	my $sth = $dbh->prepare("INSERT INTO myitems(ID, $names) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
	my $id = 1;
	foreach my $item(@DATABASE){	
		$sth->bind_param(1,$id++);
		my $i = 2;
		foreach my $itemName(@ElNames){
			$sth->bind_param($i++,$item->{$itemName});
		}
		$sth->execute();
	}	
	$dbh ->disconnect();
}

sub FromDB{
	my $dsn = 'DBI:mysql:db;localhost:3306';
	my $userid = 'root';
	my $password = '';
	my $dbh = DBI->connect($dsn, $userid, $password, {RaiseError => 1, AutoCommit=>1}) or die $DBI::errstr;
	$dbh->do('SET CHARACTER SET cp1251');
	my $sth = $dbh->prepare ("SELECT * FROM myitems;");
	$sth->execute();
	@DATABASE=();
	while(my $ref2hash = $sth->fetchrow_hashref()){
		delete($ref2hash->{ID});
		@DATABASE=(@DATABASE, $ref2hash);
	}
	$sth->finish();
	$dbh ->disconnect();
}

sub Lab2Main{
	my $q = new CGI;
	my $st	= 0+$q->param('student');
	my $wtd = 0+$q->param('wtd');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, st => $st};	
	if($wtd && defined $MODULES[$wtd-1]){
		$MODULES[$wtd-1]->($q, $global);
	}
	else{
		FromDB();
		menu($q, $global);
	}
}

sub save{
	my ($q, $global) = @_;
	my $elnum = $q->param('ElN');
	FromDB();
	my $elem = {};
	foreach my $o(@ElNames){
		$elem->{$o}=$q->param($o);
	}
	if(!$elnum){
		@DATABASE=(@DATABASE, $elem);
	}else{$DATABASE[$elnum-1]=$elem;}
	IntoDB();
	menu($q, $global);
}

sub delete{
	my ($q, $global) = @_;
	my $elnum = $q->param('ElN');
	FromDB();
	splice(@DATABASE, $elnum-1, 1);
	IntoDB();
	menu($q, $global);
}

sub edit {
	my ($q, $global) = @_;
	FromDB();
	my $elnum = $q->param('ElN');
	print $q->header('charset=windows-1251');
	print "<pre><FORM><INPUT TYPE=hidden NAME=ElN value=$elnum><INPUT TYPE=hidden NAME=student value=$global->{st}>";
	my $str ="";
	foreach my $el(@ElNames) {
		if($el eq $ElNames[-1]){
			if ($DATABASE[$elnum-1]->{$el}==1) {print "СУПЕРДОСКА <INPUT Type=checkbox Name=\"$addtnlPrm\" Value=1 Checked>";}
			else {if (!$elnum) {print "СУПЕРДОСКА <INPUT Type=checkbox Name=\"$addtnlPrm\" Value=1 unchecked>";}}
		}else{
			if($elnum){print "<INPUT TYPE=Text NAME=\"$el\" value=\"$DATABASE[$elnum-1]->{$el}\"><br>";}
			else {print "<INPUT TYPE=Text NAME =\"$el\" value=\"$el\"><br>";}}
	}
	print"</pre><button type=submit name=wtd value=3>Сохранить</button></FORM>";	
}