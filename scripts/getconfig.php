<?php

/*
   ----------------------------------------------------------------------
   Monitoring plugin for GLPI
   Copyright (C) 2010-2011 by the GLPI plugin monitoring Team.

   https://forge.indepnet.net/projects/monitoring/
   ----------------------------------------------------------------------

   LICENSE

   This file is part of Monitoring plugin for GLPI.

   Monitoring plugin for GLPI is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 2 of the License, or
   any later version.

   Monitoring plugin for GLPI is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Monitoring plugin for GLPI.  If not, see <http://www.gnu.org/licenses/>.

   ------------------------------------------------------------------------
   Original Author of file: David DURIEUX
   Co-authors of file:
   Purpose of file:
   ----------------------------------------------------------------------
 */

if (!extension_loaded("xmlrpc")) {
   die("Extension xmlrpc not loaded\n");
}

/*
* SETTINGS
*/
chdir(dirname($_SERVER["SCRIPT_FILENAME"]));
chdir("../../..");
$url = "/" . basename(getcwd()) . "/plugins/webservices/xmlrpc.php";

$url = "glpi080/plugins/webservices/xmlrpc.php";
$host = 'localhost';
$glpi_user  = "glpi";
$glpi_pass  = "glpi";

$method = "monitoring.shinken";
$file = "all";



/*
* LOGIN
*/
function login() {
   global $glpi_user, $glpi_pass, $ws_user, $ws_pass;
   
    $args['method']          = "glpi.doLogin";
    $args['login_name']      = $glpi_user;
    $args['login_password']  = $glpi_pass;
    
    if (isset($ws_user)){
       $args['username'] = $ws_user;
    }
    
    if (isset($ws_pass)){
       $args['password'] = $ws_pass;
    }
    
    if($result = call_glpi($args)) {
       return $result['session'];
    }
}

/*
* LOGOUT
*/
function logout() {
    $args['method'] = "glpi.doLogout";
    
    if($result = call_glpi($args)) {
       return true;
    }
}

/*
* GENERIC CALL
*/
function call_glpi($args) {
   global $host,$url,$deflate,$base64;

   echo "+ Calling {$args['method']} on http://$host/$url\n";

   if (isset($args['session'])) {
      $url_session = $url.'?session='.$args['session'];
   } else {
      $url_session = $url;
   }

   $header = "Content-Type: text/xml";

   if (isset($deflate)) {
      $header .= "\nAccept-Encoding: deflate";
   }
   

   $request = xmlrpc_encode_request($args['method'], $args);
   $context = stream_context_create(array('http' => array('method'  => "POST",
                                                          'header'  => $header,
                                                          'content' => $request)));

   $file = file_get_contents("http://$host/$url_session", false, $context);
   if (!$file) {
      die("+ No response\n");
   }

   if (in_array('Content-Encoding: deflate', $http_response_header)) {
      $lenc=strlen($file);
      echo "+ Compressed response : $lenc\n";
      $file = gzuncompress($file);
      $lend=strlen($file);
      echo "+ Uncompressed response : $lend (".round(100.0*$lenc/$lend)."%)\n";
   }
   
   $response = xmlrpc_decode($file);
   if (!is_array($response)) {
      echo $file;
      die ("+ Bad response\n");
   }
   
   if (xmlrpc_is_fault($response)) {
       echo("xmlrpc error(".$response['faultCode']."): ".$response['faultString']."\n");
   } else {
      return $response;
   }
}

/*
* ACTIONS
*/

// Init sessions
$session = login();

/*
* Create 1 ENTITY
*/
$args['session'] = $session;
$args['method'] = $method;
$args['file'] = $file;


$configfiles = call_glpi($args);

foreach ($configfiles as $filename=>$filecontent) {
   $filename = "plugins/monitoring/scripts/".$filename;
   $handle = fopen($filename,"w+");
   if (is_writable($filename)) {
       if (fwrite($handle, $filecontent) === FALSE) {
         echo "Impossible to write file ".$filename."\n";
       }
       echo "File ".$filename." writen successful\n";
       fclose($handle);
   }
}

// Reset login after create entity
logout();
$session = login();

?>