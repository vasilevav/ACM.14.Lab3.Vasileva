package Lab3;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
#use encoding("utf-8");
use Data::Dumper;
use utf8;
#use open qw( :encoding(UTF-8) :std );
#use charnames qw( :full :short );
#binmode(DATA, ":encoding(UTF-8)");
use URI::Escape;

use Encode;
#use Encode::from_to;
use DBI;



# Настройки MySQL подключения
my $db_host = "localhost";				# Адрес сервера
my $db_port = "3306";					# Порт
my $db_user = "root";					# Логин
my $db_pwd = "rootpwd";					# Пароль
my $db_name = "student_db1";			# Имя базы даных
my $db_table_name = "student_tablett";	# Название таблицы
# Строка подключения к базе для получения информации
my $dsn_test = "DBI:mysql:INFORMATION_SCHEMA;$db_host:$db_port";
# Строка подключения к рабочей базе 
my $dsn_work = "DBI:mysql:$db_name;$db_host:$db_port";
# Имя DBM файла
my $dbm_filename = "Student_DBM_File";
# Адрес страницы
my $selfurl;
# ID студента
my $St;
# Тип используемой базы по умолчанию mysql
my $db_type = "mysql";
# Массив строк-заголовков
my @student = ( 
	"Фамилия",
	"Имя",
	"Возраст",
	"Телефон"
	);
# Массив элементов (Используем при выборе типа базы "DBM файл")
my @elements =();

# Главная процедура
sub main
{
	# Массив ссылок на процедуры
	my @commands = (\&add, 
			   \&edit, 
			   \&del,
			   \&save, 
			   \&load,
			   \&show,
			   \&add_pre_process, 
			   \&edit_pre_process, 
			   \&del_pre_process,
			   \&dbm_to_sql,
			   \&sql_to_dbm);
			   
	my ($q, $global) = @_;
	my $cgi_app = new CGI;
	$St = $global->{student};
	$selfurl = $global->{selfurl};

	# Получаем параметр изменения типа используемой базы данных
	my $change = $cgi_app->param("change_db_type");
	# Если параметр передан - меняем куки
	if(defined $change)
	{
		# Меняем тип базы
		$db_type = $change;
		# Меняем куки на новые
		my $cookie = $cgi_app->cookie(
			-name  => 'db_type',
			-value => $db_type
		);
		undef $change;
		# Отправляем заголовки
		print $cgi_app->header(-type => "text/html", -charset => "utf-8", -cookie => $cookie);
		print $cgi_app->start_html(
			-head=>$cgi_app->meta(
                   {
                     -http_equiv => 'Refresh',
                     -content => '2;URL='.$ENV{'SCRIPT_NAME'}
                   }
                 ));
		print $cgi_app->end_html();
	}
	else
	{	
		print $cgi_app->header(-type => "text/html", -charset => "utf-8", -cookie => $cgi_app->cookie('db_type'));
		# Получаем тип используемой базы данных
		$db_type = $cgi_app->cookie('db_type') ;
	}
	my $act = $cgi_app->param("act");
	# Если заданы параметры - обрабатываем пункт меню
	if(defined $act) {
		# Проверяем корректность выбранного пункта меню
		if($act >= 0 && $act <= 10)
		{
			# Обрабатываем для базы DBM файл
			if($act < 9 && $db_type eq "dbm" )
			{
				# Используем сохранение/загрузку из файла dbm
				load();
				$commands[$act]->($cgi_app);
				save();
			}
			# Обрабатываем для базы MySQL
			else
			{
				$commands[$act]->($cgi_app);
			}			
		}
		else { print "<center>Не корректный пункт меню.center>"; }
	}
	# Если не выбрана обработка - просто отображаем меню
	else {		
	print qq~
			<html>
			    <Head>
			       <title>Лабораторная работа #3</title>
				   <STYLE type="text/css">
					a {
						display: block;
						width:200px;
						height: 25px;
						text-decoration:none;
						background:#f0f0f0;
						padding:5px;
						border: solid 1px #000;
					}
				   </style>
			    </Head>
				<body>
				    <center>
					<h3>Меню</h3>
							<form>
							<a href="$selfurl?student=$St&act=5&db_type=$db_type" id="show"> Показать </a>
						    <a href="$selfurl?student=$St&act=6&db_type=$db_type" id="add"> Добавить</a>
						    <a href="$selfurl?student=$St&act=7&db_type=$db_type" id="edit"> Редактировать </a>
						    <a href="$selfurl?student=$St&act=8&db_type=$db_type" id="del"> Удалить </a>
							<a href="$selfurl?student=$St&act=9&db_type=$db_type" id="dbm_to_sql"> dbm в sql </a>
							<a href="$selfurl?student=$St&act=10&db_type=$db_type" id="sql_to_dbm">sql в dbm</a>
							<label>Тип используемой базы
							<select id="selected_db_type" name="change_db_type" >~;
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
							print qq~							
							<input type="submit" value="Изменить"/>							
							</select>
							</label>
							</form>
					</center>
				    <BR>
				</body>
				</html>~;
	}
	# Если пришли после заполнения одной из форм (редактирования/удаления/добавления) 
	if(defined $cgi_app->param("btn"))
	{
		# Делаем редиррект на главную	
		print $cgi_app->start_html(
			-head=>$cgi_app->meta(
                   {
                     -http_equiv => 'Refresh',
                     -content => '2;URL='.$ENV{'SCRIPT_NAME'}
                   }
                 ));
		print $cgi_app->end_html();
	}	
};

