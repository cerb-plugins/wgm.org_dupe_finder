<fieldset style="margin:0;margin-top:10px;" class="peek">
<a href="javascript:;" style="display:none;position:absolute;margin-top:-10px;margin-left:-15px;" onclick="$(this).closest('fieldset').remove();"><span class="glyphicons glyphicons-circle-remove" style="font-size:16px;color:rgb(200,0,0);vertical-align:middle;"></span></a>

<ul style="list-style:none;margin:0;padding:0;">
{foreach from=$similarities item=org}
	<li style="padding-left:10px;">
		<label style="cursor:pointer;padding:2px;">
			<input type="checkbox" name="org_id[]" value="{$org.id}"> 
			<b>{$org.name}</b>
		</label>
		
		<a href="javascript:;" style="display:none;" onclick="genericAjaxPopup('peek','c=internal&a=showPeekPopup&context={CerberusContexts::CONTEXT_ORG}&context_id={$org.id}',null,false,'50%');"><span class="glyphicons glyphicons-search"></span></a></a>
	</li>
{/foreach}
</ul>
</fieldset>