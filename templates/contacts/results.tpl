<fieldset style="margin:0;margin-top:10px;">
<a href="javascript:;" style="display:none;position:absolute;margin-top:-10px;margin-left:-15px;" onclick="$(this).closest('fieldset').remove();"><span class="cerb-sprite2 sprite-cross-circle-frame" style="vertical-align:middle;"></span></a>

<ul style="list-style:none;margin:0;padding:0;">
{foreach from=$similarities item=org}
	<li style="padding-left:10px;">
		<label style="cursor:pointer;padding:2px;">
			<input type="checkbox" name="org_id[]" value="{$org.id}"> 
			<b>{$org.name}</b>
		</label>
		
		<a href="javascript:;" style="display:none;" onclick="genericAjaxPopup('peek','c=contacts&a=showOrgPeek&id={$org.id}',null,false,'550');"><span class="cerb-sprite2 sprite-document-search-result" style="vertical-align:middle;"></span></a>
	</li>
{/foreach}
</ul>
</fieldset>