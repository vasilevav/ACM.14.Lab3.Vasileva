package ST04;
use DBI;
use Data::Dumper;
use strict;
use Encode 'from_to';

my $dbh;
my $selfurl;
my $stNum;
my %myRoomItems;

sub st04
{
	my ($q, $global) = @_;
	my $cgiAPI = new CGI;
	$stNum = $global->{student};
	$selfurl = $global->{selfurl};
	my $isappVS = $cgiAPI->param("isapp");
	if ($isappVS ==1) {
		#print "Content-type: text/html\n\n";
		mainFunc($cgiAPI);
		return 1;
	} 
	else {
		print "Content-type: text/html\n\n";
		print qq~
				<HTML>
				    <HEAD>
				       <TITLE>Spisok chlenov garajnogo kooperativa</TITLE>
				    </HEAD>
				    <BODY>
					    <hr>
						    <menu type="toolbar">
						    	<ul type="square">
							    	<li> <a href="$selfurl?action=0&student=$stNum" > Pokazat' ves' spisok </a>	</li>
							    	<li> <a href="$selfurl?action=8&student=$stNum" > Dobavit' ychastnika </a> </li>
							    	<li> <a href="$selfurl?action=9&student=$stNum" > Izmenit' ychstnika </a> </li>
							    	<li> <a href="$selfurl?action=10&student=$stNum"> Udalit' ychastnika </a> </li>
							    </ul>
						    </menu>
						 <hr>
					    <BR>
					    ~;

		mainFunc($cgiAPI);

		 
		print qq~
				    </BODY>
				    <footer>
				    <BR>
				    <hr>
				    Spisok chlenov garajnogo kooperativa <BR> 
					by Vorobev Nikita, ASM-14-04 <BR>
				    <a href="$global->{selfurl}">Back</a><BR>
				    </footer>
				</HTML>~;
		return 1;
	}
	

	
	
};

1;

sub mainFunc
{
	my ($params) = @_;
	my $action = $params->param("action");

	my @arr = (\&showAllItems, \&addItem, \&updateItem, \&deleteItem, \&saveToFile, 
				\&loadFromFile, \&saveToDB, \&loadFromDB, \&addItemForm, \&updItemForm, \&delItemForm);

	if(defined $action) {
		#loadFromFile();

		$dbh = DBI->connect('DBI:mysql:vorobev_baze:localhost:8889', 'root', 'root', { RaiseError => 1, AutoCommit => 1});
		loadFromDB();
		$arr[$action]->($params);

		$dbh->disconnect();
		#saveToFile();
	};


};

sub addItemForm
{
	print qq~<FORM action="$selfurl" name = SaveAndUpd>
				Imya vladelcya:<BR>
			    <input type=text width = 40 name = "nameVL"> <BR>
			    Marka avtomobilya:<BR>
			    <input type=text width = 40 name = "markaAV"> <BR>
			    Nomer garaja:<BR>
			    <input type=text width = 40 name = "numberGR"><BR>
				Nomer scheta:<BR>
			    <input type=text width = 40 name = "numberSCH"><BR>
			    Vozmojnost parkovki v nochnoe vremya: 
			    <input type=checkbox name = "nochVR" value = 0 ><BR>
			    <INPUT TYPE="HIDDEN" NAME="action" VALUE ="1"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
			    <input type = submit name = "btn" value = "Save"/><BR>
		    </FORM>~;
};

sub updItemForm
{
	print qq~<FORM action="$selfurl" name = SaveAndUpd>
				Imya vladelcya:<BR>
			    <input type=text width = 40 name = "nameVL"> <BR>
			    Marka avtomobilya:<BR>
			    <input type=text width = 40 name = "markaAV"> <BR>
			    Nomer garaja:<BR>
			    <input type=text width = 40 name = "numberGR"><BR>
				Nomer scheta:<BR>
			    <input type=text width = 40 name = "numberSCH"><BR>
			    Vozmojnost parkovki v nochnoe vremya: 
			    <input type=checkbox name = "nochVR" value = 0 ><BR>
	    	<INPUT TYPE="HIDDEN" NAME=action VALUE ="2">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
		    <input type = submit name = btn  value = "Save changes"/><BR>
	    </FORM>~;
};


sub delItemForm
{
	print qq~	<FORM action="$selfurl" name = DelEl>
					Imya vladelcya:<BR>
					<input type=text width = 40 name = "nameVL"> <BR>
				    <INPUT TYPE="HIDDEN" NAME=action VALUE ="3"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM>~;
};


sub addItem
{
	my ($params) = @_;
	my $name = $params->param("nameVL");
	my $marka = $params->param("markaAV");
	my $number = $params->param("numberGR");
	my $schet = $params->param("numberSCH");
	my $nochVR = $params->param("nochVR");
	if (defined $params->param("nochVR") )
	{
		$nochVR = "da";
	} else {
		$nochVR = "net";
	};
 	my @paramArr = ( $name,$marka,$number,$schet,$nochVR);
	$dbh->do("insert into vorobev_baze.g_koop (name, marka, number, schet, nochnoevremya) values (?,?,?,?,?)", undef,@paramArr);
};


