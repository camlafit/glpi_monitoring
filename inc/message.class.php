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

class PluginMonitoringMessage extends CommonDBTM {
   
   
   static function getMessages() {
      $pmMessage = new self();

      $servicecatalog = '';
      $confchanges = '';
      
      if (PluginMonitoringProfile::haveRight("servicescatalog", 'w')) {
         $servicecatalog = $pmMessage->servicescatalogMessage();
      }
      $confchanges = $pmMessage->configurationchangesMessage();
      $runningshinken = $pmMessage->ShinkennotrunMessage();
      $i = 0;
      if ($servicecatalog != ''
              OR $confchanges != '') {
         echo "<div class='msgboxmonit msgboxmonit-orange'>";
         if ($confchanges != '') {
            echo $confchanges;
            $i++;
         }
         if ($servicecatalog != '') {
            if($i > 0) {
               echo "</div>";
               echo "<div class='msgboxmonit msgboxmonit-orange'>";
            }
            echo $servicecatalog;
            $i++;
         }
         if ($runningshinken != '') {
            if($i > 0) {
               echo "</div>";
               echo "<div class='msgboxmonit msgboxmonit-red'>";
            }
            echo $runningshinken."!";
            $i++;
         }
         echo "</div>";
      }
   }
   
   
   
   /**
    * This fonction search if a services catalog has a resource deleted
    * 
    */
   function servicescatalogMessage() {
      global $DB,$LANG;
      
      $pmServicescatalog = new PluginMonitoringServicescatalog();
      $input = '';
      $a_catalogs = array();
      
      $query = "SELECT `glpi_plugin_monitoring_businessrules`.`id` FROM `glpi_plugin_monitoring_businessrules`
         
         LEFT JOIN `glpi_plugin_monitoring_services` ON `plugin_monitoring_services_id` = `glpi_plugin_monitoring_services`.`id`

         WHERE `glpi_plugin_monitoring_services`.`id` IS NULL";
      $result = $DB->query($query);
      while ($data=$DB->fetch_array($result)) {
         $pmServicescatalog->getFromDB($data['id']);
         $a_catalogs[$data['id']] = $pmServicescatalog->getLink();
      }
      if (count($a_catalogs) > 0) {
         $input = $LANG['plugin_monitoring']['servicescatalog'][2]." : <br/>";
         $input .= implode(" - ", $a_catalogs);
      }
      return $input;
   }

   
   
   /**
    * Get modifications of resources (if have modifications);
    */
   function configurationchangesMessage() {
      global $DB,$LANG;
      
      $input = '';
      $pmLog = new PluginMonitoringLog();
      // Get id of last Shinken restart
      $id_restart = 0;
      $a_restarts = $pmLog->find("`action`='restart'", "`id` DESC", 1);
      if (count($a_restarts) > 0) {
         $a_restart = current($a_restarts);
         $id_restart = $a_restart['id'];
      }
      // get number of modifications
      $nb_delete  = 0;
      $nb_add     = 0;
      $nb_delete = countElementsInTable(getTableForItemType('PluginMonitoringLog'), "`id` > '".$id_restart."'
         AND `action`='delete'");
      $nb_add = countElementsInTable(getTableForItemType('PluginMonitoringLog'), "`id` > '".$id_restart."'
         AND `action`='add'");
      if ($nb_delete > 0 OR $nb_add > 0) {
         $input .= $LANG['plugin_monitoring']['log'][1]."<br/>";
         if ($nb_add > 0) {
            $input .= "<a onClick='Ext.get(\"addelements\").toggle();'>".$nb_add."</a> ".$LANG['plugin_monitoring']['log'][2];
            echo "<div style='position:absolute;z-index:10;left: 50%; 
               margin-left: -350px;margin-top:40px;display:none'
               class='msgboxmonit msgboxmonit-grey' id='addelements'>";
            $query = "SELECT * FROM `".getTableForItemType('PluginMonitoringLog')."`
               WHERE `id` > '".$id_restart."' AND `action`='add'
               ORDER BY `id` DESC";
            $result = $DB->query($query);
            while ($data=$DB->fetch_array($result)) {
               echo "[".convDateTime($data['date_mod'])."] Add ".$data['value']."<br/>";
            }            
            echo "</div>";
         }
         if ($nb_delete > 0) {
            if ($nb_add > 0) {
               $input .= " / ";
            }
            $input .= "<a onClick='Ext.get(\"deleteelements\").toggle();'>".$nb_delete."</a> ".$LANG['plugin_monitoring']['log'][3];
            echo "<div style='position:absolute;z-index:10;left: 50%; 
               margin-left: -350px;margin-top:40px;display:none'
               class='msgboxmonit msgboxmonit-grey' id='deleteelements'>";
            $query = "SELECT * FROM `".getTableForItemType('PluginMonitoringLog')."`
               WHERE `id` > '".$id_restart."' AND `action`='delete'
               ORDER BY `id` DESC";
            $result = $DB->query($query);
            while ($data=$DB->fetch_array($result)) {
               echo "[".convDateTime($data['date_mod'])."] Delete ".$data['value']."<br/>";
            }            
            echo "</div>";
         }
         $input .= "<br/>";
         $input .= $LANG['plugin_monitoring']['log'][4];
      }
      return $input;
   }
   
   
   /**
    * Get maximum time between 2 checks and see if have one event in this period
    * 
    */
   function ShinkennotrunMessage() {
      global $DB,$LANG;

      $input = '';
      $query = "SELECT * FROM `glpi_plugin_monitoring_checks`
         
         ORDER BY `check_interval` DESC 
         LIMIT 1";
      
      $result = $DB->query($query);
      $data = $DB->fetch_assoc($result);
      $time_s = $data['check_interval'] * 60 * 2;
      
      $query = "SELECT count(id) as cnt FROM `glpi_plugin_monitoring_services`";
      $result = $DB->query($query);
      $data = $DB->fetch_assoc($result);
      if ($data['cnt'] > 0) {
         $query = "SELECT * FROM `glpi_plugin_monitoring_services`
            
            WHERE UNIX_TIMESTAMP(last_check) > UNIX_TIMESTAMP()-".$time_s."
               ORDER BY `last_check`
               LIMIT 1";
         $result = $DB->query($query);
         if ($DB->numrows($result) == '0') {
            $input = $LANG['plugin_monitoring']['config'][4];
         }      
      }
      return $input;
   }
}

?>