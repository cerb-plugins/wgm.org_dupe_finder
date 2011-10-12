<form id="frmFindDupeOrgs" action="{devblocks_url}{/devblocks_url}" method="POST" style="margin-bottom:10px;" onsubmit="return false;">
	<input type="hidden" name="c" value="contacts">
	<input type="hidden" name="a" value="handleTabAction">
	<input type="hidden" name="tab" value="wgm.orgdupefinder.tab">
	<input type="hidden" name="action" value="findDupes">

	<button type="button" class="search"><span class="cerb-sprite2 sprite-document-search-result"></span> Find Similar Orgs</button>
	 &nbsp; 
	Starts with: <input type="text" name="starts_with" size="6" value="">
</form>
	
<form id="frmOrgDupeResults" action="{devblocks_url}{/devblocks_url}" method="POST" onsubmit="return false;">
	<input type="hidden" name="c" value="contacts">
	<input type="hidden" name="a" value="showOrgMergeContinuePeek">

	<div id="divOrgDupeResults" style="margin-top:10px;"></div>
	
	<div class="toolbar" style="display:none;padding:5px;background-color:rgb(235,235,235);border-color:rgb(200,200,200);border-width:0px 1px 1px 1px;">
		<button type="button" class="merge"><span class="cerb-sprite2 sprite-tick-circle-frame"></span> Merge</button>
		<button type="button" class="remove" style="display:none;">Remove</button>
		<button type="button" class="clear"><span class="cerb-sprite2 sprite-cross-circle-frame"></span> Clear</button>
	</div>
</form>

<script type="text/javascript">
$frm = $('#frmFindDupeOrgs');

$frm.find('> button.search').click(function(e) {
	$('#frmOrgDupeResults div.toolbar').prependTo($('#frmOrgDupeResults'));
	$('#divOrgDupeResults').html('<div style="font-size:18pt;text-align:center;padding:50px;margin:20px;background-color:rgb(232,242,255);">Computing, please wait...</div>');
	genericAjaxPost('frmFindDupeOrgs','','c=contacts&a=handleTabAction',function(html) {
		$div = $('#divOrgDupeResults');
		$div.html(html);
		$div.find('input:checkbox')
			.change(function(e) {
				$parent = $(this).closest('fieldset');
				$toolbar = $('#frmOrgDupeResults div.toolbar').insertAfter($parent).show().find('button:first').focus();
			})
			.closest('li')
			.hover(function(e) {
				$(this).find('a').show();
			},function(e) {
				$(this).find('a').hide();
			})
		;
		$div.find('fieldset').hover(
			function(e) {
				$(this).find('> a').show();
			},
			function(e) {
				$(this).find('> a').hide();
			}
		)
		;
	});
});

$frm = $('#frmOrgDupeResults');

$frm.find('div.toolbar > button.clear').click(function(e) {
	$frm = $(this).closest('form');
	$frm.find(':checkbox:checked').each(function(e) {
		$(this).removeAttr('checked');
	});
	$(this).closest('div').hide();
});

$frm.find('div.toolbar > button.merge').click(function(e) {
	$frm = $(this).closest('form');
 	var checks = '&org_id[]=' + $frm.find(':checkbox:checked').map(function(e) {
 		return $(this).val();
 	}).get().join('&org_id[]=');

 	$popup = genericAjaxPopup('peek','c=contacts&a=showOrgMergeContinuePeek&is_ajax=1' + checks, null, false, '500');
 	$popup.one('org_merge',function(e) {
 		$frm = $('#frmOrgDupeResults');
 		$toolbar = $frm.find('div.toolbar');
 		$toolbar.find('> button.remove').click();
 		$toolbar.hide();
 	});
});

$frm.find('div.toolbar > button.remove').click(function(e) {
	$frm = $(this).closest('form');
	$frm.find(':checkbox:checked').each(function(box) {
		$li = $(this).closest('li');
		if($li.closest('ul').find('> li').length == 1)
			$li.closest('fieldset').remove();
		else
			$li.remove();
	});
});
</script>