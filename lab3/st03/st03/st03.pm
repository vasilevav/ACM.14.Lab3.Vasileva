package Lab3;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $data = "test/data";
my $q = new CGI;
my %hash;
my $student;


my %oplist = (
  del => \&confirm,
  yes => \&remove,
  add => \&add,
  edt => \&edit, 
  set => \&set,
  import => \&dbm_to_sql,
  export => \&sql_to_dbm
);


my $db_host = "localhost";				
my $db_port = "3306";					
my $db_user = "root";					
my $db_pwd = "rootpwd";					
my $db_name = "library_db";				
my $db_table_name = "library_table";	
my $dsn_test = "DBI:mysql:INFORMATION_SCHEMA;$db_host:$db_port";
my $dsn_work = "DBI:mysql:$db_name;$db_host:$db_port";
my $dbm_filename = "library_dbm_file";
my $St;
my $db_type = "mysql";




sub main {
	$q = shift;
	my $title = 'Список книг';
	my $change = $q->param("change_db_type");
	if(defined $change)
	{
	
		$db_type = $change;
		my $cookie = $q->cookie(
			-name  => 'db_type',
			-value => $db_type
		);
		undef $change;
		print $q->header(-type => "text/html", -charset => "utf-8", -cookie => $cookie);
		print $q->start_html(
			-head=>$q->meta(
                   {
                     -http_equiv => 'Refresh',
                     -content => '2;URL='.$ENV{'SCRIPT_NAME'}
                   }
                 ));
		print $q->end_html();
	}
	else
	{	
		print $q->header(-type => "text/html", -charset => "utf-8", -cookie => $q->cookie('db_type'));
		$db_type = $q->cookie('db_type') ;
	}


	print $q->start_html($title);
	
	print '<form><label>Тип используемой базы<select id="selected_db_type" name="change_db_type" >';
	if($db_type eq "mysql")
	{
		print qq~ <option value="mysql" selected >MySQL</option>
				  <option value="dbm" >dbm file</option> ~;
	}
	else
	{
		print qq~ <option value="mysql" >MySQL</option>
				  <option value="dbm" selected >dbm file</option> ~;
	}
	print '<input type="submit" value="Изменить"/></select></label></form>';
	print $q->h3("Импорт/Экспорт");
	print 	$q->start_form(-action => $q->url(), -method => 'post'),
			$q->Tr(
				$q->td([
					$q->submit('import', 'DBM to MySQL'),
					$q->submit('export', 'MySQL to DBM'),
				]),

			),
			$q->end_form;
	$db_type = $q->cookie('db_type');
	print $q->h1($title);
	dbmopen(%hash, $data, 0666);
	my $done;
	foreach my $op (keys %oplist) {
		if (defined($q->param($op))) {
			$oplist{$op}->();
			$done = 1;
		}
	}
	normal() unless $done;
	print $q->h2('Список книг');
		print $q->start_table();
		print $q->Tr([
			$q->th(['ID', 'Автор', 'Название', 'Год']),
		]);
	if($db_type eq "mysql")
	{
		my $dbh = connect_to_mysql();	
		my $query =  "SELECT * FROM $db_table_name";
		my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
		my ($id, $author, $title, $year);
		$sth->bind_columns(\($id, $author, $title, $year)) or die "Не могу привязать $DBI::errstr";
		$rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
		while($sth->fetch())
		{
			$q->param('id', $id);
			print $q->start_form(-action => $q->url(), -method => 'get'),
				$q->hidden('id', $id),
				$q->Tr(
					$q->td([
						($id, $author, $title, $year),
						$q->submit('edt', 'Изменить'),
						$q->submit('del', 'Удалить'),
					]),
			
				),
				$q->end_form;
		}		
		$sth->finish(); $dbh->disconnect();
	}
	else
	{
		foreach my $id (sort keys %hash) {
			$q->param('id', $id);
			print $q->start_form(-action => $q->url(), -method => 'post'),
				$q->hidden('id', $id),
				$q->Tr(
					$q->td([
						split ("##", $hash{$id}),
						$q->submit('edt', 'Изменить'),
						$q->submit('del', 'Удалить'),
					]),
				),
				$q->end_form;
		}		
	}
	dbmclose(%hash);
	print $q->end_table;
	print $q->end_html;	
}
sub dbm_to_sql 
{
	my $dbh = connect_to_mysql();
	my $query = "DROP TABLE $db_table_name";
	my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	$sth->execute() or die "Не могу выполнить $DBI::errstr";
	$sth->finish(); $dbh->disconnect();	
	my $dbh = connect_to_mysql();
	$query = "INSERT INTO $db_table_name (author, title, year) VALUES (?, ?, ?)";
	$sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	foreach my $id (sort keys %hash) {
		my ($author, $title, $year) = split ("##", $hash{$id});
		$sth->execute($author, $title, $year);		
	}
	$query = "SELECT count(*) FROM $db_table_name";
	$sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	$sth->execute or die "Не могу выполнить $DBI::errstr";	
	print "добавлено в таблицу <b>$db_table_name</b> mysql базы <b>$db_name</b>: ".$sth->fetchrow_array()."<br>";
	$sth->finish(); $dbh->disconnect();	
	normal();
}

