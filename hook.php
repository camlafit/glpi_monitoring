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

function plugin_monitoring_giveItem($type,$id,$data,$num) {

//   $searchopt = &Search::getOptions($type);
//   $table = $searchopt[$id]["table"];
//   $field = $searchopt[$id]["field"];
//         
//   switch ($table.'.'.$field) {
//
//   }

   return "";
}



/* Cron */
function cron_plugin_monitoring() {
   return 1;
}



function plugin_monitoring_install() {

   include (GLPI_ROOT . "/plugins/monitoring/install/update.php");
   $version_detected = pluginMonitoringGetCurrentVersion(PLUGIN_MONITORING_VERSION);
   if ((isset($version_detected)) 
           AND ($version_detected != PLUGIN_MONITORING_VERSION)
           AND $version_detected != '0') {
      pluginMonitoringUpdate($version_detected);
   } else {
      include (GLPI_ROOT . "/plugins/monitoring/install/install.php");
      pluginMonitoringInstall(PLUGIN_MONITORING_VERSION);
   }
      
   return true;
}

// Uninstall process for plugin : need to return true if succeeded
function plugin_monitoring_uninstall() {
   include (GLPI_ROOT . "/plugins/monitoring/install/install.php");
   pluginMonitoringUninstall();
   return true;
}

// Define headings added by the plugin //
function plugin_get_headings_monitoring($item,$withtemplate) {
   global $LANG;

   switch (get_class($item)) {
      
      case 'Computer' :
      case 'Device':
      case 'Printer':
      case 'NetworkEquipment':
         $array = array();
         //$array[0] = $LANG['plugin_monitoring']['title'][0]."-".$LANG['state'][0];
         if ($_GET['id'] > 0) {
            $array[2] = $LANG['plugin_monitoring']['title'][0]."-".$LANG['plugin_monitoring']['service'][0];
         }
         return $array;
         break;
      
      case 'User':
         $array = array();
         //$array[0] = $LANG['plugin_monitoring']['title'][0]."-".$LANG['state'][0];
         if ($_GET['id'] > 0) {
            $array[1] = $LANG['plugin_monitoring']['title'][0]."-".$LANG['plugin_monitoring']['contact'][0];
         }
         return $array;
         break;
      
      case 'PluginMonitoringServicescatalog':
         $array = array();
         if ($_GET['id'] > 0) {
            $array[0] = $LANG['plugin_monitoring']['title'][0]."-".$LANG['plugin_monitoring']['businessrule'][0];
         }
         return $array;
         break;
      
      case 'Entity':
         $array = array();
         $array[0] = $LANG['plugin_monitoring']['title'][0];
         return $array;
         break;
      
   }

   return false;
}

// Define headings actions added by the plugin
//function plugin_headings_actions_fusioninventory($type) {
function plugin_headings_actions_monitoring($item) {

   switch (get_class($item)) {
      
      case 'Computer':
      case 'Device':
      case 'Printer':
      case 'NetworkEquipment':
         $array = array ();
//         $array[0] = "plugin_headings_monitoring_status";
         $array[2] = "plugin_headings_monitoring_resources";
         return $array;
         break;
      
      case 'User':
         $array = array ();
//         $array[0] = "plugin_headings_monitoring_status";
         $array[1] = "plugin_headings_monitoring_contacts";
         return $array;
         break;
      
      case 'PluginMonitoringServicescatalog':
         $array = array ();
         $array[0] = "plugin_headings_monitoring_businessrules";
         return $array;
         break;
      
      case 'Entity':
         $array = array();
         $array[0] = "plugin_headings_monitoring_entitytag";
         return $array;
         break;
      
   }
   return false;
}


function plugin_headings_monitoring_status($item) {

$plu = new PluginMonitoringHostevent();
$plu->parseToRrdtool($item->fields['id'], get_class($item));
$to = new PluginMonitoringRrdtool();
//$to->displayGLPIGraph("Computer", $item->fields['id'], "3h");
//$to->displayGLPIGraph("Computer", $item->fields['id']);
//$to->displayGLPIGraph("Computer", $item->fields['id'], "1w");

//echo "<img src='".GLPI_ROOT."/plugins/monitoring/front/send.php?file=Computer-".$item->fields['id']."-3h.gif' />";
//echo "<br/>";
//echo "<img src='".GLPI_ROOT."/plugins/monitoring/front/send.php?file=Computer-".$item->fields['id']."-1d.gif' />";

$plus = new PluginMonitoringServiceevent();
$plus->parseToRrdtool($item->fields['id'], get_class($item));
$to = new PluginMonitoringRrdtool();

echo "<br/>Http :<br/>";
//$to->displayGLPIGraph("PluginMonitoringHost_Service", 5, "12h");
//echo "<img src='".GLPI_ROOT."/plugins/monitoring/front/send.php?file=PluginMonitoringService-5-12h.gif' />";

   
   $pmHostevent = new PluginMonitoringHostevent();
   $pmHostevent->showForm($item);

}



function plugin_headings_monitoring_resources($item) {

   $pmService = new PluginMonitoringService();
   $pmService->manageServices(get_class($item), $item->fields['id']);
   $pmHostconfig = new PluginMonitoringHostconfig();
   $pmHostconfig->showForm($item->getID(), get_class($item));
}



function plugin_headings_monitoring_businessrules($item) {
   $pMonitoringBusinessrule = new PluginMonitoringBusinessrule();
   $pMonitoringBusinessrule->showForm($item->fields['id']);
}



function plugin_headings_monitoring_contacts($item) {

   $pmContact = new PluginMonitoringContact();
   $pmContact->showForm(0);
}



