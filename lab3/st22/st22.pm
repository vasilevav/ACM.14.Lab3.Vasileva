
package ST22;
use DBI;
use Data::Dumper;
use strict;
use Encode 'from_to';

my $dbh;
my $selfurl;
my $stNum;
my %myRoomItems;

sub st22
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
				       <TITLE>3rd lab</TITLE>
				    </HEAD>
				    <BODY>
					    <hr>
						    <menu type="toolbar">
						    	<ul type="square">
							    	<li> <a href="$selfurl?action=0&student=$stNum" > Show all </a>	</li>
							    	<li> <a href="$selfurl?action=8&student=$stNum" > Add element </a> </li>
							    	<li> <a href="$selfurl?action=9&student=$stNum" > Modify element </a> </li>
							    	<li> <a href="$selfurl?action=10&student=$stNum"> Delete element </a> </li>
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
				    Designed by: ShishkinaV (st22) <BR>
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

		$dbh = DBI->connect('DBI:mysql:mydb:localhost:3306', 'root', '', { RaiseError => 1, AutoCommit => 1});
		loadFromDB();
		$arr[$action]->($params);

		$dbh->disconnect();
		#saveToFile();
	};


};

sub addItemForm
{
	print qq~<FORM action="$selfurl" name = SaveAndUpd>
				Element name:<BR>
			    <input type=text width = 40 name = "nameEl"> <BR>
			    Element color:<BR>
			    <input type=text width = 40 name = "colorEl"> <BR>
			    Element description:<BR>
			    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
			    Some bool indicator: 
			    <input type=checkbox name = "SBoolInd" value = 0 ><BR>
			    <INPUT TYPE="HIDDEN" NAME="action" VALUE ="1"/>
			    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
			    <input type = submit name = "btn" value = "Save"/><BR>
		    </FORM>~;
};

sub updItemForm
{
	print qq~<FORM action="$selfurl" name = SaveAndUpd>
			Element name:<BR>
		    <input type=text width = 40 name = "nameEl"> <BR>
		    Element color:<BR>
		    <input type=text width = 40 name = "colorEl"> <BR>
		    Element description:<BR>
		    <Textarea name = "descriptionEl" rows = 12 cols = 50 ></Textarea><BR>
		    Some bool indicator: 
		    <input type=checkbox name = "SBoolInd" value = 0 ><BR>
	    	<INPUT TYPE="HIDDEN" NAME=action VALUE ="2">
	    	<INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
		    <input type = submit name = btn  value = "Save changes"/><BR>
	    </FORM>~;
};


sub delItemForm
{
	print qq~	<FORM action="$selfurl" name = DelEl>
					Element name:<BR>
				    <input type=text width = 40 name = "nameEl">
				    <INPUT TYPE="HIDDEN" NAME=action VALUE ="3"> 
				    <INPUT TYPE="HIDDEN" NAME="student" VALUE =$stNum/>
				    <input type = submit name = btn value = "Delete"/><BR>
			    </FORM>~;
};


sub addItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");
	my $color = $params->param("colorEl");
	my $details = $params->param("descriptionEl");
	my $SBoolInd = $params->param("SBoolInd");
	if (defined $params->param("SBoolInd") )
	{
		$SBoolInd = "true";
	};
 	my @paramArr = ( $name,$color, $details,$SBoolInd);
	$dbh->do("insert into mydb.myitems (name, color, description,someboolindicator) values (?,?,?,?)", undef,@paramArr);
};


sub deleteItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");

	my @paramArr = ($name);
	$dbh->do("delete from mydb.myitems where name = ?", undef,@paramArr);
};


sub updateItem
{
	my ($params) = @_;
	my $name = $params->param("nameEl");
	my $color = $params->param("colorEl");
	my $details = $params->param("descriptionEl");
	my $SBoolInd = $params->param("SBoolInd");
	if (defined $params->param("SBoolInd") )
	{
		$SBoolInd = 1;
	};
 	my @paramArr = ( $color, $details,$SBoolInd, $name);
	$dbh->do("update mydb.myitems set color = ?, description = ?, someboolindicator = ? where name=?", undef,@paramArr);
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
			$resStr .= "<li>"."<B>"."Name of element: " ."</B>".$name."; ";
			#while((my $itemKey,my $itemInfo) = each %{$myRoomItems{$name}})
			foreach my $itemKey(sort keys %{$myRoomItems{$name}})
			{
				#print "Item info: ".$itemKey." ".$itemInfo."<BR>";
				#from_to($itemKey,'cp866','windows-1251');
				#from_to($itemInfo,'cp866','windows-1251');
				from_to($itemKey,'cp866','windows-1251');
				from_to(${$myRoomItems{$name}}{$itemKey},'cp866','windows-1251');
				$resStr .="<B>".$itemKey." of element: "."</B>".${$myRoomItems{$name}}{$itemKey}."; "
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
	dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";
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
		dbmopen(%buffHash,"ShishkinaDB",0644) || die "Error open to file!";

		while((my $name,my $item) = each %buffHash)
		{
			my @buf12 = undef();
			@buf12 =  split(/;/, $buffHash{$name}); 
			$myRoomItems{$name} = {color => @buf12[0], details =>  @buf12[1]};
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
	my $sql = $dbh->prepare("select name, color, description, someboolindicator from mydb.myitems");
	$sql->execute();
	while (my @rowAsArr = $sql->fetchrow_array())
	{
		my $name = @rowAsArr[0];
		my $color = @rowAsArr[1];
		my $details = @rowAsArr[2];
		my $SBoolInd = @rowAsArr[3]; 
		$myRoomItems{$name} = {"Color" => $color, "Details" => $details, "Some bool indicator"=>$SBoolInd};
	};
	$sql->finish();

};