sub sql_to_dbm
{	

	my $dbh = connect_to_mysql();	
	my $query = "SELECT * FROM $db_table_name";
	my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	my $rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
	my ($id, $author, $title, $year);
	$sth->bind_columns(\($id, $author, $title, $year)) or die "Не могу привязать $DBI::errstr";
	my $rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
	%hash = ();
	while($sth->fetch())
	{	
		$hash{$id} = join "##", ($author, $title, $year);
	}
	$sth->finish(); $dbh->disconnect();	
	my $size = keys %hash;
	print "Записано в DBM файл: $size<br>";
	normal();
}
sub connect_to_mysql
{	
	my $dbh = DBI->connect($dsn_test, $db_user, $db_pwd, { RaiseError => 0, PrintError => 1, mysql_enable_utf8 => 1 } 
		) || die "Colud not connect to database: $DBI::errstr";
	my $query = "CREATE DATABASE IF NOT EXISTS $db_name";
	my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	my $rv = $sth->execute or die "Не могу выполнить $DBI::errstr";

	$sth->finish(); $dbh->disconnect();
	my $dbh = DBI->connect($dsn_work, $db_user, $db_pwd, { RaiseError => 0, PrintError => 1, mysql_enable_utf8 => 1 } 
		) || die "Colud not connect to database: $DBI::errstr";
		#$dbh->do( 'SET NAMES cp1251' );
	$query = "CREATE TABLE IF NOT EXISTS $db_table_name 
	(id int(11) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	author varchar(32) NOT NULL,
	title varchar(32) NOT NULL,
	year int(11) NOT NULL) DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci ENGINE=InnoDB";
	$sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
	$rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
	return $dbh;
};

sub normal {
	print $q->h2('Добавление данных');
	print $q->start_table();
	print $q->Tr([
		$q->th(['Автор', 'Название', 'Год']),
		$q->start_form(-action => $q->url(), -method => 'post'),
		$q->td([
			$q->textfield(-name => 'a_a', -size => 20),
			$q->textfield(-name => 'a_n', -size => 30),
			$q->textfield(-name => 'a_y', -size => 5),
			$q->submit('add', 'Добавить'),
		]),
		$q->end_form
	]);
	print $q->end_table;
}

sub edit {
	if($db_type eq "mysql")
	{
		my $id = $q->param('id');
		my $dbh = connect_to_mysql();	
		my $query =  "SELECT author, title, year FROM $db_table_name WHERE id = ?";
		my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($id) or die "Не могу выполнить $DBI::errstr";
		
		my ($author, $title, $year);
		$sth->bind_columns(\($author, $title, $year)) or die "Не могу привязать $DBI::errstr";
		$rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
		$sth->fetch();	

		$sth->finish(); $dbh->disconnect();
		
		print $q->h2('Изменение данных');
		print $q->start_table();
		print $q->Tr([
			$q->th(['Автор', 'Название', 'Год']),
			$q->start_form(-action => $q->url(), -method => 'post'),
			$q->hidden('id', $id),
			$q->td([
				$q->textfield(-name => 'e_a', -value => $author, -size => 20),
				$q->textfield(-name => 'e_n', -value => $title, -size => 30),
				$q->textfield(-name => 'e_y', -value => $year, -size => 5),
				$q->submit('set', 'Изменить'),
			]),
			#$q->end_formmy $q
		]);
		print $q->end_table;
	}
	else
	{
		my $id = $q->param('id');
		my @temp = split "##", $hash{$id};
		print $q->h2('Изменение данных');
		print $q->start_table();
		print $q->Tr([
			$q->th(['Автор', 'Название', 'Год']),
			$q->start_form(-action => $q->url(), -method => 'post'),
			$q->hidden('id', $id),
			$q->td([
				$q->textfield(-name => 'e_a', -value => $temp[0], -size => 20),
				$q->textfield(-name => 'e_n', -value => $temp[1], -size => 30),
				$q->textfield(-name => 'e_y', -value => $temp[2], -size => 5),
				$q->submit('set', 'Изменить'),
			]),
			#$q->end_formmy $q
		]);
		print $q->end_table;
	}
}

