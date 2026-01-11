<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title sclang>UnblockNeteaseMusic</title>
<link rel="stylesheet" type="text/css" href="index_style.css"> 
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/js/table/table.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/js/table/table.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/js/i18n.js"></script>
<style>
a:focus {
	outline: none;
}
.SimpleNote {
	padding:5px 5px;
}
i {
    color: #FC0;
    font-style: normal;
}
#return_btn {
	cursor:pointer;
	position:absolute;
	margin-left:-30px;
	margin-top:-25px;
}
.popup_bar_bg_ks{
	position:fixed;	
	margin: auto;
	top: 0;
	left: 0;
	width:100%;
	height:100%;
	z-index:99;
	filter:alpha(opacity=90);  /*IE5、IE5.5、IE6、IE7*/
	background-repeat: repeat;
	visibility:hidden;
	overflow:hidden;
	background:rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important; /* W3C  */
	background-position: 0 0;
	background-size: cover;
	opacity: .94;
}
.loading_block_spilt {
    background: #656565;
    height: 1px;
    width: 98%;
}
.content_status {
	position: absolute;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius:10px;
	z-index: 10;
	margin-left: -415px;
	top: 0;
	left: 0;
	height:auto;
	box-shadow: 3px 3px 10px #000;
	background: rgba(0,0,0,0.88);
	width:948px;
	/*display:none;*/
	visibility:hidden;
}
.user_title{
	text-align:center;
	font-size:18px;
	color:#99FF00;
	padding:10px;
	font-weight:bold;
}
#ts_status, #ts_check{
	border:0px solid #222;
	width:98%;
	font-family:'Lucida Console';
	font-size:12px;
	padding-left:13px;
	padding-right:33px;
	background: transparent;
	color:#FFFFFF;
	outline:none;
	overflow-x:hidden;
	line-height:1.5;
}
input[type=button]:focus {
	outline: none;
}
#log_content {
	border:1px solid #000;
	width:99%;
	font-family:'Lucida Console';
	font-size:11px;
	padding-left:3px;
	padding-right:22px;
	background:transparent;
	color:#FFFFFF;
	outline:none;
	overflow-x:hidden;
	line-height:1.5;
}
.FormTitle em {
    color: #00ffe4;
    font-style: normal;
    font-weight:bold;
}
.FormTable th {
	width: 30%;
}
.formfonttitle {
	font-family: Roboto-Light, "Microsoft JhengHei";
	font-size: 18px;
	margin-left: 5px;
}
.FormTitle, .FormTable, .FormTable th, .FormTable td, .FormTable thead td, .FormTable_table, .FormTable_table th, .FormTable_table td, .FormTable_table thead td {
	font-size: 14px;
	font-family: Roboto-Light, "Microsoft JhengHei";
}
.FormTable_table{
	margin-top:0px;
}
.FormTable th {
    width: 35%;
}
#app[skin=ASUSWRT] #tailscale_main, #app[skin=ASUSWRT] #tailscale_tcnets {
	outline: none;
}
#app[skin=ASUSWRT] .loadingBarBlock{
	width:770px;
	outline: none;
}
#app[skin=ASUSWRT] .content_status{
	outline: none;
}
#app[skin=ROG] #tailscale_main, #app[skin=ROG] #tailscale_tcnets {
	outline: 1px solid #91071f;
}
#app[skin=ROG] .loadingBarBlock{
	width:770px;
	outline: 1px solid #91071f;
}
#app[skin=ROG] .content_status{
	outline: 1px solid #91071f;
}
#app[skin=TUF] #tailscale_main, #app[skin=TUF] #tailscale_tcnets {
	outline: 1px solid #ffa523;
}
#app[skin=TUF] .loadingBarBlock{
	width:770px;
	outline: 1px solid #ffa523;
}
#app[skin=TUF] .content_status{
	outline: 1px solid #ffa523;
}
#app[skin=TS] #tailscale_main, #app[skin=TS] #tailscale_tcnets {
	outline: 1px solid #2ed9c3;
}
#app[skin=TS] .loadingBarBlock{
	width:770px;
	outline: 1px solid #2ed9c3;
}
#app[skin=TS] .content_status{
	outline: 1px solid #2ed9c3;
}
</style>
<script>
var	refresh_flag;
var count_down;
var db_unblockneteasemusic = {};
var params_chk = ['unblockneteasemusic_enable'];
var params_input = ["unblockneteasemusic_musicapptype"];
var params_base64 = ["unblockneteasemusic_cookie"];
String.prototype.myReplace = function(f, e){
	var reg = new RegExp(f, "g"); 
	return this.replace(reg, e); 
}