1;

# Форма заполнения добавления элемента в базу
sub add_pre_process
{
	# Получаем параметры
	my ($params) 	= @_;
	my $st			= $params->param("student");
	my $act			= $params->param("act");
	my $db_type 	= $params->param("db_type");

	print qq~<center><h3>Работаем с $db_type</h3><FORM act="$selfurl" name = add_student>
				Имя<bR>
			    <input type=text width = 40 name = "name"> <BR>
			    Фамилия<bR>
			    <input type=text width = 40 name = "surname"> <BR>
			    Возраст<bR>
			    <input type=text width = 40 name = "age"><BR>
				Телефон<BR>
			    <input type=text width = 40 name = "tel"><BR>
			    <INPUT TYPE="HIDDEN" NAME="act" VALUE ="0"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
				<INPUT TYPE="HIDDEN" NAME="db_type" VALUE =$db_type/>
			    <input type = submit name = "btn" value = "Добавить"/><BR>
				<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ="button" value="Назад в главное"/></a><br>
		    </FORM></center>~;
};
# Подготовка к редактированию
sub edit_pre_process
{
	# Получили параметры
	my ($params) 	= @_;
	my $st			= $params->param("student");
	my $act			= $params->param("act");
	my $db_type 	= $params->param("db_type");
	# Выводим данные которые можно редактировать
	show($params);
	# Рисуем форму
	print qq~<center><FORM act="$selfurl" name = edit_student>
			Индекс<BR>
		    <input type=text width = 40 name = "index"> <BR>
			Имя<BR>
		    <input type=text width = 40 name = "name"> <BR>
		    Фамилия<BR>
		    <input type=text width = 40 name = "surname"> <BR>
		    Возраст<BR>
		    <input type=text width = 40 name = "age"><BR>
			Телефон<BR>
		    <input type=text width = 40 name = "tel"><BR>
	    	<INPUT TYPE="HIDDEN" NAME=act VALUE ="1">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
			<INPUT TYPE="HIDDEN" NAME="db_type" VALUE =$db_type/>
		    <input type = submit name = btn  value = "Редактировать"><BR>
			<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ="button" value="Назад в меню"/></a><br>
	    </FORM></cnter>~;
};
# Подготовка к удалению
sub del_pre_process
{
	# Получили параметры
	my ($params) 	= @_;
	my $st			= $params->param("student");
	my $act			= $params->param("act");
	my $db_type 	= $params->param("db_type");
	# Рисуем форму
	print qq~	<center><FORM act="$selfurl" name = delete_student>
					Индекс:<BR>
					<input type=text width = 40 name = "index"><BR>
				    <INPUT TYPE="HIDDEN" NAME=act VALUE ="2"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$St/>
					<INPUT TYPE="HIDDEN" NAME="db_type" VALUE =$db_type/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM></center>~;
	# Показываем записи которые есть в базе
	show($params);
};
# Соединение с базой
sub connect_to_mysql
{	
	# Соединяемся с базой которая наверняка есть на сервере: "INFORMATION_SCHEMA"
	my $dbh = DBI->connect($dsn_test, $db_user, $db_pwd, { RaiseError => 0, PrintError => 1, mysql_enable_utf8 => 1 } 
		) || die "Colud not connect to database: $DBI::errstr";
	# Если нету нашей базы - создаем
	my $query = "CREATE DATABASE IF NOT EXISTS $db_name";
	my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	my $rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
	# Закрываем соединение
	$sth->finish(); $dbh->disconnect();
	# Открываем соединение уже к рабочей базе
	my $dbh = DBI->connect($dsn_work, $db_user, $db_pwd, { RaiseError => 0, PrintError => 1, mysql_enable_utf8 => 1 } 
		) || die "Colud not connect to database: $DBI::errstr";
		#$dbh->do( 'SET NAMES cp1251' );
	# Если нет таблицы - создаем
	$query = "CREATE TABLE IF NOT EXISTS $db_table_name 
	(id int(11) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(32) NOT NULL,
	surname varchar(32) NOT NULL,
	age int(11) NOT NULL,
	telephone varchar(32) NOT NULL) DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci ENGINE=InnoDB";
								#####DEFAULT CHARACTER SET cp1251 DEFAULT COLLATE cp1251_general_ci ENGINE=InnoDB";
								#####DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci ENGINE=InnoDB";
	$sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	$rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
	# Возвращаем соединение
	return $dbh;
};
# Добавить
sub add
{
	my ($params) 		= @_;
	
	my $name 			= $params->param("name");
	my $surname		    = $params->param("surname");
	my $age				= $params->param("age");
	my $tel			    = $params->param("tel");
	my $db_method		= $params->param("db_type");
	if (!($age =~ /^\d+$/)) # Проверяем поле "возраст"
	{
		print "<center><b style='color:red;'>При заполнении произошли след ошибки: <br></b>";
		print "Поле <b><i>возраст</i></b> должен быть целочисленным<br></center>";
	}
	else
	{
	# Работа с MySQL
	if($db_method eq "mysql/")
	{
		print "<center>MySQL INSERT...</center>";
		# Соединение
		my $dbh = connect_to_mysql();			
		# Готовим запрос
		my $query = "INSERT INTO $db_table_name (name, surname, age, telephone) VALUES (?, ?, ?, ?)";
		my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($name, $surname, $age, $tel) or die "Немогу выполнить $DBI::errstr";
		$sth->finish(); $dbh->disconnect();
	}
	# Работа с DBM
	else
	{
		if (!($age =~ /^\d+$/)) # Проверяем поле "возраст"
		{
			print "<center><b style='color:red;'>При заполнении произошли след ошибки: <br></b>";
			print "Поле <b><i>возраст</i></b> должен быть целочисленным<br></center>";
		}
		else
		{
			push(@elements,
			{
				$student[0] => $name,
				$student[1] => $surname,
				$student[2] => $age,
				$student[3] => $tel
			});
			print "<center>Добавляем...</center>";
		}
	}
	}
};
# Редактирование
sub edit
{
	my ($params) 		= @_;
	my $index			= $params->param("index");
	my $name 			= $params->param("name");
	my $surname		    = $params->param("surname");
	my $age				= $params->param("age");
	my $tel			    = $params->param("tel");
	my $db_method		= $params->param("db_type");
	# Работаем с mysql
	if($db_method eq "mysql/")
	{
		print "<center>MySQL UPDATE...</center>";
		# Соединяемся
		my $dbh = connect_to_mysql();
		# Запрос на обновление данных
		my $query =  "UPDATE $db_table_name SET name = ?, surname = ?, age = ?, telephone = ? WHERE id = ?";
		my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
		# Выполняем запрос
		my $rv = $sth->execute($name, $surname, $age, $tel, $index) or die "Немогу выполнить $DBI::errstr";
		$sth->finish(); $dbh->disconnect();	
	}
	# Работаем с dbm
	else
	{
		my @errors = ();
		if (!($age =~ /^\d+$/)) # Возраст целое
		{
			push(@errors, "Значение поля <b><i>возраст</></b> должно быть целочисленным<br>");
		}
		if (!($index =~ /^\d+$/))  # Индекс целое
		{
			push(@errors, "Значение индекса должно быть целым.<br>");
		}
		if($index < 0 || $index > $#elements)
		{
			push(@errors, "Некорректный индекс !<br>");
		}
		# Если нет ошибок - редактируем
		if(scalar @errors == 0)
		{
			$elements[$index]->{$student[0]} = $name;
			$elements[$index]->{$student[1]} = $surname;
			$elements[$index]->{$student[2]} = $age;
			$elements[$index]->{$student[3]} = $tel;	
			print "<center>Редактируем...</center>";
		}
		# Иначе выводим ошибки
		else
		{
			print "<center><b style='color:red;'>При заполнении форм произошли следующие ошибки:<br></b>";
			print "<i>$_</i>" foreach @errors ;
			print "</center>";
		}
	}
};
# Удаление
sub del
{
	# Получили параметры
	my ($params) 		= @_;
	my $index	 		= $params->param("index");
	my $db_method		= $params->param("db_type");
	# Работаем с mysql
	if($db_method eq "mysql/")
	{
		print "<center>MySQL DELETE...</center>";
		my $dbh = connect_to_mysql();		
		# Запрос на удаление элемент с идентификатором == id
		my $query =  "DELETE FROM $db_table_name WHERE id=?";
		my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
		my $rv = $sth->execute($index) or die "Немогу выполнить $DBI::errstr";
		# Закрываем соединение
		$sth->finish(); $dbh->disconnect();	
	}
	# Работа с dbm
	else
	{
		# Проверка индекса
		if ($index =~ /^\d+$/ && $index >= 0 && $index <= $#elements)
		{
			splice @elements, $index, 1;
			print "<center>Удаляем элемент с индексом [".$index."]...</center>";
		}
		else
		{
			print "<center>Некорректный индекс !<br></center>";
		}
	}
};
# Вывод данных
sub show
{
	my ($params) 		= @_;
	my $db_method 		= $params->param("db_type");
	# Работаем с mysql
	if($db_method eq "mysql")
	{
		# Соединяемся
		my $dbh = connect_to_mysql();	
		# Делаем выборку всех строк из таблицы
		my $query =  "SELECT * FROM $db_table_name";
		my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
		# Выполняем запрос
		my $rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
		# Сюда будет делать выборку
		my ($id, $name, $surname, $age, $tel);
		# Привязываем переменные к столбцам
		$sth->bind_columns(\($id, $name, $surname, $age, $tel)) or die "Немогу привязать $DBI::errstr";
		$rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
		# Выводим данные в таблицу
		my $i = 0;
		print '<center><h3>Работаем с '.$db_method.'</h3><form><table>';
		print "<tr><td>Идентификатор</td><td>$student[0]</td><td>$student[1]</td><td>$student[2]</td><td>$student[3]</td></tr>";
		while($sth->fetch())
		{
			print "<tr><td>[".$id."]</td><td>$name</td><td>$surname</td><td>$age</td><td>$tel</td></tr>";
			$i++;
		}
		print "<tr><td>Общее количество элементов:</td><td colspan=4><center>".$i."</center></td></tr>";
		print "</table></form><br><a href=\"$ENV{'SCRIPT_NAME'}\"><input type ='button' value='Назад в меню'/></a></center>";
		$sth->finish(); $dbh->disconnect();	
	}
	# Работаем с dbm
	else
	{
		# Выводим таблицу
		print '<center><h3>Работаем с '.$db_method.'</h3><form><table>';
		print "<tr><td>Индекс</td><td>$student[0]</td><td>$student[1]</td><td>$student[2]</td><td>$student[3]</td></tr>";
		my $i = 0;
		# Выводим строки с элементами
		for my $href ( @elements ) 
		{
			print "<tr><td>[".$i++."]</td><td>$href->{$student[0]}</td><td>$href->{$student[1]}</td><td>$href->{$student[2]}</td><td>$href->{$student[3]}</td></tr>";
		}
		print "<tr><td>Общее количество элементов:</td><td colspan=4><center>".scalar @elements."</center></td></tr>";
		print '<tr><td colspan=5><center><input type="submit" value="Назад в меню"/></center></td></tr>';
		print "</table></form></center>";
	}
};
# Сохранить (для dbm)
sub save
{
	# Открываем
	dbmopen(my %recs, $dbm_filename, 0644) || die "Cannot open DBM dbmfile: $!";
	%recs = ();
	my $i = 0;
	my%buffHash;
	# Сохраняем построчно элементы разделяя параметры табуляциями
	for my $elem ( @elements )
	{
		my $str = join("\t",
				$elem->{$student[0]},
				$elem->{$student[1]},
				$elem->{$student[2]},
				$elem->{$student[3]});
		
		utf8::encode($str);
		$recs {$i++} = $str;
	}
	#my @bufArr = %buffHash;
	# Закрываем
	dbmclose(%recs);
};
# Загрузить (для dbm)
sub load
{
	# Открываем
	dbmopen(my %recs, $dbm_filename, 0644) || die "Cannot open DBM dbmfile: $!";
	# Чистим массив
	splice @elements, 0, scalar @elements;
	my $i = 0;
	# Читаем
	while ((my $key, my $val) = each %recs)
	{
		# Разделяем строки получая параметры
		my @entry = split /\t/, $val;
		foreach (@entry) { utf8::decode($_);}
		# Добавляем
		push @elements, 
		{
			$student[0] => $entry[0],
			$student[1] => $entry[1],
			$student[2] => $entry[2],
			$student[3] => $entry[3]
		};
	}
	# Закрываем
	dbmclose(%recs);
};
# Переносим все записи из dbm файла в mysql базу
sub dbm_to_sql
{
	# Открываем файл
	dbmopen(my %recs, $dbm_filename, 0644) || die "Cannot open DBM dbmfile: $!";
	# Чистим массив
	splice @elements, 0, $#elements + 1;
	my $i = 0;
	# Добавляем
	while ((my $key, my $val) = each %recs)
	{
		# Разбиваем строки получаем при этом все необходимы поля
		my @entry = split /\t/, $val;
		foreach (@entry) { utf8::encode($_);}
		push @elements, 
		{
			$student[0] => $entry[0],
			$student[1] => $entry[1],
			$student[2] => $entry[2],
			$student[3] => $entry[3]
		};
	}
	# Закрываем файл
	dbmclose(%recs);
	# Соединяемся с базой
	my $dbh = connect_to_mysql();
	# Запрос на удаление таблицы
	my $query = "DROP TABLE $db_table_name";
	my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	$sth->execute() or die "Немогу выполнить $DBI::errstr";
	# Закрываем соединение
	$sth->finish(); $dbh->disconnect();	
	# Соединяемся с базой повторно, это даст автоматическое создание таблицы которая отсутствует
	my $dbh = connect_to_mysql();
	# Запрос на добавление
	$query = "INSERT INTO $db_table_name (name, surname, age, telephone) VALUES (?, ?, ?, ?)";
	$sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	# Добавляем
	for my $href ( @elements ) 
	{
		$sth->execute(
			(
			$href->{$student[0]},
			$href->{$student[1]},
			$href->{$student[2]},
			$href->{$student[3]}
			)
		) or die "Немогу выполнить $DBI::errstr";
	}
	# Делаем выборку всех строк таблицы
	$query = "SELECT count(*) FROM $db_table_name";
	$sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	$sth->execute or die "Немогу выполнить $DBI::errstr";
	
	print "<center>Данные преобразования: <br> 
	- прочитано из dbm файла: ".scalar @elements."<br>
	- добавлено в таблицу <b>$db_table_name</b> mysql базы <b>$db_name</b>: ".$sth->fetchrow_array()."<br>
	<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ='button' value='Назад в меню'/></a></center>";
	# Закрываем соединение
	$sth->finish(); $dbh->disconnect();	
};
# Конвертирование из sql в dbm
sub sql_to_dbm
{
##################my $query =  "SELECT SCHEMA_NAME FROM SCHEMATA";
	# Соединяемся
	my $dbh = connect_to_mysql();	
	# Делаем выборку всех строк таблицы
	my $query = "SELECT * FROM $db_table_name";
	my $sth = $dbh->prepare($query) or die "Немогу подготовить $query: $DBI::errstr";
	# Выполняем запрос
	my $rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
	# Данные выбирать будем сюда
	my ($id, $name, $surname, $age, $tel);
	# Привязываем переменные к столбцам
	$sth->bind_columns(\($id, $name, $surname, $age, $tel)) or die "Немогу привязать $DBI::errstr";
	# Выполняем запрос
	my $rv = $sth->execute or die "Немогу выполнить $DBI::errstr";
	###
	# Открываем файл
	dbmopen(my %recs, $dbm_filename, 0644) || die "Cannot open DBM dbmfile: $!";
	my $i = 0;
	# Очищаем хеш
	%recs = ();
	###
	
	
use utf8;
no utf8;	

	
	while($sth->fetch())
	{	
		# Добавляем новую запись
		print "</br>";
		print join("|", $name, Dumper($name), $surname, Dumper($surname), $age, Dumper($age), $tel, Dumper($tel))."<br>";
		utf8::encode($name);
		utf8::encode($surname);
		utf8::encode($age);
		utf8::encode($tel);
		
		print join("|", $name, Dumper($name), $surname, Dumper($surname), $age, Dumper($age), $tel, Dumper($tel))."<br>";
		
		$recs {$i++} = join("\t",
				($name),
				($surname),
				($age),
				($tel));
				
		
	}
	# Закрываем соединение
	$sth->finish(); $dbh->disconnect();	
	my $size = keys %recs;
	# Закрываем файл
	dbmclose(%recs);
use utf8;	
	
	print "<center>Прочитано из MySQL  : ".$i."<br>";
	print "Записано в DBM файл: $size<br>";
	print "<a href=\"$ENV{'SCRIPT_NAME'}\"><input type ='button' value='Назад в меню'/></a></center>";
};