sub confirm {

	if($db_type eq "mysql")
	{
		my $id = $q->param('id');
		
		
	    my $dbh = connect_to_mysql();	
		my $query =  "SELECT author, title, year FROM $db_table_name WHERE id = ?";
		my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($id) or die "Не могу выполнить $DBI::errstr";		
		my ($author, $title, $year);
		$sth->bind_columns(\($author, $title, $year)) or die "Не могу привязать $DBI::errstr";
		$rv = $sth->execute or die "Не могу выполнить $DBI::errstr";
		$sth->fetch();
		$sth->finish(); $dbh->disconnect();
		print $q->h2('Подтвердите удаление записи');
		print $q->start_table();
		print $q->Tr([
			$q->th(['Автор', 'Название', 'Год']),
			$q->start_form(-action => $q->url(), -method => 'post'),
			$q->hidden('id', $id),
			$q->td([
				($author, $title, $year),
				$q->submit('yes', 'Удалить'),
			]),
			$q->end_form
		]);
		print $q->end_table;
	}
	else
	{
		my $id = $q->param('id');
		my @temp = split "##", $hash{$id};
		print $q->h2('Подтвердите удаление записи');
		print $q->start_table();
		print $q->Tr([
			$q->th(['Автор', 'Название', 'Год']),
			$q->start_form(-action => $q->url(), -method => 'post'),
			$q->hidden('id', $id),
			$q->td([
				split ("##", $hash{$id}),
				$q->submit('yes', 'Удалить'),
			]),
			$q->end_form
		]);
		print $q->end_table;
	}
}

sub add {
	#my $type = $q->cookie('db_type');
	if($db_type eq "mysql")
	{
		my $author = $q->param('a_a');
		my $title = $q->param('a_n');
		my $year = $q->param('a_y');
		if ($author . $title . $year) {
			print $q->h2('Запись добавлена');
			my $dbh = connect_to_mysql();			
			my $query = "INSERT INTO $db_table_name (author, title, year) VALUES (?, ?, ?)";
			my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
			my $rv = $sth->execute($author, $title, $year) or die "Не могу выполнить $DBI::errstr";
			$sth->finish(); $dbh->disconnect();
		}
	}
	else
	{
		my $id = [sort keys %hash]->[-1] + 1;
		my $autor = $q->param('a_a');
		my $title = $q->param('a_n');
		my $year = $q->param('a_y');
		if ($autor . $title . $year) {
			print $q->h2('Запись добавлена');
			$hash{$id} = join "##", ($autor, $title, $year);
		}
	}
	normal();
}

sub set {
	if($db_type eq "mysql")
	{
		my $id = $q->param('id');
		my $author = $q->param('e_a');
		my $title = $q->param('e_n');
		my $year = $q->param('e_y');
		my $dbh = connect_to_mysql();
		my $query =  "UPDATE $db_table_name SET author = ?, title = ?, year = ? WHERE id = ?";
		my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($author, $title, $year, $id) or die "Не могу выполнить $DBI::errstr";
		$sth->finish(); $dbh->disconnect();
		print $q->h2('Запись изменена');		
	}
	else
	{
		my $id = $q->param('id');
		my $autor = $q->param('e_a');
		my $title = $q->param('e_n');
		my $year = $q->param('e_y');
		if ($autor . $title . $year) {
			print $q->h2('Запись изменена');
			$hash{$id} = join "##", ($autor, $title, $year);
		}
	}
	normal();
}

sub remove {
	if($db_type eq "mysql")
	{
		my $id = $q->param('id');
		my $dbh = connect_to_mysql();		
		my $query =  "DELETE FROM $db_table_name WHERE id=?";
		my $sth = $dbh->prepare($query) or die "Не могу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($id) or die "Не могу выполнить $DBI::errstr";
		$sth->finish(); $dbh->disconnect();
	}
	else
	{
		my $id = $q->param('id');
		print $q->h2('Запись удалена');
		delete $hash{$id}; 
	}	
	normal();
}

1;
