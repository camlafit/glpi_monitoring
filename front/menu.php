<?php

/*
   ------------------------------------------------------------------------
   Plugin Monitoring for GLPI
   Copyright (C) 2011-2012 by the Plugin Monitoring for GLPI Development Team.

   https://forge.indepnet.net/projects/monitoring/
   ------------------------------------------------------------------------

   LICENSE

   This file is part of Plugin Monitoring project.

   Plugin Monitoring for GLPI is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Plugin Monitoring for GLPI is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with Behaviors. If not, see <http://www.gnu.org/licenses/>.

   ------------------------------------------------------------------------

   @package   Plugin Monitoring for GLPI
   @author    David Durieux
   @co-author 
   @comment   
   @copyright Copyright (c) 2011-2012 Plugin Monitoring for GLPI team
   @license   AGPL License 3.0 or (at your option) any later version
              http://www.gnu.org/licenses/agpl-3.0-standalone.html
   @link      https://forge.indepnet.net/projects/monitoring/
   @since     2011
 
   ------------------------------------------------------------------------
 */

if (!defined('GLPI_ROOT')) {
   define('GLPI_ROOT', '../../..');
}

include (GLPI_ROOT."/inc/includes.php");

checkCentralAccess();

commonHeader($LANG['plugin_monitoring']['title'][0], $_SERVER["PHP_SELF"], "plugins",
             "monitoring", "menu");

$pmMessage = new PluginMonitoringMessage();
$pmMessage->getMessages();

echo "<table class='tab_cadre' width='950'>";

echo "<tr class='tab_bg_1'>";
echo "<th height='80'>";
echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/display.php'>".$LANG['plugin_monitoring']['display'][0]."</a>";
echo "</th>";
echo "</tr>";
echo "</table>";

echo "<br/>";

echo "<table class='tab_cadre' width='950'>";
echo "<tr class='tab_bg_1'>";
echo "<th align='center' height='50' width='33%'>";
if (PluginMonitoringProfile::haveRight("servicescatalog", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/servicescatalog.php'>".$LANG['plugin_monitoring']['servicescatalog'][0]."</a>";
}
echo "</th>";

echo "<th width='33%'>";
if (PluginMonitoringProfile::haveRight("weathermap", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/weathermap.php'>".$LANG['plugin_monitoring']['weathermap'][0]."</a>";
}
echo "</th>";

echo "<th>";
if (PluginMonitoringProfile::haveRight("view", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/displayview.php'>".$LANG['plugin_monitoring']['displayview'][0]."</a>";
}
echo "</th>";
echo "</tr>";
echo "</table>";

echo "<br/>";

echo "<table class='tab_cadre' width='950'>";
echo "<th height='40'>";
if (PluginMonitoringProfile::haveRight("componentscatalog", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/componentscatalog.php'>".$LANG['plugin_monitoring']['componentscatalog'][0]."</a>";
}
echo "</th>";
echo "</tr>";
echo "</table>";

echo "<br/>";

echo "<table class='tab_cadre' width='950'>";
echo "<tr class='tab_bg_1'>";
echo "<th colspan='4' height='30' width='75%'>";
if (PluginMonitoringProfile::haveRight("component", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/component.php'>".$LANG['plugin_monitoring']['component'][0]."</a>";
}
echo "</th>";

echo "<th rowspan='2'>";
if (PluginMonitoringProfile::haveRight("config", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/contacttemplate.php'>".$LANG['plugin_monitoring']['contacttemplate'][0]."</a>";
}
echo "</th>";

echo "<th rowspan='2'>";
if (PluginMonitoringProfile::haveRight("config", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/realm.php'>".$LANG['plugin_monitoring']['realms'][0]."</a>";
}
echo "</th>";
echo "</tr>";

echo "<tr class='tab_bg_1'>";
echo "<th width='18%' height='25'>";
if (PluginMonitoringProfile::haveRight("command", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/command.php'>".$LANG['plugin_monitoring']['command'][0]."</a>";
}
echo "</th>";

echo "<th width='18%'>";
if (PluginMonitoringProfile::haveRight("check", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/check.php'>".$LANG['plugin_monitoring']['check'][0]."</a>";
}
echo "</th>";

echo "<th width='18%'>";
if (haveRight('calendar', 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/front/calendar.php'>".$LANG['buttons'][15]."</a>";
}
echo "</th>";

echo "<th width='18%'>";
if (PluginMonitoringProfile::haveRight("config", 'r')) {
   echo "<a href='".$CFG_GLPI['root_doc']."/plugins/monitoring/front/rrdtemplate.php'>".$LANG['plugin_monitoring']['rrdtemplates'][0]."</a>";
}
echo "</th>";

echo "</table>";

commonFooter();

?>