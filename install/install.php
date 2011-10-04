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

function pluginMonitoringInstall($version) {
   global $DB,$LANG,$CFG_GLPI;

   // ** Insert in DB
   $DB_file = GLPI_ROOT ."/plugins/monitoring/install/mysql/plugin_monitoring-"
              .$version."-empty.sql";
   $DBf_handle = fopen($DB_file, "rt");
   $sql_query = fread($DBf_handle, filesize($DB_file));
   fclose($DBf_handle);
   foreach ( explode(";\n", "$sql_query") as $sql_line) {
      if (get_magic_quotes_runtime()) $sql_line=stripslashes_deep($sql_line);
      if (!empty($sql_line)) $DB->query($sql_line);
   }

   include (GLPI_ROOT . "/plugins/monitoring/inc/command.class.php");
   $pluginMonitoringCommand = new PluginMonitoringCommand();
   $pluginMonitoringCommand->initCommands();
   include (GLPI_ROOT . "/plugins/monitoring/inc/notificationcommand.class.php");
   $pluginMonitoringNotificationcommand = new PluginMonitoringNotificationcommand();
   $pluginMonitoringNotificationcommand->initCommands();
   include (GLPI_ROOT . "/plugins/monitoring/inc/check.class.php");
   $pluginMonitoringCheck = new PluginMonitoringCheck();
   $pluginMonitoringCheck->initChecks();
   
   if (!is_dir(GLPI_PLUGIN_DOC_DIR.'/monitoring')) {
      mkdir(GLPI_PLUGIN_DOC_DIR."/monitoring");
   }
   
   CronTask::Register('PluginMonitoringServiceevent', 'updaterrd', '300', 
                      array('mode' => 2, 'allowmode' => 3, 'logs_lifetime'=> 30));
  
   
}


function pluginMonitoringUninstall() {
   global $DB;

   $query = "SHOW TABLES;";
   $result=$DB->query($query);
   while ($data=$DB->fetch_array($result)) {
      if (strstr($data[0],"glpi_plugin_monitoring_")) {
         $query_delete = "DROP TABLE `".$data[0]."`;";
         $DB->query($query_delete) or die($DB->error());
      }
   }
}

?>