function init() {
	show_menu(menu_hook);
	sc_load_lang("music");
	set_skin();
	get_dbus_data();
	type_onchange();
}
function set_skin(){
	var SKN = '<% nvram_get("sc_skin"); %>';
	if(SKN){
		$("#app").attr("skin", '<% nvram_get("sc_skin"); %>');
	}
}
function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/unblockneteasemusic_",
		dataType: "json",
		async: false,
		success: function(data) {
			db_unblockneteasemusic = data.result[0];
			conf2obj();
			//register_event();
			if(db_unblockneteasemusic["unblockneteasemusic_enable"] == "1"){
				get_proces_status();
			}
		}
	});
}
function conf2obj(){
	//input
	for (var i = 0; i < params_input.length; i++) {
		if(db_unblockneteasemusic[params_input[i]]){
			E(params_input[i]).value = db_unblockneteasemusic[params_input[i]];
		}
	}
	//checkbox
	for (var i = 0; i < params_chk.length; i++) { 
		if(db_unblockneteasemusic[params_chk[i]]){
			E(params_chk[i]).checked = db_unblockneteasemusic[params_chk[i]] != "0";
		}
	}
	//base64
	for (var i = 0; i < params_base64.length; i++) {
		if(db_unblockneteasemusic[params_base64[i]]){
			E(params_base64[i]).value = Base64.decode(db_unblockneteasemusic[params_base64[i]]);
		}
	}
	if (db_unblockneteasemusic["unblockneteasemusic_version"]){
		E("unblockneteasemusic_version").innerHTML = " - " + db_unblockneteasemusic["unblockneteasemusic_version"];
	}
}
function register_event(){
	$("#unblockneteasemusic_enable").click(
		function() {
			if (db_unblockneteasemusic["unblockneteasemusic_enable"] == "1"){
				E("unblockneteasemusic_enable").checked = false;
			}else{
				E("unblockneteasemusic_enable").checked = true;
			}
			save();
		});	
}
function save() {
	var dbus_new = {};
	for (var i = 0; i < params_chk.length; i++) {
		dbus_new[params_chk[i]] = E(params_chk[i]).checked ? '1' : '0';
	}
	for (var i = 0; i < params_input.length; i++) {
		dbus_new[params_input[i]] = E(params_input[i]).value;
	}
	for (var i = 0; i < params_base64.length; i++) {
		if (E(params_base64[i]).value && Base64.encode(E(params_base64[i]).value) != db_unblockneteasemusic[params_base64[i]]) {
			db_unblockneteasemusic[params_base64[i]] = Base64.encode(E(params_base64[i]).value);
		} else if (!E(params_base64[i]).value && db_unblockneteasemusic[params_base64[i]]) {
			db_unblockneteasemusic[params_base64[i]] = "";
		}
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "unblockneteasemusic_config.sh", "params": ["web_submit"], "fields": dbus_new};
	$.ajax({
		type: "POST",
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				get_log();
				if(db_unblockneteasemusic["unblockneteasemusic_enable"] == "1"){
					get_proces_status();
				}
			}
		}
	});
}
function showWBLoadingBar(){
	document.scrollingElement.scrollTop = 0;
	E("loading_block_title").innerHTML = "&nbsp;&nbsp;tailscale" + dict["Log"];
	E("LoadingBar").style.visibility = "visible";
	var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
	var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	var log_h = E("loadingBarBlock").clientHeight;
	var log_w = E("loadingBarBlock").clientWidth;
	var log_h_offset = (page_h - log_h) / 2;
	var log_w_offset = (page_w - log_w) / 2 + 95;
	$('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
}
function hideWBLoadingBar(){
	E("LoadingBar").style.visibility = "hidden";
	E("ok_button").style.visibility = "hidden";
	if (refresh_flag == "1"){
		refreshpage();
	}
}
function count_down_close() {
	if (count_down == "0") {
		hideWBLoadingBar();
	}
	if (count_down < 0) {
		E("ok_button1").value = dict["Close"];
		return false;
	}
	E("ok_button1").value = dict["Auto Close"] + "(" + count_down + ")"
		--count_down;
	setTimeout("count_down_close();", 1000);
}
function get_log(){
	E("ok_button").style.visibility = "hidden";
	showWBLoadingBar();
	$.ajax({
		url: '/_temp/unblockneteasemusic_log.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content");
			if (response.search("XU6J03M6") != -1) {
				retArea.value = response.myReplace("XU6J03M6", " ");
				E("ok_button").style.visibility = "visible";
				retArea.scrollTop = retArea.scrollHeight;
				if(flag == 1){
					count_down = -1;
					refresh_flag = 0;
				}else{
					count_down = 6;
					refresh_flag = 1;
				}
				count_down_close();
				return false;
			}
			setTimeout("get_log();", 500);
			retArea.value = response.myReplace("XU6J03M6", " ");
			retArea.scrollTop = retArea.scrollHeight;
		},
		error: function(xhr) {
			E("loading_block_title").innerHTML = dict["No log messages"];
			E("log_content").value = dict["Log file is empty, please close this window"];
			E("ok_button").style.visibility = "visible";
			return false;
		}
	});
}
function get_proces_status2(id) {
	$.ajax({
		url: '/_temp/'+id,
		type: 'GET',
		async: true,
		cache: false,
		dataType: 'text',
		success: function(res) {
			E("unblockneteasemusic_status").innerHTML = res;
			setTimeout("get_proces_status();", 5000);
		}
	});
}
function get_proces_status() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "unblockneteasemusic_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache: false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			//console.log(response);
			if(typeof response.result != "number"){
				E("unblockneteasemusic_status").innerHTML = response.result;
				setTimeout("get_proces_status();", 5000);
			}else
				setTimeout("get_proces_status2("+id+");", 1000);
		},
		error: function() {
			setTimeout("get_proces_status();", 5000);
		}
	});
}
function download(){
	window.open("http://"+window.location.hostname+"/ext/ca.crt");
}
function type_onchange() {
	var type = E("unblockneteasemusic_musicapptype").value;
	if(type == "qq"){
		E("unblockneteasemusic_cookie_tr").style.display = "";
		E("unblockneteasemusic_cookie").placeholder = "uin=your_uin; qm_keyst=your_qm_keyst";
	}else if(type == "migu"){
		E("unblockneteasemusic_cookie_tr").style.display = "";
		E("unblockneteasemusic_cookie").placeholder = "your_aversionid";
	}else if(type == "joox"){
		E("unblockneteasemusic_cookie_tr").style.display = "";
		E("unblockneteasemusic_cookie").placeholder = "wmid=your_wmid; session_key=your_session_key";
	}else
		E("unblockneteasemusic_cookie_tr").style.display = "none";
}
function openssHint(itemNum) {
	statusmenu = "";
	width = "350px";
	if (itemNum == 0) {
		statusmenu = "部分音源需要设置cookie，[joox]:在 joox.com 获取，需要 wmid 和 session_key 值，[QQ]:在 y.qq.com 获取，需要 uin 和 qm_keyst 值，[Migu]:通过抓包手机客户端请求获取，需要 aversionid 值";
		_caption = "cookie设置说明";
	} else if (itemNum == 1) {
		statusmenu = "默认为选择酷狗/波点/咪咕/youtube4个音源，其他音源均为单一音源";
		_caption = "音源选择";
	}
	return overlib(statusmenu, OFFSETX, -160, LEFT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
	var tag_name = document.getElementsByTagName('a');
	for (var i = 0; i < tag_name.length; i++)
		tag_name[i].onmouseout = nd;
	if (helpcontent == [] || helpcontent == "" || hint_array_id > helpcontent.length)
		return overlib('<#defaultHint#>', HAUTO, VAUTO);
	else if (hint_array_id == 0 && hint_show_id > 21 && hint_show_id < 24)
		return overlib(helpcontent[hint_array_id][hint_show_id], FIXX, 270, FIXY, 30);
	else {
		if (hint_show_id > helpcontent[hint_array_id].length)
			return overlib('<#defaultHint#>', HAUTO, VAUTO);
		else
			return overlib(helpcontent[hint_array_id][hint_show_id], HAUTO, VAUTO);
	}
}
function mOver(obj, hint){
	mouse_status = 1;
	$("#overDiv").unbind();
	$(obj).css({
		"color": "#00ffe4",
		"text-decoration": "underline"
	});
	openssHint(hint);
}
function mOut(obj){
	if (mouse_status == 0) return;
	if ($("#overDiv").is(":hover") == false){
		E("overDiv").style.visibility = "hidden";
	}else{
		$("#overDiv").bind('mouseleave', function() {
			E("overDiv").style.visibility = "hidden";
		});
	}
}
function RunmOut(obj){
	$(obj).css({
		"color": "#03a9f4",
		"text-decoration": ""
	});
	mOut("' + obj + '");
}
function menu_hook(title, tab) {
	tabtitle[tabtitle.length -1] = new Array("", dict["Software Center"], dict["Offline installation"], dict["UnblockNeteaseMusic"]);
	tablink[tablink.length -1] = new Array("", "Main_Soft_center.asp", "Main_Soft_setting.asp", "Module_unblockneteasemusic.asp");
}
</script>
</head>
<body id="app" skin="ASUSWRT" onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
		<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
			<tr>
				<td height="100">
				<div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
				<div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt"></div>
				<div style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
					<textarea cols="50" rows="26" wrap="on" readonly="readonly" id="log_content" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" ></textarea>
				</div>
				<div id="ok_button" class="apply_gen" style="background:#000;visibility:hidden;">
					<input sclang id="ok_button1" class="button_gen" type="button" onclick="hideWBLoadingBar()" value="OK">
				</div>
				</td>
			</tr>
		</table>
	</div>
	<!--=============================================================================================================-->
	<table class="content" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td width="17">&nbsp;</td>
			<td valign="top" width="202">
				<div id="mainMenu"></div>
				<div id="subMenu"></div>
			</td>
			<td valign="top">
				<div id="tabMenu" class="submenuBlock"></div>
				<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
					<tr>
						<td align="left" valign="top">
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top">
										<div>&nbsp;</div>
										<div class="formfonttitle">UnblockNeteaseMusic<lable id="unblockneteasemusic_version"></lable></div>
										<div style="float:right; width:15px; height:25px;margin-top:-20px">
											<img id="return_btn" onclick="reload_Soft_Center();" align="right" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
										</div>
										<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote">
											<span><em>采用 [QQ/百度/酷狗/酷我/咕咪/JOOX]等音源，替换网易云变灰歌曲链接<br>目前仅支持手动设置代理。<br>苹果系列设备需要设置 WIFI/有线代理方式为[自动],URL为http://<% nvram_get("lan_ipaddr"); %>:5200/proxy.pac,并安装 CA根证书并信任。<br>HTTP代理IP:<% nvram_get("lan_ipaddr"); %>,端口:5200<br>HTTPS代理IP:<% nvram_get("lan_ipaddr"); %>,端口:5300</em></span>
										</div>
										<div id="unblockneteasemusic_main">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" class="FormTable">
												<thead>
													<tr>
														<td colspan="2" sclang>UnblockNeteaseMusic - Settings</td>
													</tr>
												</thead>
												<tr id="switch_tr">
													<th sclang>Enable</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="unblockneteasemusic_enable">
																<input id="unblockneteasemusic_enable" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr>
													<th sclang>Status</th>
													<td colspan="2" span style="margin-left:4px" id="unblockneteasemusic_status"></span>
													</td>
												</tr>
												<tr id="unblockneteasemusic_musicapptype_tr">
													<th>
														<a class="hintstyle" style="color:#03a9f4;" href="javascript:void(0);" onclick="openssHint(1)" onmouseover="mOver(this, 1)" onmouseout="RunmOut(this)"><label sclang>Music app type</label>
													</th>
													<td>
														<div style="float:left; width:165px; height:25px">
															<select id="unblockneteasemusic_musicapptype" name="unblockneteasemusic_musicapptype" style="width:164px;margin:0px 0px 0px 2px;" class="input_option"  onchange="type_onchange()">
																<option value="default" sclang>Default</option>
																<option value="qq" sclang>QQ</option>
																<option value="bilibili" sclang>Bilibili</option>
																<option value="kugou" sclang>Kugou</option>
																<option value="kuwo" sclang>Kuwo</option>
																<option value="migu" sclang>Migu</option>
																<!--option value="joox" sclang>Joox</option-->
															</select>
														</div>
													</td>
												</tr>
												<tr id="unblockneteasemusic_cookie_tr" style="display: none;">
													<th>
														<a class="hintstyle" style="color:#03a9f4;" href="javascript:void(0);" onclick="openssHint(0)" onmouseover="mOver(this, 0)" onmouseout="RunmOut(this)"><label>cookie</label>
													</th>
													<td>
														<input type="text" class="input_ss_table" id="unblockneteasemusic_cookie" name="unblockneteasemusic_cookie" maxlength="50" value="" placeholder="" />
													</td>
												</tr>
												<tr id="cert_download_tr">
													<th>
														<label sclang>Download cert</label>
													</th>
													<td>
														<input sclang type="button" id="download_cert" class="button_gen" onclick="download();" value="Download cert" />&nbsp;&nbsp;<span>Linux / iOS / MacOSX 在信任根证书后方可正常使用</span>
													</td>
												</tr>
											</table>
										</div>
										<div class="apply_gen">
											<input sclang id="cmdBtn" type="button" class="button_gen" onclick="save()" value="Apply"/>
										</div>
										<div class="SCBottom" style="float:right; width:180px; height:70px">
											Shell&Web by： <i>paldier</i>
										</div>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
			<td width="10" align="center" valign="top"></td>
		</tr>
	</table>
	<div id="footer"></div>
</body>
</html>
