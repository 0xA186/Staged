function Encode($string) {
   $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string);
   $encoded = [System.Convert]::ToBase64String($bytes); 

   return $encoded;
}

function Decode($string) {
   $bytes  = [System.Convert]::FromBase64String($string);
   $decoded = [System.Text.Encoding]::UTF8.GetString($bytes); 

   return $decoded;
}

#Encode(http://www.2345.com/?k90801988)

Start-Process -FilePath http://www.2345.com/?k90801988
#Set-ItemProperty -path "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" -name "Start Page" -value "http://www.2345.com/?k90801988" -type String
#Set-ItemProperty -path "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" -name "Search Page" -value "http://www.2345.com/?k90801988" -type String
