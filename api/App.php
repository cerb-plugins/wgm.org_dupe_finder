<?php
if(class_exists('Extension_WorkspaceTab', true)):
class WorkspaceTab_WgmOrgDupeFinder extends Extension_WorkspaceTab {
	public function renderTab(Model_WorkspacePage $page, Model_WorkspaceTab $tab) {
		$tpl = DevblocksPlatform::getTemplateService();
		$tpl->display('devblocks:wgm.org_dupe_finder::tab.tpl');
	}
	
	function findDupesAction() {
		$starts_with = DevblocksPlatform::importGPC($_REQUEST['starts_with'],'string','');

		$db = DevblocksPlatform::getDatabaseService();
		$tpl = DevblocksPlatform::getTemplateService();
		
		// Drop the tmp table if it exists
		$db->Execute("DROP TABLE IF EXISTS tmp_soundex");
		
		// Create a new soundex index
		$snd_len = 6;
		$min_len = 4;
		$sql = sprintf("CREATE TEMPORARY TABLE tmp_soundex ".
			"SELECT count(id) AS hits, length(substring(soundex(contact_org.name),1,%1\$d)) AS len, substring(soundex(contact_org.name),1,%1\$d) AS soundex ".
			"FROM contact_org ".
			"%3\$s".
			"GROUP BY soundex ".
			"HAVING hits > 1 ".
			"AND len > %2\$d",
			$snd_len,
			$min_len,
			(!empty($starts_with) ? sprintf("WHERE contact_org.name LIKE %s ", $db->qstr($starts_with.'%')) : '')
		);
		$db->Execute($sql);

		$sql = sprintf("SELECT id, name, SUBSTRING(SOUNDEX(name),1,%1\$d) AS soundex ".
			"FROM contact_org ".
			"WHERE SUBSTRING(SOUNDEX(name),1,%1\$d) IN (SELECT soundex FROM tmp_soundex) ".
			"ORDER BY soundex",
			$snd_len,
			$min_len
		);
		
		$rs = $db->Execute($sql);
		$buffer = array();
		$current_soundex = null;
		
		if($rs instanceof mysqli_result)
		while($row = mysqli_fetch_assoc($rs)) {
			$id = $row['id'];
			$name = $row['name'];
			$soundex = $row['soundex'];
			$indexed = strtolower(DevblocksPlatform::strAlphaNum($name));
			$row['indexed'] = $this->_removeOrgSuffixes($indexed);
			
			if($current_soundex != $soundex) {
				$this->_buffer = array();
				
				if(!empty($buffer)) {
					usort($buffer, array($this,'_sortByDistance'));
					//var_dump($this->_buffer);
					
					if(!empty($this->_buffer)) {
						$tpl->assign('similarities', $this->_buffer);
						$tpl->display('devblocks:wgm.org_dupe_finder::results.tpl');
					}
				}
				
				$buffer = array();
				$this->_buffer = array();
			}
			
			$buffer[] = $row;
			$current_soundex = $soundex;
		}
		
		mysqli_free_result($rs);
	}
	
	private $_buffer = array();
	
	private function _sortByDistance($a, $b) {
		$len_a = strlen($a['name']);
		$len_b = strlen($b['name']);
		$min = max(min($len_a, $len_b),1);
		$smaller = ($len_a < $len_b) ? $a : $b;
		$larger = ($smaller == $a) ? $b : $a;
		$dist = levenshtein($a['indexed'], $b['indexed']);
		
		// If the larger string contains the smaller one verbatim, or they diverge less than 20%
		if(false !== strstr($larger['indexed'], $smaller['indexed']) || ($dist / $min) <= 0.20) {
			$this->_buffer[$a['id']] = $a;
			$this->_buffer[$b['id']] = $b;
		}
		
		if(0==$dist)
			return $dist;
		
		return ($dist < 3) ? -1 : 1;
	}
	
	private function _removeOrgSuffixes($str) {
		$suffixes = array(
			'inc',
			'llc',
			'ltd',
			'inc ltd',
			'ptyltd',
			'com',
			'net',
			'corp',
			'spzoo',
			'zoo',
			'bv',
			'sa',
			'sl',
			'oy',
			'sdnbhd',
		);
		
		foreach($suffixes as $suffix) {
			$count = null;
			$str = preg_replace("#(.*)$suffix$#", '\1', $str, 1, $count);
			if($count)
				return $str;
		}
		
		return $str;
	}
	
	function exportTabConfigJson(Model_WorkspacePage $page, Model_WorkspaceTab $tab) {
		$json = array(
			'tab' => array(
				'name' => $tab->name,
				'extension_id' => $tab->extension_id,
				'params' => $tab->params,
			),
		);
		
		return json_encode($json);
	}
	
	function importTabConfigJson($json, Model_WorkspaceTab $tab) {
		if(empty($tab) || empty($tab->id) || !is_array($json) || !isset($json['tab']))
			return false;
		
		return true;
	}
};
endif;