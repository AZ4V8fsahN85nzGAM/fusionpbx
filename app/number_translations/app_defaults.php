<?php
/*
	FusionPBX
	Version: MPL 1.1

	The contents of this file are subject to the Mozilla Public License Version
	1.1 (the "License"); you may not use this file except in compliance with
	the License. You may obtain a copy of the License at
	http://www.mozilla.org/MPL/

	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.

	The Original Code is FusionPBX

	The Initial Developer of the Original Code is
	Mark J Crane <markjcrane@fusionpbx.com>
	Portions created by the Initial Developer are Copyright (C) 2008-2017
	the Initial Developer. All Rights Reserved.

	Contributor(s):
	Matthew Vale <github@mafoo.org>
*/

	if ($domains_processed == 1) {
		//add the variables to the database
		$sql = "select count(*) from v_number_translations ";
		$num_rows = $database->select($sql, null, 'column');
		unset($sql);

		if ($num_rows == 0) {
			//get the array of xml files
			$xml_list = glob($_SERVER["PROJECT_ROOT"] . "/*/*/resources/switch/conf/number_translation/*.xml");

			//number_translation class
			$number_translation = new number_translations;

			//process the xml files
			foreach ($xml_list as $xml_file) {
				//get and parse the xml
					$number_translation->xml = file_get_contents($xml_file);
					$number_translation->import();
			}

			//check for existing configuration
			if (!empty($setting->get('switch','conf')) && file_exists($setting->get('switch','conf')."/autoload_configs/translate.conf.xml")) {
				//import existing data
				$xml = file_get_contents($setting->get('switch','conf')."/autoload_configs/translate.conf.xml");

				//convert the xml string to an xml object
				$xml = simplexml_load_string($xml);

				//convert to json
				$json = json_encode($xml);

				//convert to an array
				$number_translations = json_decode($json, true);
				if (array_key_exists('include', $number_translations)) {
					$number_translations = $number_translations['include'];
				}
				if (!empty($number_translations['configuration']) && $number_translations['configuration']['@attributes']['autogenerated'] != 'true') {
					foreach ($number_translations['configuration']['profiles']['profile'] as $profile) {
						$json = json_encode($profile);
						$number_translation->display_type = $display_type;
						$number_translation->json = $json;
						$number_translation->import();
					}
				}
			}
		}

	}

?>