sub deleteItem
{
	my ($params) = @_;
	my $name = $params->param("nameVL");

	my @paramArr = ($name);
	$dbh->do("delete from vorobev_baze.g_koop where name = ?", undef,@paramArr);
};


sub updateItem
{
	my ($params) = @_;
	my $name = $params->param("nameVL");
	my $marka = $params->param("markaAV");
	my $number = $params->param("numberGR");
	my $schet = $params->param("numberSCH");
	my $nochVR = $params->param("nochVR");
	if (defined $params->param("nochVR") )
	{
		$nochVR = "da";
	} else {
		$nochVR = "net";
	};
 	my @paramArr = ( $marka,$number,$schet, $nochVR, $name);
	$dbh->do("update vorobev_baze.g_koop set marka = ?, number = ?, schet = ?, nochnoevremya = ? where name = ?", undef,@paramArr);
};


sub showAllItems
{
	my ($params) = @_;
	my $resStr;
	my $isappVS = $params->param("isapp");
	if ($isappVS ==1) {
		#print "Content-type: text/html\n\n";
		while((my $name,my $item) = each %myRoomItems)
		{
			from_to($name,'cp866','windows-1251');
			$resStr .= $name;
			#while((my $itemKey,my $itemInfo) = each %{$myRoomItems{$name}})
			foreach my $itemKey(sort keys %{$myRoomItems{$name}})
			{
				#print "Item info: ".$itemKey." ".$itemInfo."<BR>";
				from_to($itemKey,'cp866','windows-1251');
				from_to(${$myRoomItems{$name}}{$itemKey},'cp866','windows-1251');
				$resStr .= "_".${$myRoomItems{$name}}{$itemKey};
			};
			$resStr .= ";";
		};
	} 
	else
	{
		$resStr .=  "<ul type=circle>";
		while((my $name,my $item) = each %myRoomItems)
		{
			from_to($name,'cp866','windows-1251');
			$resStr .= "<li>"."<B>"."Imya vladelcya: " ."</B>".$name."; ";
			#while((my $itemKey,my $itemInfo) = each %{$myRoomItems{$name}})
			foreach my $itemKey(sort keys %{$myRoomItems{$name}})
			{
				#print "Item info: ".$itemKey." ".$itemInfo."<BR>";
				#from_to($itemKey,'cp866','windows-1251');
				#from_to($itemInfo,'cp866','windows-1251');
				from_to($itemKey,'cp866','windows-1251');
				from_to(${$myRoomItems{$name}}{$itemKey},'cp866','windows-1251');
				$resStr .="<B>".$itemKey." : "."</B>".${$myRoomItems{$name}}{$itemKey}."; "
			};
			$resStr .= "</li>";
		};
		$resStr .= "</ul>";	
	};

	print $resStr;
};


sub saveToFile
{
	my %buffHash;
	dbmopen(%buffHash,"vorobev_baze",0666) || die "Error open to file!";
	my $bufStr = undef();
	
	while((my $name,my $item) = each %myRoomItems)
	{
		$bufStr = undef();
		foreach my $itemKey (keys %{$myRoomItems{$name}})
		{
			$bufStr = $bufStr.${$myRoomItems{$name}}{$itemKey}.";";
		};		
		$buffHash{$name} = $bufStr;
	};
	my @bufArr = %buffHash;
	dbmclose(%buffHash);		
};


sub loadFromFile
{
	#print "<BR>"."loadFromFile\n"."<BR>";
		my %buffHash = undef();
		my $bufStr;
		dbmopen(%buffHash,"vorobev_baze",0666) || die "Error open to file!";

		while((my $name,my $item) = each %buffHash)
		{
			my @buf12 = undef();
			@buf12 =  split(/;/, $buffHash{$name}); 
			$myRoomItems{$name} = {marka => @buf12[0], number =>  @buf12[1], schet =>  @buf12[2]};
		};
		dbmclose(%buffHash);
};


sub saveToDB
{
	return 1;
};


sub loadFromDB
{
	%myRoomItems = ();
	my $sql = $dbh->prepare("select name, marka, number, schet, nochnoevremya from vorobev_baze.g_koop");
	$sql->execute();
	while (my @rowAsArr = $sql->fetchrow_array())
	{
		my $name = @rowAsArr[0];
		my $marka = @rowAsArr[1];
		my $number = @rowAsArr[2];
		my $schet = @rowAsArr[3];
		my $nochVR = @rowAsArr[4]; 
		$myRoomItems{$name} = {"Marka" => $marka, "Nomer garaja" => $number, "Nomer scheta" => $schet, "Vozmojnost parkovki v nochnoe vremya"=>$nochVR};
	};
	$sql->finish();

};


