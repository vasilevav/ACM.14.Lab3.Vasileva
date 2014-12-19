package ST15;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my @Objects=();
undef @Objects;

my @RefToMenuItems =
(
	\&edit,
	\&delete,
	\&save
);
my @Attributes=(
	'Name',
	'Attribute1',
	'Attribute2',
	'Attribute3',
	'UniqueAttribute');
	
my $addtnlPrm = 'UniqueAttribute';

sub st15{
	Lab3Main();
 }

sub menu{
	my ($q, $global) = @_;
	print $q->header('charset=windows-1251');
	my $i = 0;
	print 
	"<pre>
		<table cellspacing=0>
			<tr>
				<th>
					N&nbsp;
				</th>
				<th>
					El Name&nbsp;
				</th>
				<th>
					Delete
				</th>
			</tr>";
	foreach my $s(@Objects){
		$i++;
		print  "<tr>
				<td>
					$i
				</td>
				<td>
					<a href=\"$global->{selfurl}?Num=$i&action=1&student=$global->{st}\">
						$s->{$Attributes[0]}
					</a>
				</td>
				<td>
					&nbsp;
					<a href=\"$global->{selfurl}?Num=$i&action=2&student=$global->{st}\">
						Del
					</a>
				</td>
			</tr>";
	}
	print 
		"</table>
	</pre>
	<FORM>
		<button type=submit name=action value=1>
			Add
		</button>
		<INPUT TYPE=hidden NAME =student value=\"$global->{st}\">
		<a href=\"$global->{selfurl}\">
			Exit
		</a>
	</FORM>";
}

sub SaveToDB{
	my $dsn = 'DBI:mysql:DB_PRIDACHIN;localhost:3306';
	my $userid = 'root';
	my $password = '';
	my $dbh = DBI->connect($dsn, $userid, $password, {RaiseError => 1, AutoCommit=>1}) or die;
	$dbh->do('TRUNCATE TABLE mytable');
	my $names = join(',',@Attributes);
	my $sql = $dbh->prepare("INSERT INTO mytable(ID, $names) VALUES (?, ?, ?, ?, ?, ?)");
	my $id = 1;
	foreach my $item(@Objects){	
		$sql->bind_param(1,$id++);
		my $i = 2;
		foreach my $itemName(@Attributes){
			$sql->bind_param($i++,$item->{$itemName});
		}
		$sql->execute();
	}	
	$dbh ->disconnect();
}

sub LoadFromDB{
	my $dsn = 'DBI:mysql:DB_PRIDACHIN;localhost:3306';
	my $userid = 'root';
	my $password = '';
	my $dbh = DBI->connect($dsn, $userid, $password, {RaiseError => 1, AutoCommit=>1}) or die;
	my $sql = $dbh->prepare ("SELECT * FROM mytable;");
	$sql->execute();
	@Objects=();
	while(my $ref2hash = $sql->fetchrow_hashref()){
		delete($ref2hash->{ID});
		@Objects=(@Objects, $ref2hash);
	}
	$sql->finish();
	$dbh ->disconnect();
}

sub Lab3Main{
	my $q = new CGI;
	my $st	= 0+$q->param('student');
	my $act = 0+$q->param('action');
	my $global = {selfurl => $ENV{SCRIPT_NAME}, st => $st};	
	if($act && defined $RefToMenuItems[$act-1]){
		$RefToMenuItems[$act-1]->($q, $global);
	}
	else{
		LoadFromDB();
		menu($q, $global);
	}
}

sub save{
	my ($q, $global) = @_;
	my $i = $q->param('Num');
	LoadFromDB();
	my $elem = {};
	foreach(@Attributes){
		$elem->{$_}=$q->param($_);
	}
	if(!$i){
		@Objects=(@Objects, $elem);
	}
	else{
		$Objects[$i-1]=$elem;
	}
	SaveToDB();
	menu($q, $global);
}

sub delete{
	my ($q, $global) = @_;
	my $i = $q->param('Num');
	LoadFromDB();
	splice(@Objects, $i-1, 1);
	SaveToDB();
	menu($q, $global);
}

sub edit {
	my ($q, $global) = @_;
	LoadFromDB();
	my $i = $q->param('Num');
	print "Content-type: text/html\n\n";
	print 
	"<FORM>
		<INPUT TYPE=hidden NAME =Num value=\"$i\">
		<INPUT TYPE=hidden NAME =student value=\"$global->{st}\">";
	my $str ="";
	foreach my $el(@Attributes){
		if($el eq $Attributes[-1] ){
			if(@Objects){
				if($Objects[$i-1]->{$el}==1){
					print "UniqueAttribute <INPUT Type=checkbox Name=\"$addtnlPrm\" Value=1 Checked>";
				}
				else{
					if(!$i){
						print "UniqueAttribute <INPUT Type=checkbox Name=\"$addtnlPrm\" Value=1 unchecked>";
					}
				}
			}
			else{
				if(!$i){
					print "UniqueAttribute <INPUT Type=checkbox Name=\"$addtnlPrm\" Value=1 unchecked>";
				}
			}
		}
		else{
			if($i){
				print 
				"<INPUT TYPE=Text NAME =\"$el\" value=\"$Objects[$i-1]->{$el}\">
				<br>";
			}
			else {
				print 
				"<INPUT TYPE=Text NAME =\"$el\" value=\"$el\">
				<br>";
			}
		}
	}
	print
		"<button type=submit name=action value=3>
			Save
		</button>
	</FORM>";	
}