function plugin_headings_monitoring_entitytag($item) {
   $pmEntity = new PluginMonitoringEntity();
   $pmHostconfig = new PluginMonitoringHostconfig();
   
   $pmHostconfig->showForm($item->getID(), "Entity");
   $pmEntity->showForm($item->fields['id']);
}



function plugin_headings_monitoring_tasks($item, $itemtype='', $items_id=0) {
 
}



function plugin_headings_monitoring($item, $withtemplate=0) {

}



function plugin_monitoring_MassiveActionsFieldsDisplay($options=array()) {

   return false;
}



function plugin_monitoring_MassiveActions($type) {
   global $LANG;

   switch ($type) {
      case "Computer":
         return array (
            "plugin_monitoring_activatehosts" => $LANG['plugin_monitoring']['host'][18]
         );
         break;
   }

   return array ();
}



function plugin_monitoring_MassiveActionsDisplay($options=array()) {
   global $LANG, $CFG_GLPI;

   switch ($options['itemtype']) {
      case "Computer":
         switch ($options['action']) {
            case "plugin_monitoring_activatehosts" :
               $pmHost = new PluginMonitoringHost();
               $a_list = $pmHost->find("`is_template`='1'");
               $a_elements = array();
               foreach ($a_list as $data) {
                  $a_elements[$data['id']] = $data['template_name'];
               }
               $rand = Dropdown::showFromArray("template_id", $a_elements);
               echo "<img alt='' title=\"".$LANG['buttons'][8]."\" src='".$CFG_GLPI["root_doc"].
                     "/pics/add_dropdown.png' style='cursor:pointer; margin-left:2px;'
                     onClick=\"var w = window.open('".$pmHost->getFormURL()."?withtemplate=1&popup=1&amp;rand=".
                     $rand."' ,'glpipopup', 'height=400, ".
                     "width=1000, top=100, left=100, scrollbars=yes' );w.focus();\">";
               echo "<input name='add' value='Post' class='submit' type='submit'>";
               break;
         }
         break;
   }

   return "";
}



function plugin_monitoring_MassiveActionsProcess($data) {

   switch ($data['action']) {
      case "plugin_monitoring_activatehosts" :
         if ($data['itemtype'] == "Computer") {
            $pmHost = new PluginMonitoringHost();
            foreach ($data['item'] as $key => $val) {
               if ($val == '1') {
                  $pmHost->massiveactionAddHost($data['itemtype'], $key, $data['template_id']);
               }
            }
         }
         break;
         
   }
}


function plugin_monitoring_addSelect($type,$id,$num) {

//   $searchopt = &Search::getOptions($type);
//   $table = $searchopt[$id]["table"];
//   $field = $searchopt[$id]["field"];
//
//   switch ($type) {
//
//   }
   return "";
}


function plugin_monitoring_forceGroupBy($type) {
    return false;
}


function plugin_monitoring_addLeftJoin($itemtype,$ref_table,$new_table,$linkfield,&$already_link_tables) {

   switch ($itemtype) {
      
   }
   return "";
}


function plugin_monitoring_addOrderBy($type,$id,$order,$key=0) {
   return "";
}


function plugin_monitoring_addDefaultWhere($type) {
 
}


function plugin_monitoring_addWhere($link,$nott,$type,$id,$val) {
	global $SEARCH_OPTION;

//   $searchopt = &Search::getOptions($type);
//   $table = $searchopt[$id]["table"];
//   $field = $searchopt[$id]["field"];
//
//   switch ($type) {
//
//   }
   return "";
}


/*
 * Webservices
 */
function plugin_monitoring_registerMethods() {
   global $WEBSERVICES_METHOD;

   $WEBSERVICES_METHOD['monitoring.shinkenGetConffiles'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenGetConffiles');
   # Get commands for arbiter
   $WEBSERVICES_METHOD['monitoring.shinkenCommands'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenCommands');
   $WEBSERVICES_METHOD['monitoring.shinkenHosts'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenHosts');
   $WEBSERVICES_METHOD['monitoring.shinkenContacts'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenContacts');
   $WEBSERVICES_METHOD['monitoring.shinkenTimeperiods'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenTimeperiods');
   
   $WEBSERVICES_METHOD['monitoring.shinkenServices'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenServices');
   $WEBSERVICES_METHOD['monitoring.shinkenTemplates'] = array('PluginMonitoringWebservice',
                                                       'methodShinkenTemplates');
   $WEBSERVICES_METHOD['monitoring.dashboard'] = array('PluginMonitoringWebservice',
                                                       'methodDashboard');
   $WEBSERVICES_METHOD['monitoring.getServicesList'] = array('PluginMonitoringWebservice',
                                                             'methodGetServicesList');
   $WEBSERVICES_METHOD['monitoring.doLogin'] = array('PluginWebservicesMethodSession',
                                                     'methodLogin');
   $WEBSERVICES_METHOD['monitoring.doLogout'] = array('PluginWebservicesMethodSession',
                                                     'methodLogout');
}

/**
 * Define Dropdown tables to be manage in GLPI :
**/
function plugin_monitoring_getDropdown(){
   global $LANG;

   return array('PluginMonitoringServicescatalog'     => $LANG['plugin_monitoring']['servicescatalog'][0],
                'PluginMonitoringCheck'               => $LANG['plugin_monitoring']['check'][0],
                'PluginMonitoringCommand'             => $LANG['plugin_monitoring']['command'][0],
                'PluginMonitoringComponentscatalog'   => $LANG['plugin_monitoring']['componentscatalog'][0],
                'PluginMonitoringComponent'           => $LANG['plugin_monitoring']['component'][0]);
}

?>
