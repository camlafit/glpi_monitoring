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
   die("Sorry. You can't access directly to this file");
}

class PluginMonitoringNotificationcommand extends CommonDBTM {
   

   function initCommands() {
      global $DB;

      $input = array();
      $input['name'] = 'Host : notify by mail';
      $input['command_name'] = 'notify-host-by-email';
      $input['command_line'] = "\$PLUGINSDIR\$/sendmailhost.pl \"\$NOTIFICATIONTYPE\$\" \"\$HOSTNAME\$\" \"\$HOSTSTATE\$\" \"\$HOSTADDRESS\$\" \"\$HOSTOUTPUT\$\" \"\$SHORTDATETIME\$\" \"\$CONTACTEMAIL\$\"";
      $this->add($input);

      $input = array();
      $input['name'] = 'Service : notify by mail';
      $input['command_name'] = 'notify-service-by-email';
      $input['command_line'] = "\$PLUGINSDIR\$/sendmailservices.pl \"\$NOTIFICATIONTYPE\$\" \"\$SERVICEDESC\$\" \"\$HOSTALIAS\$\" \"\$HOSTADDRESS\$\" \"\$SERVICESTATE\$\" \"\$SHORTDATETIME\$\" \"\$SERVICEOUTPUT\$\" \"\$CONTACTEMAIL\$\" \"\$SERVICENOTESURL\$\"";
      $this->add($input);
      
   }

   

   /**
   * Get name of this type
   *
   *@return text name of this type by language of the user connected
   *
   **/
   static function getTypeName() {
      global $LANG;

      return "notification commands";
   }



   function canCreate() {
      return haveRight('computer', 'w');
   }


   
   function canView() {
      return haveRight('computer', 'r');
   }


   
   function canCancel() {
      return haveRight('computer', 'w');
   }


   
   function canUndo() {
      return haveRight('computer', 'w');
   }


   
   function canValidate() {
      return true;
   }

   

   function getSearchOptions() {
      global $LANG;

      $tab = array();
    
      $tab['common'] = "notification commands";

		$tab[1]['table'] = $this->getTable();
		$tab[1]['field'] = 'name';
		$tab[1]['linkfield'] = 'name';
		$tab[1]['name'] = $LANG['common'][16];
		$tab[1]['datatype'] = 'itemlink';

      $tab[2]['table']     = $this->getTable();
      $tab[2]['field']     = 'is_active';
      $tab[2]['linkfield'] = 'is_active';
      $tab[2]['name']      = $LANG['common'][60];
      $tab[2]['datatype']  = 'bool';

      return $tab;
   }



   function defineTabs($options=array()){
      global $LANG,$CFG_GLPI;

      $ong = array();

      return $ong;
   }



   /**
   * Display form for agent configuration
   *
   * @param $items_id integer ID 
   * @param $options array
   *
   *@return bool true if form is ok
   *
   **/
   function showForm($items_id, $options=array()) {
      global $DB,$CFG_GLPI,$LANG;

      if ($items_id!='') {
         $this->getFromDB($items_id);
      } else {
         $this->getEmpty();
      }

      $this->showTabs($options);
      $this->showFormHeader($options);


      
      $this->showFormButtons($options);
      $this->addDivForTabs();

      return true;
   }
}

?>